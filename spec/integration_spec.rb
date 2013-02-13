require 'spec_helper'

describe "CLI" do
  include Helpers

  it "shows vulnerable gems" do
    result = decolorize(sh("cd spec/bundle && ../../bin/bundle-audit", :fail => true))
    result.should include <<-ADVICE
Name: rails
Version: 3.2.10
CVE: 2013-0276
Criticality: Medium
URL: http://direct.osvdb.org/show/osvdb/90072
Title: Ruby on Rails Active Record attr_protected Method Bypass
ADVICE
  end

  it "shows nothing when everything is fine" do
    decolorize(sh("bin/bundle-audit")).strip.should == "No unpatched versions found"
  end
end
