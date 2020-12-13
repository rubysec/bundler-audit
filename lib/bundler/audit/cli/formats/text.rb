require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Formats
        module Text

          #
          # Prints any findings as plain-text.
          #
          # @param [Report] report
          #   The results from the {Scanner}.
          #
          # @param [IO] output
          #   Optional output stream.
          #
          def print_report(report,output=$stdout)
            original_stdout = $stdout
            $stdout = output

            report.each do |result|
              case result
              when Results::InsecureSource
                print_warning "Insecure Source URI found: #{result.source}"
              when Results::UnpatchedGem
                print_advisory result.gem, result.advisory
              end
            end

            if report.vulnerable?
              say "Vulnerabilities found!", :red
            else
              say("No vulnerabilities found", :green) unless options.quiet?
            end

            $stdout = original_stdout
          end

          private

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

        Formats.register :text, Text
      end
    end
  end
end
