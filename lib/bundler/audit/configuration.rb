require 'yaml'

module Bundler
  module Audit
    # Class for storing and validating configuration for running the auditor
    #
    # @since 0.8.0
    # @attr_reader [config] The full configuration hash
    class Configuration
      class InvalidConfigurationError < StandardError; end
      class FileNotFound < StandardError; end

      class << self
        # A constructor method for loading configuration from a YAML file
        #
        # @param [String] path to the yaml file holding the configuration
        #
        # @raise [FileNotFound] will raise a file not found error when the path
        # to the configuration YAML file does not exist
        #
        # @raise [InvalidConfigurationError] will raise an invalid configuration error
        # indicating what in the YAML file is invalid for the configuration
        #
        # @return [Configuration] a Configuration object containing the config hash
        # loaded from the file passed
        def from_yaml_file(file_path)
          raise(FileNotFound, "Configuration file '#{file_path}' does not exist") unless File.exist?(file_path)
          new(YAML.load(File.read(file_path)))
        end

        # A constructor method for creating an empty configuration object
        #
        # @return [Configuration] a Configuration object containing an empty config hash
        def empty
          new({})
        end
      end

      attr_reader :config

      # @params [Hash] The configuration hash
      #
      # @raise [InvalidConfigurationError] will raise an invalid configuration error
      # indicating what in the YAML file is invalid for the configuration
      def initialize(config)
        @config = config
        validate_ignore! if config['ignore']
      end

      # Accessor method for accessing the ignore configuration, allows the passing
      # of an override array provided by the CLI
      #
      # If overrides are provided, this method will return the overrides if they are
      # valid, and print a warning if they are not before returning the ignore array
      # stored in the config hash
      #
      # @param [Array<String>] (optional) overrides array of CVEs to ignore. This array
      # will be validated and returned instead of the array stored in the config hash
      #
      # @return [Array<String>] An array of CVE strings
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

      # Valid or raise method for the ignore configuration
      #
      # @raise [InvalidConfigurationError] will raise an invalid configuration error
      # indicating what in the YAML file is invalid for the configuration
      def validate_ignore!
        unless ignore_is_valid?(config['ignore'])
          raise InvalidConfigurationError, 'Invalid CVE ignore list found in configuration. Must be an array of CVE codes.'
        end
      end

      # Method for indicating that a given ignore configuration is valid
      #
      # @param [Array<String>] ignore config that you would like to validate
      #
      # @return [boolean]
      def ignore_is_valid?(ignore_config)
        ignore_config.is_a?(Array) && ignore_config.all? { |cve| cve.is_a?(String) }
      end
    end
  end
end
