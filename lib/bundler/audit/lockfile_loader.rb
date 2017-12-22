# frozen_string_literal: true
module Bundler
  module Audit
    class LockfileLoader
      # The project path used to find the lockfile.
      #
      # @return [String]
      attr_reader :path

      # Initializes a scanner.
      #
      # @param [String] path
      #   The project path used to find the lockfile.
      def initialize(path)
        @path = path
      end

      # Seaches for the lockfile in the given path, and then returns its contents as a string.
      #
      # @return [String]
      #   The string contents of the lockfile
      def contents
        self.class.lockfile_names.each do |lockfile_name|
          filename = File.join(path, lockfile_name)
          return File.read(filename) if File.exist?(filename)
        end

        raise StandardError, "Cannot find a lockfile named #{self.class.lockfile_names} in #{path}"
      end

      # Returns the ordered list of lockfiles to search, depending on the version of Bundler.
      #
      # @return [Array]
      #   Possible lockfile names.
      def self.lockfile_names
        if Gem::Version.new(Bundler::VERSION) >= Gem::Version.new('1.8.0.pre'.freeze)
          ["gems.locked", "Gemfile.lock"].freeze
        else
          ["Gemfile.lock"].freeze
        end
      end
    end
  end
end

