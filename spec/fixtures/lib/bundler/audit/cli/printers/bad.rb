require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Printers
        module Bad

          def print_report(report)
            say "I am a bad printer!", :red
          end

        end

        Printers.register :incorrect, Bad
      end
    end
  end
end
