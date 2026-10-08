#
# Copyright (c) 2013-2026 Hal Brodigan (postmodern.mod3 at gmail.com)
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
      class InvalidConfigurationError < StandardError
      end

      class FileNotFound < StandardError
      end

      #
      # A constructor method for loading configuration from a YAML file.
      #
      # @param [String] file_path
      #   Path to the YAML file holding the configuration.
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

        unless doc.kind_of?(YAML::Nodes::Document)
          raise(InvalidConfigurationError,"Configuration found in '#{file_path}' is not YAML")
        end

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
          when 'exclude'
            unless value.is_a?(YAML::Nodes::Sequence)
              raise(InvalidConfigurationError,"'exclude' key found in config file, but is not an Array")
            end

            unless value.children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
              raise(InvalidConfigurationError,"'exclude' array in config file contains a non-String")
            end

            config[:exclude] = value.children.map(&:value)
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
      # The list of gem names to exclude from scanning.
      #
      # @return [Set<String>]
      #
      attr_reader :exclude

      #
      # Initializes the configuration.
      #
      # @param [Hash] config
      #   The configuration hash.
      #
      # @option config [Array<String>] :ignore
      #   The list of advisory IDs to ignore.
      #
      # @option config [Array<String>] :exclude
      #   The list of gem names to exclude from scanning.
      #
      def initialize(config={})
        @ignore  = Set.new(config[:ignore])
        @exclude = Set.new(config[:exclude])
      end

    end
  end
end
