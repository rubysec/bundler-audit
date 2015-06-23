#
# Copyright (c) 2013-2015 Hal Brodigan (postmodern.mod3 at gmail.com)
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
# along with bundler-audit.  If not, see <http://www.gnu.org/licenses/>.
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

      # Git URL of the ruby-advisory-db
      URL = 'https://github.com/rubysec/ruby-advisory-db.git'

      # Default path to the ruby-advisory-db
      VENDORED_PATH =  File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','data','ruby-advisory-db'))

      # Timestamp for when the database was last updated
      VENDORED_TIMESTAMP = Time.parse(File.read("#{VENDORED_PATH}.ts")).utc

      # Path to the user's copy of the ruby-advisory-db
      USER_PATH = File.expand_path(File.join(ENV['HOME'],'.local','share','ruby-advisory-db'))

      # The path to the advisory database
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
        if File.directory?(USER_PATH)
          t1 = Dir.chdir(USER_PATH) { Time.parse(`git log --date=iso8601 --pretty="%cd" -1`) }
          t2 = VENDORED_TIMESTAMP

          if t1 >= t2 then USER_PATH
          else             VENDORED_PATH
          end
        else
          VENDORED_PATH
        end
      end

      #
      # Updates the ruby-advisory-db.
      #
      # @return [Boolean]
      #   Specifies whether the update was successful.
      #
      # @note
      #   Requires network access.
      #
      # @since 0.3.0
      #
      def self.update!
        if File.directory?(USER_PATH)
          Dir.chdir(USER_PATH) do
            system 'git', 'pull', 'origin', 'master'
          end
        else
          system 'git', 'clone', URL, USER_PATH
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
