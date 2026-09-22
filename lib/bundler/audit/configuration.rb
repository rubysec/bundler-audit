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
        load_with_chain(file_path,[])
      end

      #
      # Internal loader that tracks the ancestor chain of absolute paths in
      # order to detect cycles across `inherit_from:` links.
      #
      # @param [String] file_path
      #   Path to the YAML file holding the configuration.
      #
      # @param [Array<String>] ancestors
      #   Absolute paths of configuration files already being loaded further up
      #   the recursion. Used only to detect cycles.
      #
      # @raise [FileNotFound]
      # @raise [InvalidConfigurationError]
      #
      # @return [Configuration]
      #
      # @api private
      #
      def self.load_with_chain(file_path,ancestors)
        absolute_path = File.expand_path(file_path)

        if ancestors.include?(absolute_path)
          raise(InvalidConfigurationError,"Cycle detected in 'inherit_from': #{(ancestors + [absolute_path]).join(' -> ')}")
        end

        unless File.exist?(absolute_path)
          raise(FileNotFound,"Configuration file '#{file_path}' does not exist")
        end

        doc = YAML.parse(File.new(absolute_path))

        unless doc.kind_of?(YAML::Nodes::Document)
          raise(InvalidConfigurationError,"Configuration found in '#{file_path}' is not YAML")
        end

        unless doc.root.kind_of?(YAML::Nodes::Mapping)
          raise(InvalidConfigurationError,"Configuration found in '#{file_path}' is not a Hash")
        end

        config = { ignore: [] }

        doc.root.children.each_slice(2) do |key,value|
          case key.value
          when 'ignore'
            unless value.is_a?(YAML::Nodes::Sequence)
              raise(InvalidConfigurationError,"'ignore' key found in config file, but is not an Array")
            end

            unless value.children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
              raise(InvalidConfigurationError,"'ignore' array in config file contains a non-String")
            end

            config[:ignore].concat(value.children.map(&:value))
          when 'inherit_from'
            unless value.is_a?(YAML::Nodes::Sequence)
              raise(InvalidConfigurationError,"'inherit_from' key found in config file, but is not an Array")
            end

            unless value.children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
              raise(InvalidConfigurationError,"'inherit_from' array in config file contains a non-String")
            end

            base_dir = File.dirname(absolute_path)
            value.children.each do |child_node|
              inherited_path = File.expand_path(child_node.value,base_dir)
              parent_config  = load_with_chain(inherited_path,ancestors + [absolute_path])
              config[:ignore].concat(parent_config.ignore.to_a)
            end
          end
        end

        new(config)
      end
      private_class_method :load_with_chain

      #
      # The list of advisory IDs to ignore.
      #
      # @return [Set<String>]
      #
      attr_reader :ignore

      #
      # Initializes the configuration.
      #
      # @param [Hash] config
      #   The configuration hash.
      #
      # @option config [Array<String>] :ignore
      #   The list of advisory IDs to ignore.
      #
      def initialize(config={})
        @ignore = Set.new(config[:ignore])
      end

    end
  end
end
