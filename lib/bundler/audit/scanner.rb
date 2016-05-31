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

      # Represent a Ruby or RubyGems version.
      class Version
        def initialize(name,version)
          @name = name
          @version = Gem::Version.new(version)
        end

        attr_reader :name, :version
      end

      # Represents a gem that is covered by an Advisory
      UnpatchedGem = Struct.new(:gem, :advisory)

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
      # @param [String] root
      #   The path to the project root.
      #
      def initialize(root=Dir.pwd)
        @root     = File.expand_path(root)
        @database = Database.new
        @lockfile = LockfileParser.new(
          File.read(File.join(@root,'Gemfile.lock'))
        )
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

        scan_ruby(options,&block)
        scan_rubygems(options,&block)
        scan_sources(options,&block)
        scan_specs(options,&block)

        return self
      end

      #
      # Scans the current Ruby version.
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
      # @since 0.5.0
      #
      def scan_ruby(options={},&block)
        if RUBY_PATCHLEVEL < 0
          version = ruby_version
        else
          version = "#{RUBY_VERSION}.#{RUBY_PATCHLEVEL}"
        end
        specs = [Version.new(RUBY_ENGINE,version)]
        scan_inner(specs,'ruby',options,&block)
      end

      #
      # Scans the current RubyGems version.
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
      # @since 0.5.0
      #
      def scan_rubygems(options={},&block)
        specs = [Version.new('rubygems',rubygems_version)]
        scan_inner(specs,'library',options,&block)
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
      def scan_specs(options={},&block)
        scan_inner(@lockfile.specs,'gem',options,&block)
      end

      private

      #
      # Checks the Ruby version.
      #
      # @return [String]
      #   The current Ruby version.
      #
      def ruby_version
        # .gsub to separate strings (e.g., 2.1.0dev -> 2.1.0.dev,
        # 2.2.0preview1 -> 2.2.0.preview.1).
        `ruby --version`.split[1]
          .gsub(/(\d)([a-z]+)/, '\1.\2')
          .gsub(/([a-z]+)(\d)/, '\1.\2')
      end

      #
      # Checks the RubyGems version.
      #
      # @return [String]
      #   The current RubyGems version.
      #
      def rubygems_version
        `gem --version`.strip
      end

      #
      # Scans the specified sources.
      #
      # @param [Array] specs
      #   An array of specifications (Ruby, RubyGems, or gems) to scan.
      #
      # @param [String] type
      #   The type of specification; one of gem, library, or ruby.
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
      # @since 0.5.0
      #
      def scan_inner(specs,type,options={})
        return enum_for(__method__,options) unless block_given?

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        specs.each do |spec|
          @database.send("check_#{type}".to_sym,spec) do |advisory|
            unless (ignore.include?(advisory.cve_id) ||
                    ignore.include?(advisory.osvdb_id))
              yield UnpatchedGem.new(spec,advisory)
            end
          end
        end
      end

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
