require 'rake/tasklib'

module Bundler
  module Audit
    class Task < Rake::TaskLib
      #
      # Initializes the task.
      #
      def initialize
        define
      end

      protected

      #
      # Defines the `bundle:audit` task.
      #
      def define
        namespace :bundle do
          desc 'Updates the ruby-advisory-db then runs bundle-audit'
          task :audit do
            require 'bundler/audit/cli'
            Bundler::Audit::CLI.start %w[check]
          end
        end
      end
    end
  end
end
