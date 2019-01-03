require 'bundler/audit/results/result'

require 'uri'

module Bundler
  module Audit
    module Results
      class UnpatchedGem < Result

        # The specification of the vulnerable gem.
        #
        # @return [Gem::Specification]
        attr_reader :gem

        # The advisory documenting the vulnerability.
        #
        # @return [Advisory]
        attr_reader :advisory

        #
        # Initializes the unpatched gem result.
        #
        # @param [Gem::Specification] gem
        #   The specification of the vulnerable gem.
        #
        # @param [Advisory] advisory
        #   The advisory documenting the vulnerability.
        #
        def initialize(gem,advisory)
          @gem      = gem
          @advisory = advisory
        end

        #
        # Compares the unpatched gem to another result.
        #
        # @param [Result] result
        #
        # @return [Boolean]
        #
        def ==(other)
          self.class == other.class && (
            @gem.name == other.gem.name &&
            @gem.version == other.gem.version &&
            @advisory == other.advisory
          )
        end

        #
        # Converts the unpatched gem result into a String.
        #
        # @return [String]
        #
        def to_s
          @advisory.id
        end

        #
        # @return [Hash{Symbol => Object}]
        #
        def to_h
          {
            type: :unpatched_gem,
            gem:  {
              name: @gem.name,
              version: @gem.version
            },
            advisory: @advisory.to_h
          }
        end

      end
    end
  end
end
