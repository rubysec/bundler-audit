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

desc 'Updates data/ruby-advisory-db'
task :update do
  chdir 'data/ruby-advisory-db' do
    sh 'git', 'pull', 'origin', 'master'
  end

  sh 'git', 'commit', 'data/ruby-advisory-db', '-m', 'Updated ruby-advisory-db'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

namespace :spec do
  task :bundle do
    root = 'spec/bundle'

    %w[secure unpatched_gems insecure_sources].each do |bundle|
      chdir(File.join(root,bundle)) do
        begin
          sh 'BUNDLE_BIN_PATH="" BUNDLE_GEMFILE="" RUBYOPT="" bundle install --path ../../../vendor/bundle'
        rescue
          if(File.exist?("Gemfile.lock"))
            puts "Looks like Gemfile may have been updated.  Attempting to update things."
            sh 'BUNDLE_BIN_PATH="" BUNDLE_GEMFILE="" RUBYOPT="" bundle update'
          end
        end
      end
    end
  end
end
task :spec => 'spec:bundle'

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new  
task :doc => :yard
