#
# Copyright (c) 2013-2015 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# bundler-audit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bundler-audit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bundler-audit.  If not, see <http://www.gnu.org/licenses/>.
#

require 'bundler/audit/scanner'
require 'bundler/audit/version'

require 'thor'
require 'bundler'
require 'bundler/vendored_thor'

module Bundler
  module Audit
    class CLI < ::Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :verbose, :type => :boolean, :aliases => '-v'
      method_option :ignore, :type => :array, :aliases => '-i'

      def check
        scanner    = Scanner.new
        vulnerable = false

        scanner.scan(:ignore => options.ignore) do |result|
          vulnerable = true

          case result
          when Scanner::InsecureSource
            print_warning "Insecure Source URI found: #{result.source}"
          when Scanner::UnpatchedGem
            print_advisory result.gem, result.advisory
          end
        end

        if vulnerable
          say "Vulnerabilities found!", :red
          exit 1
        else
          say "No vulnerabilities found", :green
        end
      end

      desc 'update', 'Updates the ruby-advisory-db'
      def update
        say "Updating ruby-advisory-db ..."

        Database.update!
        puts "ruby-advisory-db: #{Database.new.size} advisories"
      end

      desc 'version', 'Prints the bundler-audit version'
      def version
        database = Database.new

        puts "#{File.basename($0)} #{VERSION} (advisories: #{database.size})"
      end

      protected

      def say(message="", color=nil)
        color = nil unless $stdout.tty?
        super(message.to_s, color)
      end

      def print_warning(message)
        say message, :yellow
      end

      def print_advisory(gem, advisory)
        say "Name: ", :red
        say gem.name

        say "Version: ", :red
        say gem.version

        say "Advisory: ", :red

        if advisory.cve
          say "CVE-#{advisory.cve}"
        elsif advisory.osvdb
          say advisory.osvdb
        end

        say "Criticality: ", :red
        case advisory.criticality
        when :low    then say "Low"
        when :medium then say "Medium", :yellow
        when :high   then say "High", [:red, :bold]
        else              say "Unknown"
        end

        say "URL: ", :red
        say advisory.url

        if options.verbose?
          say "Description:", :red
          say

          print_wrapped advisory.description, :indent => 2
          say
        else

          say "Title: ", :red
          say advisory.title
        end

        unless advisory.patched_versions.empty?
          say "Solution: upgrade to ", :red
          say advisory.patched_versions.join(', ')
        else
          say "Solution: ", :red
          say "remove or disable this gem until a patch is available!", [:red, :bold]
        end

        say
      end

    end
  end
end
