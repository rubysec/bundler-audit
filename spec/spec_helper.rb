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

  def executable
    File.expand_path(File.join('..','..','bin','bundle-audit'), __FILE__)
  end

  def audit_in_directory(additions, directory)
    Dir.chdir(directory) { decolorize(sh(executable + additions)) }
  end
end

include Bundler::Audit
