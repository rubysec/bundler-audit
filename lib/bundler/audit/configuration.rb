require 'yaml'
require 'set'

module Bundler
  module Audit
    #
    # Class for storing and validating configuration for running the auditor.
    #
    # @since 0.8.0
    #
    class Configuration
      class InvalidConfigurationError < StandardError; end
      class FileNotFound < StandardError; end

      #
      # A constructor method for loading configuration from a YAML file.
      #
      # @param [String] path
      #   Path to the yaml file holding the configuration.
      #
      # @raise [FileNotFound]
      #   Will raise a file not found error when the path to the
      #   configuration YAML file does not exist.
      #
      # @raise [InvalidConfigurationError]
      #   Will raise an invalid configuration error indicating what in the
      #   YAML file is invalid for the configuration.
      #
      # @return [Configuration]
      #   A Configuration object containing the config hash loaded from the
      #   file passed.
      #
      def self.load(file_path)
        raise(FileNotFound,"Configuration file '#{file_path}' does not exist") unless File.exist?(file_path)

        doc = YAML.parse(File.new(file_path))

        unless doc.root.kind_of?(YAML::Nodes::Mapping)
          raise(InvalidConfigurationError,"Configuration found in '#{file_path}' is not a Hash")
        end

        config = {}

        doc.root.children.each_slice(2) do |key,value|
          case key.value
          when 'ignore'
            unless value.is_a?(YAML::Nodes::Sequence)
              raise(InvalidConfigurationError,"'ignore' key found in config file, but is not an Array")
            end

            unless value.children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
              raise(InvalidConfigurationError,"'ignore' array in config file contains a non-String")
            end

            config[:ignore] = value.children.map(&:value)
          end
        end

        new(config)
      end

      #
      # The list of advisory IDs to ignore.
      #
      # @return [Set<String>]
      #
      attr_reader :ignore

      #
      # Initializes the configuration.
      #
      # @params [Hash] config
      #   The configuration hash.
      #
      # @option config [Array<String>] :ignore
      #   The list of advisory IDs to ignore.
      #
      # @raise [InvalidConfigurationError]
      #   Will raise an invalid configuration error indicating what in the YAML
      #   file is invalid for the configuration.
      #
      def initialize(config={})
        @ignore = Set.new(config[:ignore])
      end

    end
  end
end
