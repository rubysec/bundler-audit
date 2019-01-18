require 'bundler/audit/presenter/base'

module Bundler
  module Audit
    module Presenter
      class Plain < Base
        def print_report
          @warnings.each do |warning|
            print_warning warning
          end

          @advisory_bundles.each do |bundle|
            print_advisory bundle.gem, bundle.advisory
          end

          if problematic?
            say "Vulnerabilities found!", :red
          else
            say("No vulnerabilities found", :green) unless options.quiet?
          end
        end

        protected

        def say(message = '', color = nil)
          color = nil unless $stdout.tty?
          shell.say(message.to_s, color)
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
end
