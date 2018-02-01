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
        # Converts the unpatched gem result into a String.
        #
        # @return [String]
        #
        def to_s
          @advisory.id
        end

      end
    end
  end
end
