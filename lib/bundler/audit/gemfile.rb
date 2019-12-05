require 'set'

module Bundler
  module Audit
    class Gemfile
      def initialize(env)
        @env = env
      end

      def groups
        groups = Set.new
        @env.current_dependencies.each do |dependency|
          groups += dependency.groups
        end
        groups.to_a
      end

      def dependencies_for(groups)
        groups.map!(&:to_sym)
        dependencies = Set.new
        parent_dependencies = @env.current_dependencies.select { |dep| (dep.groups & groups).any? }

        while parent_dependencies.any?
          tmp = Set.new
          parent_dependencies.each do |dependency|
            dependencies << dependency
            child_dependencies = spec_for_dependency(dependency).runtime_dependencies.to_set
            tmp += child_dependencies
          end
          parent_dependencies = tmp
        end
        dependencies.to_a
      end

      private

      def spec_for_dependency(dependency)
        @env.requested_specs.find { |spec| spec.name == dependency.name }
      end
    end
  end
end
