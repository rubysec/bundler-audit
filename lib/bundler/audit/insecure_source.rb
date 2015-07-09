# Represents a plain-text source
module Bundler
  module Audit
    class InsecureSource

      # The repository source url
      #
      # @return [String]
      attr_accessor :source

      #
      # Initializes an unpatched gem.
      #
      # @param [String] source
      #   The repository source url
      def initialize(source)
        @source = source
      end

      #
      # Returns relevant details about an insecure source.
      #
      # @return [String]
      #
      def to_s
        "Insecure Source URI found: #{self.source}"
      end
    end
  end
end
