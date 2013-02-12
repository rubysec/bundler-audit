require 'spec_helper'

describe "CLI" do
  it "shows vulnerable gems" do
    result = sh("cd spec/bundle && bundle && ../../bin/bundle-audit").gsub(/\e\[\d+m/, "")
    result.should include <<-ADVICE
Name: rails
Version: 3.2.10
CVE: 2013-0276
Criticality: Medium
URL: http://direct.osvdb.org/show/osvdb/90072
Title: Ruby on Rails Active Record attr_protected Method Bypass
ADVICE
  end

  def sh(command, options={})
    Bundler.with_clean_env do
      result = `#{command} 2>&1`
      raise "FAILED #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end
  end
end
