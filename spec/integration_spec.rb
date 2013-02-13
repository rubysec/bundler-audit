require 'spec_helper'

describe "CLI" do
  include Helpers

  let(:command) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundle-audit'))
  end

  context "when auditing a vulnerable bundle" do
    let(:bundle)    { 'vuln' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) do
        decolorize(sh(command, :fail => true))
      end
    end

    it "should print advisory information for the vulnerable gems" do
      subject.should include %{
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
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) do
        decolorize(sh(command))
      end
    end

    it "should print nothing when everything is fine" do
      subject.strip.should == "No unpatched versions found"
    end
  end
end
