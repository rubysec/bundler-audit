require 'thor'
require 'json'

module Bundler
  module Audit
    class CLI < ::Thor
      module Formats
        module JSON
          def print_report(report,output=$stdout)
            hash = report.to_h

            if output.tty?
              output.puts ::JSON.pretty_generate(hash)
            else
              output.write(::JSON.generate(hash))
            end
          end
        end

        Formats.register :json, JSON
      end
    end
  end
end
