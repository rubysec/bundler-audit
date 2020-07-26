require 'yaml'

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

      class << self
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
        def from_yaml_file(file_path)
          raise(FileNotFound, "Configuration file '#{file_path}' does not exist") unless File.exist?(file_path)

          doc = YAML.parse(File.new(file_path))

          unless doc.root.kind_of?(YAML::Nodes::Mapping)
            raise InvalidConfigurationError, "Configuration found in '#{file_path}' is not a Hash"
          end

          config = Hash[doc.root.children.each_slice(2).map do |key, value|
            [key.value, value]
          end]

          new(
            'ignore' => parse_ignore_list_from_yaml_doc(config['ignore'])
          )
        end

        #
        # A constructor method for creating an empty configuration object.
        #
        # @return [Configuration]
        #   A Configuration object containing an empty config hash.
        #
        def empty
          new({})
        end

        private

        #
        # Validates and parses out the ignore list from a YAML doc.
        #
        # @param [YAML::Nodes::Sequence<YAML::Nodes::Scalar>]
        #   A YAML doc representation of an Array of Strings.
        #
        # @raise [InvalidConfigurationError]
        #   Will raise an invalid configuration error indicating what in the
        #   ignore list is invalid for the configuration.
        #
        def parse_ignore_list_from_yaml_doc(ignore_list)
          if ignore_list
            unless ignore_list.is_a?(YAML::Nodes::Sequence)
              raise InvalidConfigurationError, "Ignore key found in config file, but is not an Array"
            end

            unless ignore_list.children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
              raise InvalidConfigurationError, "Ignore array in config file contains a non-String"
            end

            ignore_list.children.map { |cve| cve.value }
          end
        end
      end

      attr_reader :config

      #
      # Initializes the configuration.
      #
      # @params [Hash] config
      #   The configuration hash.
      #
      # @raise [InvalidConfigurationError]
      #   Will raise an invalid configuration error indicating what in the YAML
      #   file is invalid for the configuration.
      #
      def initialize(config)
        @config = config
        validate_ignore! if config['ignore']
      end

      #
      # Accessor method for accessing the ignore configuration, allows the
      # passing of an override array provided by the CLI.
      #
      # If overrides are provided, this method will return the overrides if they
      # are valid, and print a warning if they are not before returning the
      # ignore array stored in the config hash.
      #
      # @param [Array<String>] optional
      #   Overrides array of CVEs to ignore. This array will be validated and
      #   returned instead of the array stored in the config hash.
      #
      # @return [Array<String>]
      #   An array of CVE strings.
      #
      def ignore(overrides = [])
        overrides_array = Array(overrides)

        is_valid_override = ignore_is_valid?(overrides_array)

        warn 'Invalid --ignore value provided' unless is_valid_override

        if overrides_array&.any? && is_valid_override
          overrides_array
        else
          config['ignore'] || []
        end
      end

      private

      #
      # Valid or raise method for the ignore configuration.
      #
      # @raise [InvalidConfigurationError]
      #   Will raise an invalid configuration error indicating what in the YAML
      #   file is invalid for the configuration.
      #
      def validate_ignore!
        unless ignore_is_valid?(config['ignore'])
          raise InvalidConfigurationError, 'Invalid CVE ignore list found in configuration. Must be an array of CVE codes.'
        end
      end

      #
      # Method for indicating that a given ignore configuration is valid.
      #
      # @param [Array<String>] ignore_config
      #   The ignore value to be validated.
      #
      # @return [boolean]
      #
      def ignore_is_valid?(ignore_config)
        ignore_config.is_a?(Array) && ignore_config.all? { |cve| cve.is_a?(String) }
      end
    end
  end
end
