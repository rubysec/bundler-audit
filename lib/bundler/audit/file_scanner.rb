require 'bundler/audit/scanner'

module Bundler
  module Audit
    class FileScanner < Scanner

      # Project root directory
      attr_reader :root

      #
      # Initializes a file scanner.
      #
      # @param [String] root
      #   The path to the project root.
      #
      # @param [String] gemfile_lock
      #   Alternative name for the `Gemfile.lock` file.
      #
      def initialize(root=Dir.pwd,gemfile_lock='Gemfile.lock')
        @root = File.expand_path(root)
        super(LockfileParser.new(File.read(File.join(@root,gemfile_lock))))
      end
    end
  end
end

