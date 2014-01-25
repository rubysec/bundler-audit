require 'rake'
require 'rake/tasklib'
require 'bundler/audit/scanner'
require 'bundler/audit/cli'

module Bundler
  module Audit
    class Task < ::Rake::TaskLib
      attr_accessor :name
      attr_accessor :options
      attr_accessor :block
      attr_accessor :verbose
      attr_accessor :ignore

      def initialize(*args, &block)
        @options = args || []
        @block = block if block
        @verbose = false

        define
      end

      protected
      def define
        desc "Run Bundler-audit" unless ::Rake.application.last_comment
        @name = options.shift || :audit

        task @name, *options do |_, task_args|
          RakeFileUtils.send(:verbose, @verbose) do
            block.call(self) if block
            run
          end
        end
      end

      def run
        t = ['check']
        t << '-v' if verbose
        t << '-i' << ignore if ignore
        Bundler::Audit::CLI.start t
      end

    end
  end
end
