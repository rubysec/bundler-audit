#
# Copyright (c) 2013-2026 Hal Brodigan (postmodern.mod3 at gmail.com)
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
# along with bundler-audit.  If not, see <https://www.gnu.org/licenses/>.
#

require 'thor'
require 'json'

module Bundler
  module Audit
    class CLI < ::Thor
      module Formats
        #
        # The JSON output format.
        #
        module JSON
          #
          # Outputs the report as JSON. Will pretty-print JSON if `output`
          # is a TTY, otherwise normal JSON will be outputted.
          #
          # @param [Report] report
          #   The results from the {Scanner}.
          #
          # @param [IO, File] output
          #   The output stream.
          #
          def print_report(report,output=$stdout)
            hash = prepare_data(report)

            if output.tty?
              output.puts(::JSON.pretty_generate(hash))
            else
              output.write(::JSON.generate(hash))
            end
          end

          def criticality_label(advisory)
            case advisory.criticality
            when :none     then "none"
            when :low      then "low"
            when :medium   then "medium"
            when :high     then "high"
            when :critical then "critical"
            else "unknown"
            end
          end

          private

          #
          # Prepares the data from the report into a hash before it is formatted as JSON.
          #
          # @param [Report] report
          #   The results from the {Scanner}.
          #
          # @return [Hash]
          #
          def prepare_data(report)
            hash = report.to_h
            hash[:results].each do |result|
              prepare_result(result)
            end
            hash
          end

          #
          # Prepares a result hash before it is formatted as JSON.
          #
          # @param [Hash] result
          #   A result
          #
          def prepare_result(result)
            if advisory = result[:advisory]
              advisory.delete(:gem)
              advisory.delete(:engine)
            end
          end
        end

        Formats.register :json, JSON
      end
    end
  end
end
