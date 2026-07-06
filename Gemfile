source 'https://rubygems.org/'

gemspec

group :development do
  gem 'rake'
  gem 'rubygems-tasks', '~> 0.3'

  # rdoc 8 depends on rbs, which has no java platform gem before 4.1.0.pre.2.
  # See https://github.com/ruby/rdoc/issues/1746
  gem 'rbs', '>= 4.1.0.pre.2' if RUBY_PLATFORM == 'java'

  gem 'rubocop',        '~> 1.18'

  gem 'rspec',          '~> 3.0'
  gem 'simplecov',      '~> 0.7', require: false

  gem 'kramdown',       '~> 2.0'
  gem 'redcarpet',       platform: :mri
  gem 'yard',           '~> 0.9'
  gem 'yard-spellcheck', require: false
end
