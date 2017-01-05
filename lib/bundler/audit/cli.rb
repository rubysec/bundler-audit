#
# Copyright (c) 2013-2016 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'json'

module Bundler
  module Audit
    class CLI < ::Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :verbose, :type => :boolean, :aliases => '-v'
      method_option :ignore, :type => :array, :aliases => '-i'
      method_option :update, :type => :boolean, :aliases => '-u'
      method_option :json, :type => :boolean

      def check
        update if options[:update]

        scanner = Scanner.new
        vulnerable = false

        insecure_sources = scanner.scan_sources(:ignore => options.ignore).to_a
        unpatched_gems = scanner.scan_specs(:ignore => options.ignore).to_a

        vulnerable = !(insecure_sources.empty? and unpatched_gems.empty?)

        if options.json
          print_vulnerabilities_json(insecure_sources, unpatched_gems)
        else
          print_vulnerabilities(insecure_sources, unpatched_gems)
        end

        if options.json
          error "Vulnerabilities found!" if vulnerable
        else
          if vulnerable
            say "Vulnerabilities found!", :red
          else
            say "No vulnerabilities found", :green
          end
        end

        if vulnerable
          exit 1
        end
      end

      desc 'update', 'Updates the ruby-advisory-db'
      def update
        say "Updating ruby-advisory-db ..."

        case Database.update!
        when true
          say "Updated ruby-advisory-db", :green
        when false
          say "Failed updating ruby-advisory-db!", :red
          exit 1
        when nil
          say "Skipping update", :yellow
        end

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

      def print_vulnerabilities(insecure_sources, unpatched_gems)
        insecure_sources.each do |r|
          print_warning "Insecure Source URI found: #{r.source}"
        end

        unpatched_gems.each do |r|
          print_advisory(r.gem, r.advisory)
        end
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

      def print_vulnerabilities_json(insecure_sources, unpatched_gems)
        h = {
          :vulnerable_sources => insecure_sources.map { |r| { :uri => r.source } },
          :unpatched_gems => unpatched_gems.map { |r| r.advisory.to_h.merge(:name => r.gem.name, :version => r.gem.version) }
        }
        say JSON.pretty_generate(h)
      end
    end
  end
end
