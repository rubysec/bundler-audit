require 'bundler/audit/database'

require 'bundler'
require 'bundler/lockfile_parser'

module Bundler
  module Audit
    class Scanner

      # Represents a gem that is covered by an Advisory
      UnpatchedGem = Struct.new(:gem, :advisory)

      # The advisory database
      #
      # @return [Database]
      attr_reader :database

      # The parsed `Gemfile.lock` from the project
      #
      # @return [Bundler::LockfileParser]
      attr_reader :lockfile

      #
      # Initializes a scanner.
      #
      def initialize
        @database = Database.new
        @lockfile = LockfileParser.new(File.read('Gemfile.lock'))
      end

      #
      # Scans the project for issues.
      #
      # @yield [result]
      #   The given block will be passed the results of the scan.
      #
      # @yieldparam [UnpatchedGem] result
      #   A result from the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def scan
        return enum_for(__method__) unless block_given?

        @lockfile.specs.each do |gem|
          @database.check_gem(gem) do |advisory|
            yield UnpatchedGem.new(gem,advisory)
          end
        end

        return self
      end

    end
  end
end
