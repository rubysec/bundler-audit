#
# Copyright (c) 2013-2019 Hal Brodigan (postmodern.mod3 at gmail.com)
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
require 'bundler/audit/presenter/default'
require 'bundler/audit/presenter/junit'

require 'thor'
require 'bundler'
require 'bundler/vendored_thor'

module Bundler
  module Audit
    class CLI < ::Thor
      DEFAULT_PRESENTER = 'Default'
      Error = Class.new(RuntimeError)
      PresenterUnkown = Class.new(Error)
      PresenterInvalid = Class.new(Error)

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :quiet, :type => :boolean, :aliases => '-q'
      method_option :verbose, :type => :boolean, :aliases => '-v'
      method_option :ignore, :type => :array, :aliases => '-i'
      method_option :update, :type => :boolean, :aliases => '-u'
      method_option :presenter, :type => :string, :aliases => '-p', :default => DEFAULT_PRESENTER

      def check
        update if options[:update]

        scanner    = Scanner.new
        presenter = presenter_klass(options[:presenter]).new(self.shell, options)

        scanner.scan(:ignore => options.ignore) do |result|
          case result
          when Scanner::InsecureSource
            presenter.push_warning "Insecure Source URI found: #{result.source}"
          when Scanner::UnpatchedGem
            presenter.push_advisory result
          end
        end

        presenter.print_report
        exit presenter.exit_code

      rescue Error => e
        say e.message, :red
        exit 1
      end

      desc 'update', 'Updates the ruby-advisory-db'
      method_option :quiet, :type => :boolean, :aliases => '-q'

      def update
        say("Updating ruby-advisory-db ...") unless options.quiet?

        case Database.update!(quiet: options.quiet?)
        when true
          say("Updated ruby-advisory-db", :green) unless options.quiet?
        when false
          say "Failed updating ruby-advisory-db!", :red
          exit 1
        when nil
          say "Skipping update", :yellow
        end

        unless options.quiet?
          puts("ruby-advisory-db: #{Database.new.size} advisories")
        end
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

      def presenter_klass(presenter_string)
        presenter_name = options[:presenter].capitalize.to_sym
        raise PresenterUnkown, "Unknown Presenter '#{presenter_name}'" unless Presenter.const_defined? presenter_name

        Presenter.const_get presenter_name
      rescue NameError
        raise PresenterInvalid, "Invalid Presenter Name '#{presenter_name}'"
      end
    end
  end
end
