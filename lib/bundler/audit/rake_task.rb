require 'rake'
require 'rake/tasklib'

module Bundler
  module Audit
    class RakeTask < ::Rake::TaskLib
      attr_accessor :name
      attr_accessor :verbose
      attr_accessor :ignore

      def initialize(*args, &block)
        desc "Run Bundler-audit" unless ::Rake.application.last_comment
        @name = args.shift || :audit
        @verbose = false

        task @name, *args do |_, task_args|
          RakeFileUtils.send(:verbose, @verbose) do
            block.call(self) if block_given?
            run @verbose
          end
        end
      end

      def run verbose
        cmd = command
        output.puts cmd if verbose

        result = system(cmd) rescue failed = true

        if failed or !result
          output.puts result
          $stderr.puts "#{cmd} failed"
          exit $?.exitstatus
        end
      end

      def command
        cmd_parts = []
        cmd_parts << RUBY
        cmd_parts << "-S" << 'bundle-audit'
        cmd_parts << 'check'
        (cmd_parts << "-v") if verbose
        (cmd_parts << "-i" << ignore) if ignore
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def blank
        lambda {|s| s.nil? || s == ""}
      end

      def output
        $stdout
      end

    end
  end
end
