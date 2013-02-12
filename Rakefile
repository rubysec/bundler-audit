require "bundler/setup"
require "rubygems/tasks"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

namespace :spec do
  task :validate do
    validate = lambda do |path,data,field,type|
      value = data[field]

      case value
      when type
        # no-op
      when NilClass
        warn "#{path}: #{field} is missing"
      else
        warn "#{path}: expected #{field} to be #{type} but was #{value.class}"
      end
    end

    Dir.glob('data/bundler/audit/*/*.yml') do |path|
      begin
        data = YAML.load_file(path)

        validate[path, data, 'url', String]
        validate[path, data, 'title', String]
        validate[path, data, 'description', String]
        validate[path, data, 'cvss_v2', Float]
        validate[path, data, 'patched_versions', Array]
      rescue ArgumentError => error
        warn "#{path}: #{error.message}"
      end
    end
  end
end
task :spec => 'spec:validate'

task :test    => :spec
task :default => [:bundle_fixtures, :spec]
task :bundle_fixtures do
  sh "cd spec/bundle && bundle"
end

require "yard"
YARD::Rake::YardocTask.new
task :doc => :yard
