# Represents a gem that is covered by an Advisory
module Bundler
  module Audit
    class UnpatchedGem

      # The gem
      #
      # @return [Gem]
      attr_reader :gem

      # The advisory
      #
      # @return [Advisory]
      attr_accessor :advisory

      # The verbosity flag
      #
      # @return [Boolean]
      attr_accessor :verbose

      #
      # Initializes an unpatched gem.
      #
      # @param [Gem] gem
      #   The Gem which is audited
      #
      # @param [Advisory] advisory
      #   The advisory
      #
      # @param [Bool] verbose
      #   Be more verbose if true.
      #
      def initialize(gem,advisory,verbose=false)
        @gem      = gem
        @advisory = advisory
        @verbose  = verbose
      end

      #
      # Returns relevant details about an insecure gem.
      #
      # @return [String]
      #
      def to_s
        str = ''
        str << "Name: #{self.gem.name}\n"
        str << "Version: #{self.gem.version}\n"
        str << "Advisory: #{self.advisory.cve ? "CVE-#{advisory.cve}" : advisory.osvdb}\n"
        str << "Criticality: "

        str << case self.advisory.criticality
        when :low    then "Low"
        when :medium then "Medium"
        when :high   then "High"
        else              "Unknown"
        end
        str << "\n"

        str << "URL: #{self.advisory.url}\n"

        if verbose
          str << "Description: \n #{self.advisory.description}\n"
        else
          str << "Title: #{self.advisory.title}\n"
        end

        unless self.advisory.patched_versions.empty?
          str << "Solution: upgrade to \n"
          str << self.advisory.patched_versions.join(', ') + "\n"
        else
          str << "Solution: remove or disable this gem until a patch is available!"
        end

        str
      end
    end
  end
end

