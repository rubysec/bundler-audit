require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Printers
        module Text

          #
          # Prints any findings as plain-text.
          #
          # @param [Enumerator] findings
          #   The results from the {Scanner}.
          #
          def print_results(results)
            vulnerable = false

            results.each do |result|
              vulnerable = true

              case result
              when Results::InsecureSource
                print_warning "Insecure Source URI found: #{result.source}"
              when Results::UnpatchedGem
                print_advisory result.gem, result.advisory
              end
            end

            if vulnerable
              say "Vulnerabilities found!", :red
              exit 1
            else
              say("No vulnerabilities found", :green) unless options.quiet?
            end
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

        Printers.register :text, Text
      end
    end
  end
end
