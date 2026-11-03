#
# Copyright (c) 2013-2024 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'bundler/audit/results/result'

require 'uri'

module Bundler
  module Audit
    module Results
      #
      # Represents a ruby engine that has known vulnerabilities and needs to be
      # upgraded.
      #
      class UnpatchedEngine < Result

        SHORT_TYPE = 'engine'.freeze

        # The vulnerable ruby engine.
        #
        # @return [Bundler::RubyVersion]
        attr_reader :ruby_version

        # The advisory documenting the vulnerability.
        #
        # @return [Advisory]
        attr_reader :advisory

        #
        # Initializes the unpatched engine result.
        #
        # @param [Bundler::RubyVersion] ruby_version
        #   The vulnerable ruby engine.
        #
        # @param [Advisory] advisory
        #   The advisory documenting the vulnerability.
        #
        def initialize(ruby_version,advisory)
          @ruby_version = ruby_version
          @advisory = advisory
        end

        #
        # The name of the vulnerable engine.
        #
        # @return [String]
        #
        def vulnerable_name
          @ruby_version.engine
        end

        #
        # The version of the vulnerable engine.
        #
        # @return [String]
        #
        def vulnerable_version
          @ruby_version.engine_gem_version.version
        end

        #
        # A short human-friendly type to output in warnings, returns 'engine'.
        #
        # @return [String]
        #
        def short_type
          SHORT_TYPE
        end

        #
        # Compares the unpatched engine to another result.
        #
        # @param [Result] other
        #
        # @return [Boolean]
        #
        def ==(other)
          self.class == other.class && (
            @ruby_version == other.ruby_version &&
            @advisory == other.advisory
          )
        end

        #
        # Converts the unpatched engine result into a String.
        #
        # @return [String]
        #
        def to_s
          @advisory.id
        end

        #
        # Converts the unpatched engine to a Hash.
        #
        # @return [Hash{Symbol => Object}]
        #
        def to_h
          {
            type: :unpatched_engine,
            engine:  {
              name: vulnerable_name,
              version: vulnerable_version
            },
            advisory: @advisory.to_h
          }
        end

      end
    end
  end
end
