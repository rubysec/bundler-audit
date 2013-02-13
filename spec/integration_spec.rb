require 'spec_helper'

describe "CLI" do
  include Helpers

  let(:directory) { File.join('spec','bundle',bundle) }

  context "when auditing a vulnerable bundle" do
    let(:bundle)    { 'vuln' }

    it "should print advisory information for the vulnerable gems" do
      output = audit_in_directory "", directory
      output.should include %{
Name: rails
Version: 3.2.10
CVE: 2013-0276
Criticality: Medium
URL: http://direct.osvdb.org/show/osvdb/90072
Title: Ruby on Rails Active Record attr_protected Method Bypass
      }.strip
    end
  end

  context "when auditing a secure bundle" do
    let(:bundle)    { 'secure' }

    it "should print nothing when everything is fine" do
      output = audit_in_directory "", directory
      output.strip.should == "No unpatched versions found"
    end
  end

  context "using live data" do
    let(:bundle)    { 'secure' }

    it "should show update and status" do
      output = audit_in_directory "--live", directory
      output.strip.should == "Downloading ruby-advisory-db\nNo unpatched versions found"
    end

    it "should show good amount of advisories in live db" do
      output = audit_in_directory " version --live", directory
      output.split.last.to_i.should >= 19
    end
  end
end
