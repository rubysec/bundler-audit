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
          desc 'Checks the Gemfile.lock for insecure dependencies'
          task :audit do
            require 'bundler/audit/cli'
            Bundler::Audit::CLI.start %w[check]
          end

          namespace :audit do
            desc 'Updates the bundler-audit vulnerability database'
            task :update do
              require 'bundler/audit/cli'
              Bundler::Audit::CLI.start %w[update]
            end
          end
        end
      end
    end
  end
end
