require 'bundler/audit/database'
require 'bundler/audit/version'

require 'bundler/vendored_thor'
require 'bundler'

module Bundler
  module Audit
    class CLI < Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :verbose, :type => :boolean, :aliases => '-v'

      def check
        environment = Bundler.load
        database    = Database.new
        vulnerable  = false

        database.check_bundle(environment) do |gem,advisory|
          vulnerable = true

          print_advisory gem, advisory
        end

        if vulnerable
          say "Unpatched versions found!", :red
          return -1
        else
          say "No unpatched versions found", :green
        end
      end

      desc 'version', 'Prints the bundler-audit version'
      def version
        database = Database.new

        puts "#{File.basename($0)} #{VERSION} (advisories: #{database.size})"
      end

      protected

      def print_advisory(gem, advisory)
        say "Name: ", :red
        say gem.name

        say "Version: ", :red
        say gem.version

        say "CVE: ", :red
        say advisory.cve

        say "Criticality: ", :red
        case advisory.criticality
        when :low    then say "Low"
        when :medium then say "Medium", :yellow
        when :high   then say "High", [:red, :bold]
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
