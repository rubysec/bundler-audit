require 'bundler'
require 'bundler/audit/database'
require 'bundler/lockfile_parser'

require 'ipaddr'
require 'resolv'
require 'set'
require 'uri'

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
      def scan(options={},&block)
        return enum_for(__method__,options) unless block

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        scan_sources(options,&block)
        scan_specs(options,&block)

        return self
      end

      #
      # Scans the gem sources in the lockfile.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @yield [result]
      #   The given block will be passed the results of the scan.
      #
      # @yieldparam [InsecureSource] result
      #   A result from the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      # @api semipublic
      #
      # @since 0.4.0
      #
      def scan_sources(options={})
        return enum_for(__method__,options) unless block_given?

        @lockfile.sources.map do |source|
          case source
          when Source::Git
            case source.uri
            when /^git:/, /^http:/
              unless internal_source?(source.uri)
                yield InsecureSource.new(source.uri)
              end
            end
          when Source::Rubygems
            source.remotes.each do |uri|
              if (uri.scheme == 'http' && !internal_source?(uri))
                yield InsecureSource.new(uri.to_s)
              end
            end
          end
        end
      end

      #
      # Scans the gem sources in the lockfile.
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
      # @yieldparam [UnpatchedGem] result
      #   A result from the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      # @api semipublic
      #
      # @since 0.4.0
      #
      def scan_specs(options={})
        return enum_for(__method__,options) unless block_given?

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        @lockfile.specs.each do |gem|
          @database.check_gem(gem) do |advisory|
            unless (ignore.include?(advisory.cve_id) ||
                    ignore.include?(advisory.osvdb_id))
              yield UnpatchedGem.new(gem,advisory)
            end
          end
        end
      end

      private

      #
      # Determines whether a source is internal.
      #
      # @param [URI, String] uri
      #   The URI.
      #
      # @return [Boolean]
      #
      def internal_source?(uri)
        uri = URI(uri)

        internal_host?(uri.host) if uri.host
      end

      #
      # Determines whether a host is internal.
      #
      # @param [String] host
      #   The hostname.
      #
      # @return [Boolean]
      #
      def internal_host?(host)
        Resolv.getaddresses(host).all? { |ip| internal_ip?(ip) }
      rescue URI::Error
        false
      end

      # List of internal IP address ranges.
      #
      # @see https://tools.ietf.org/html/rfc1918#section-3
      # @see https://tools.ietf.org/html/rfc4193#section-8
      INTERNAL_SUBNETS = %w[
        10.0.0.0/8
        172.16.0.0/12
        192.168.0.0/16
        fc00::/7
      ].map(&IPAddr.method(:new))

      #
      # Determines whether an IP is internal.
      #
      # @param [String] ip
      #   The IPv4/IPv6 address.
      #
      # @return [Boolean]
      #
      def internal_ip?(ip)
        INTERNAL_SUBNETS.any? { |subnet| subnet.include?(ip) }
      end
    end
  end
end
