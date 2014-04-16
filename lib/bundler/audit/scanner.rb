require 'bundler'
require 'bundler/audit/database'
require 'bundler/lockfile_parser'

require 'set'

module Bundler
  module Audit
    class Scanner

      # Represents a plain-text source
      InsecureSource = Struct.new(:source)

      # Represents a gem that is covered by an Advisory
      UnpatchedGem = Struct.new(:gem, :advisory) do
        alias_method :rubygem, :gem
      end

      # The advisory database
      #
      # @return [Database]
      attr_reader :database

      # Project root directory
      attr_reader :root

      # The parsed `Gemfile.lock` from the project
      #
      # @return [Bundler::LockfileParser]
      attr_reader :lockfile

      #
      # Initializes a scanner.
      #
      # @param [String, #read] path_io
      #   The path to a directory with a Gemfile.lock, or an IO representation of Gemfile.lock
      #
      def initialize(path_io=Dir.pwd)
        @database = Database.new
        @lockfile = if path_io.respond_to?(:read)
                      @root = nil
                      LockfileParser.new(path_io.read)
                    else
                      @root = path_io
                      LockfileParser.new File.read(File.join(@root,'Gemfile.lock'))
                    end
      end

      #
      # Scans the project for issues.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Array<String>] :ignore
      #   The advisories to ignore.
      #
      # @yield [result]
      #   The given block will be passed the results of the scan.
      #
      # @yieldparam [InsecureSource, UnpatchedGem] result
      #   A result from the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def scan(options={})
        return enum_for(__method__,options) unless block_given?

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        @lockfile.sources.map do |source|
          case source
          when Source::Git
            case source.uri
            when /^git:/, /^http:/
              yield InsecureSource.new(source.uri)
            end
          when Source::Rubygems
            source.remotes.each do |uri|
              if uri.scheme == 'http'
                yield InsecureSource.new(uri.to_s)
              end
            end
          end
        end

        @lockfile.specs.each do |gem|
          @database.check_gem(gem) do |advisory|
            unless ignore.include?(advisory.id)
              yield UnpatchedGem.new(gem,advisory)
            end
          end
        end

        return self
      end

    end
  end
end
