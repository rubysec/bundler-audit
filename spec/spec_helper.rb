version = RUBY_VERSION.split(/\./).map(&:to_i)
if((version[0] == 1 && version[1] >= 9) || (version[0] >= 2))
  require 'simplecov'
  require 'json'
  SimpleCov.start
end

require 'rspec'
require 'bundler/audit/version'

module Helpers
  def sh(command, options={})
    Bundler.with_clean_env do
      result = `#{command} 2>&1`
      raise "FAILED #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end
  end

  def decolorize(string)
    string.gsub(/\e\[\d+m/, "")
  end
end

include Bundler::Audit
