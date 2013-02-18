# encoding: utf-8

require 'rubygems'

begin
  require 'bundler'
rescue LoadError => e
  warn e.message
  warn "Run `gem install bundler` to install Bundler."
  exit -1
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'

require 'rubygems/tasks'
Gem::Tasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

namespace :spec do
  task :bundle do
    %w[spec/bundle/vuln spec/bundle/secure].each do |path|
      chdir(path) { sh 'bundle', 'install', '--quiet' }
    end
  end

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
task :spec => ['spec:bundle', 'spec:validate']

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new  
task :doc => :yard
