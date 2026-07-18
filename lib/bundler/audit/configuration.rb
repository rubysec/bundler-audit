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
require 'date'
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

            config[:ignore] = value.children.map { |node| parse_ignore(node) }
          end
        end

        new(config)
      end

      #
      # Parses and validates an entry in the `ignore` array.
      #
      # @param [YAML::Nodes::Node] node
      #
      # @return [String, Hash]
      #
      # @api private
      #
      def self.parse_ignore(node)
        return node.value if node.is_a?(YAML::Nodes::Scalar)

        unless node.is_a?(YAML::Nodes::Mapping)
          raise(InvalidConfigurationError,"'ignore' array contains an invalid entry")
        end

        entry = {}

        node.children.each_slice(2) do |key,value|
          unless key.is_a?(YAML::Nodes::Scalar) && value.is_a?(YAML::Nodes::Scalar)
            raise(InvalidConfigurationError,"timed 'ignore' entries must contain String values")
          end

          case key.value
          when 'id'
            entry[:id] = value.value
          when 'until'
            entry[:until] = value.value
          else
            raise(InvalidConfigurationError,"unknown key #{key.value.inspect} in timed 'ignore' entry")
          end
        end

        unless entry[:id] && entry[:until]
          raise(InvalidConfigurationError,"timed 'ignore' entries require both 'id' and 'until'")
        end

        unless entry[:until] =~ /\A\d{4}-\d{2}-\d{2}\z/
          raise(InvalidConfigurationError,"'until' in timed 'ignore' entry must be an ISO 8601 date (YYYY-MM-DD)")
        end

        begin
          entry[:until] = Date.iso8601(entry[:until])
        rescue ArgumentError
          raise(InvalidConfigurationError,"'until' in timed 'ignore' entry must be a valid date")
        end

        entry
      end
      private_class_method :parse_ignore

      #
      # The set of advisory IDs which are currently ignored.
      #
      # @return [Set<String>]
      #
      def ignore
        ignored = @ignore.dup
        today   = Date.today

        @timed_ignores.each do |id,ignore_until|
          ignored << id if ignore_until >= today
        end

        ignored
      end

      #
      # Initializes the configuration.
      #
      # @param [Hash] config
      #   The configuration hash.
      #
      # @option config [Array<String, Hash>] :ignore
      #   The list of advisory IDs to ignore, optionally through a specific
      #   date.
      #
      def initialize(config={})
        @ignore        = Set.new
        @timed_ignores = {}

        Array(config[:ignore]).each do |entry|
          if entry.is_a?(Hash)
            @timed_ignores[entry[:id]] = entry[:until]
          else
            @ignore << entry
          end
        end
      end

    end
  end
end
