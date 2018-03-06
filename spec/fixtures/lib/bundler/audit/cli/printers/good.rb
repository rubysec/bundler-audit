require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Printers
        module Good

          def print_report(report)
            say "I am a good printer.", :green
          end

        end

        Printers.register :good, Good
      end
    end
  end
end
