require 'yaml'

module Bundler
  module Audit
    class Configuration
      class InvalidConfigurationError < StandardError; end

      class << self
        def from_yaml_file(file_path)
          raise "Configuration file '#{file_path}' does not exist" unless File.exist?(file_path)
          new(YAML.load(File.read(file_path)))
        end

        def empty
          new({})
        end
      end

      attr_reader :config

      def initialize(config)
        @config = config
        validate_ignore_is_array_of_strings! if config['ignore']
      end

      def ignore(overrides = [])
        overrides_array = Array(overrides)

        is_valid_override = is_valid_ignore_config?(overrides_array)

        warn 'Invalid --ignore value provided' unless is_valid_override

        if overrides_array&.any? && is_valid_override
          overrides_array
        else
          config['ignore'] || []
        end
      end

      private

      def validate_ignore_is_array_of_strings!
        unless is_valid_ignore_config?(config['ignore'])
          raise InvalidConfigurationError, 'Invalid CVE ignore list found in configuration. Must be an array of CVE codes.'
        end
      end

      def is_valid_ignore_config?(ignore_config)
        ignore_config.is_a?(Array) && ignore_config.all? { |cve| cve.is_a?(String) }
      end
    end
  end
end
