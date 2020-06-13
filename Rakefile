# encoding: utf-8

require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  abort e.message
end

require 'rake'
require 'time'

require 'rubygems/tasks'
Gem::Tasks.new

directory 'data/ruby-advisory-db' do
  sh 'git', 'submodule', 'update', '--init'
end

namespace :db do
  desc 'Updates data/ruby-advisory-db'
  task :update => 'data/ruuby-advsisory-db' do
    timestamp = nil

    chdir 'data/ruby-advisory-db' do
      sh 'git', 'pull', 'origin', 'master'

      File.open('../ruby-advisory-db.ts','w') do |file|
        file.write Time.parse(`git log --date=iso8601 --pretty="%cd" -1`).utc
      end
    end

    sh 'git', 'commit', 'data/ruby-advisory-db',
                        'data/ruby-advisory-db.ts',
                        '-m', 'Updated ruby-advisory-db'
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

%w[secure unpatched_gems insecure_sources].each do |bundle|
  bundle_dir   = File.join('spec/bundle',bundle)
  gemfile      = File.join(bundle_dir,'Gemfile')
  gemfile_lock = File.join(bundle_dir,'Gemfile.lock')

  file gemfile_lock => gemfile do
    chdir(bundle_dir) do
      sh 'unset BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT && bundle install --path ../../../vendor/bundle'
    end
  end

  desc "Generates the spec/bundler/*/Gemfile.lock files"
  task 'spec:bundle' => gemfile_lock
end

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new  
task :doc => :yard
