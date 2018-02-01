require 'bundler/audit/results/result'

module Bundler
  module Audit
    module Results
      class InsecureSource < Result

        # The insecure `git://` or `http://` URI.
        #
        # @return [URI::Generic, URI::HTTP]
        attr_reader :source

        #
        # Initializes the insecure source result.
        #
        # @param [URI::Generic, URI::HTTP]
        #   The insecure `git://` or `http://` URI.
        #
        def initialize(source)
          @source = source
        end

        #
        # Converts the insecure source result to a String.
        #
        def to_s
          @source.to_s
        end

      end
    end
  end
end
