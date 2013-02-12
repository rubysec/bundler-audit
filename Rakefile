# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  gem 'rubygems-tasks', '~> 0.2'
  require 'rubygems/tasks'

  Gem::Tasks.new
rescue LoadError => e
  warn e.message
  warn "Run `gem install rubygems-tasks` to install Gem::Tasks."
end

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end

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
task :default => :spec

begin
  gem 'yard', '~> 0.8'
  require 'yard'

  YARD::Rake::YardocTask.new  
rescue LoadError => e
  task :yard do
    abort "Please run `gem install yard` to install YARD."
  end
end
task :doc => :yard
