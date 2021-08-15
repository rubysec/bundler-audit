require 'rake/tasklib'

module Bundler
  module Audit
    #
    # Defines the `bundle:audit` rake tasks.
    #
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
              system 'bundler-audit', 'check'
            end

            desc 'Updates the bundler-audit vulnerability database'
            task :update do
              system 'bundler-audit', 'update'
            end
          end

          task :audit => 'audit:check'
        end

        task 'bundler:audit'        => 'bundle:audit'
        task 'bundler:audit:check'  => 'bundle:audit:check'
        task 'bundler:audit:update' => 'bundle:audit:update'
      end
    end
  end
end
