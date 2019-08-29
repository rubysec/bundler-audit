# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/audit/version'

Gem::Specification.new do |s|
  s.name    = 'bundler-audit'
  s.version = Bundler::Audit::VERSION
  s.authors     = ['Postmodern']
  s.email       = ['postmodern.mod3@gmail.com']
  s.summary     = 'Patch-level verification for Bundler'
  s.description = 'bundler-audit provides patch-level verification for Bundled apps.'
  s.homepage    = 'https://github.com/rubysec/bundler-audit#readme'
  s.license    = 'GPL-3.0+'

  s.files = `git ls-files`.split($/)

  # add paths from data/ruby-advisory-db/
  s.files += Dir.chdir('data/ruby-advisory-db') do
    `git ls-files`.split($/).map do |sub_path|
      File.join('data', 'ruby-advisory-db', sub_path)
    end
  end

  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files       = s.files.grep(%r{^(test|spec|features)/})
  s.extra_rdoc_files = Dir['*.{txt,md}']
  s.require_paths = ['lib']

  s.required_ruby_version     = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.8.0'

  s.add_dependency('thor', '~> 0.18')
  s.add_dependency('bundler', '>= 1.2.0', '< 3')
end
