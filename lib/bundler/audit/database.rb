#
# Copyright (c) 2013-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'bundler/audit/advisory'

require 'time'
require 'yaml'

module Bundler
  module Audit
    #
    # Represents the directory of advisories, grouped by gem name
    # and CVE number.
    #
    class Database

      #
      # @since 0.10.0
      #
      class GitNotInstalled < RuntimeError
      end

      class DownloadFailed < RuntimeError
      end

      class UpdateFailed < RuntimeError
      end

      # Git URL of the ruby-advisory-db.
      URL = 'https://github.com/rubysec/ruby-advisory-db.git'

      # Path to the user's copy of the ruby-advisory-db.
      USER_PATH = File.expand_path(File.join(Gem.user_home,'.local','share','ruby-advisory-db'))

      # Default path to the ruby-advisory-db.
      #
      # @since 0.8.0
      DEFAULT_PATH = ENV.fetch('BUNDLER_AUDIT_DB',USER_PATH)

      # The path to the advisory database.
      #
      # @return [String]
      attr_reader :path

      #
      # Initializes the Advisory Database.
      #
      # @param [String] path
      #   The path to the advisory database.
      #
      # @raise [ArgumentError]
      #   The path was not a directory.
      #
      def initialize(path=self.class.path)
        unless File.directory?(path)
          raise(ArgumentError,"#{path.dump} is not a directory")
        end

        @path = path
      end

      #
      # The default path for the database.
      #
      # @return [String]
      #   The path to the database directory.
      #
      def self.path
        DEFAULT_PATH
      end

      #
      # Tests whether the database exists.
      #
      # @param [String] path
      #   The given path of the database to check.
      #
      # @return [Boolean]
      #
      # @since 0.8.0
      #
      def self.exists?(path=DEFAULT_PATH)
        File.directory?(path) && !(Dir.entries(path) - %w[. ..]).empty?
      end

      #
      # Downloads the ruby-advisory-db.
      #
      # @param [String] path
      #   The destination path for the new ruby-advisory-db.
      #
      # @param [Boolean] quiet
      #   Specify whether `git` should be `--quiet`.
      #
      # @return [Dataase]
      #   The newly downloaded database.
      #
      # @raise [DownloadFailed, GitNotInstalled]
      #   * {DownloadFailed} - the `git clone` command failed.
      #   * {GitNotInstalled} - the `git` command is not installed.
      #
      # @note
      #   Requires network access.
      #
      # @since 0.8.0
      #
      def self.download(path: DEFAULT_PATH, quiet: false)
        command = %w[git clone]
        command << '--quiet' if quiet
        command << URL << path

        case system(*command)
        when false
          raise(DownloadFailed,"failed to download #{URL} to #{path.inspect}")
        when nil
          raise(GitNotInstalled,"the git command is not installed")
        end

        return new(path)
      end

      #
      # Updates the ruby-advisory-db.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional optional keyword arguments for {download} or {#update!}.
      #
      # @option kwargs [Boolean] :quiet
      #   Specify whether `git` should be `--quiet`.
      #
      # @return [Boolean]
      #   Specifies whether the update was successful.
      #
      # @note
      #   Requires network access.
      #
      # @since 0.3.0
      #
      # @deprecated Use {#update!} instead.
      #
      def self.update!(**kwargs)
        if File.directory?(DEFAULT_PATH)
          begin
            new(DEFAULT_PATH).update!(**kwargs)
          rescue UpdateFailed then false
          end
        else
          begin
            download(**kwargs, path: DEFAULT_PATH)
          rescue DownloadFailed then false
          end
        end
      end

      #
      # Determines if the database is a git repository.
      #
      # @return [Boolean]
      #
      # @since 0.8.0
      #
      def git?
        File.directory?(File.join(@path,'.git'))
      end

      #
      # Updates the ruby-advisory-db.
      #
      # @param [Boolean] quiet
      #   Specify whether `git` should be `--quiet`.
      #
      # @return [true, nil]
      #   * `true` - the ruby-advisory-db git repository was successfully
      #     updated.
      #   * `nil` - the ruby-advisory-db is not a git repository or the `git`
      #     command is not installed.
      #
      # @raise [UpdateFailed]
      #   Could not update the ruby-advisory-db git repository.
      #
      # @raise [UpdateFailed, GitNotInstalled]
      #   * {UpdateFailed} - the `git pull` command failed.
      #   * {GitNotInstalled} - the `git` command is not installed.
      #
      # @since 0.8.0
      #
      def update!(quiet: false)
        if git?
          Dir.chdir(@path) do
            command = %w[git pull]
            command << '--quiet' if quiet
            command << 'origin' << 'master'

            case system(*command)
            when false
              raise(UpdateFailed,"failed to update #{@path.inspect}")
            when nil
              raise(GitNotInstalled,"the git command is not installed")
            end

            return true
          end
        end
      end

      #
      # The last commit ID of the repository.
      #
      # @return [String, nil]
      #   The commit hash or `nil` if the database is not a git repository.
      #
      # @raise [GitNotInstalled]
      #   The `git` command is not installed.
      #
      # @since 0.9.0
      #
      def commit_id
        if git?
          Dir.chdir(@path) do
            `git rev-parse HEAD`.chomp
          rescue Errno::ENOENT
            raise(GitNotInstalled,"the git command is not installed")
          end
        end
      end

      #
      # Determines the time when the database was last updated.
      #
      # @return [Time]
      #
      # @raise [GitNotInstalled]
      #   The `git` command is not installed.
      #
      # @since 0.8.0
      #
      def last_updated_at
        if git?
          Dir.chdir(@path) do
            Time.parse(`git log --date=iso8601 --pretty="%cd" -1`)
          rescue Errno::ENOENT
            raise(GitNotInstalled,"the git command is not installed")
          end
        else
          File.mtime(@path)
        end
      end

      #
      # Enumerates over every advisory in the database.
      #
      # @yield [advisory]
      #   If a block is given, it will be passed each advisory.
      #
      # @yieldparam [Advisory] advisory
      #   An advisory from the database.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def advisories(&block)
        return enum_for(__method__) unless block_given?

        each_advisory_path do |path|
          yield Advisory.load(path)
        end
      end

      #
      # Enumerates over advisories for the given gem.
      #
      # @param [String] name
      #   The gem name to lookup.
      #
      # @yield [advisory]
      #   If a block is given, each advisory for the given gem will be yielded.
      #
      # @yieldparam [Advisory] advisory
      #   An advisory for the given gem.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def advisories_for(name)
        return enum_for(__method__,name) unless block_given?

        each_advisory_path_for(name) do |path|
          yield Advisory.load(path)
        end
      end

      #
      # Verifies whether the gem is effected by any advisories.
      #
      # @param [Gem::Specification] gem
      #   The gem to verify.
      #
      # @yield [advisory]
      #   If a block is given, it will be passed advisories that effect
      #   the gem.
      #
      # @yieldparam [Advisory] advisory
      #   An advisory that effects the specific version of the gem.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def check_gem(gem)
        return enum_for(__method__,gem) unless block_given?

        advisories_for(gem.name) do |advisory|
          if advisory.vulnerable?(gem.version)
            yield advisory
          end
        end
      end

      #
      # The number of advisories within the database.
      #
      # @return [Integer]
      #   The number of advisories.
      #
      def size
        each_advisory_path.count
      end

      #
      # Converts the database to a String.
      #
      # @return [String]
      #   The path to the database.
      #
      def to_s
        @path
      end

      #
      # Inspects the database.
      #
      # @return [String]
      #   The inspected database.
      #
      def inspect
        "#<#{self.class}:#{self}>"
      end

      protected

      #
      # Enumerates over every advisory path in the database.
      #
      # @yield [path]
      #   The given block will be passed each advisory path.
      #
      # @yieldparam [String] path
      #   A path to an advisory `.yml` file.
      #
      def each_advisory_path(&block)
        Dir.glob(File.join(@path,'gems','*','*.yml'),&block)
      end

      #
      # Enumerates over the advisories for the given gem.
      #
      # @param [String] name
      #   The gem of the gem.
      #
      # @yield [path]
      #   The given block will be passed each advisory path.
      #
      # @yieldparam [String] path
      #   A path to an advisory `.yml` file.
      #
      def each_advisory_path_for(name,&block)
        Dir.glob(File.join(@path,'gems',name,'*.yml'),&block)
      end

    end
  end
end
