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
      # Defines the `bundle:audit` and `bundle:audit:update` task.
      #
      def define
        namespace :bundle do
          namespace :audit do
            desc 'Checks the Gemfile.lock for insecure dependencies'
            task :check do
              require 'bundler/audit/cli'
              Bundler::Audit::CLI.start %w[check]
            end

            desc 'Updates the bundler-audit vulnerability database'
            task :update do
              require 'bundler/audit/cli'
              Bundler::Audit::CLI.start %w[update]
            end
          end

          task :audit => 'audit:check'
        end
      end
    end
  end
end
