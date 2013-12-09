require 'spec_helper'

describe "CLI" do
  include Helpers

  let(:command) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundle-audit'))
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print a warning" do
      subject.should include("Unpatched versions found!")
    end

    it "should print advisory information for the vulnerable gems" do
      advisory_pattern = /(Name: [^\n]+
Version: \d+.\d+.\d+
Advisory: OSVDB-\d+
Criticality: (High|Medium)
URL: http:\/\/(direct|www\.)?osvdb.org\/show\/osvdb\/\d+
Title: [^\n]*?
Solution: upgrade to ((~>|=>) \d+.\d+.\d+, )*(~>|=>) \d+.\d+.\d+[\s\n]*?)+/

      expect(subject).to match(advisory_pattern)
      expect(subject).to include("Unpatched versions found!")
    end
  end

  context "when auditing a bundle with ignored gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    let(:command) do
      File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundle-audit -i OSVDB-89026'))
    end

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should not print advisory information for ignored gem" do
      subject.should_not include("OSVDB-89026")
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print warnings about insecure sources" do
      subject.should include(%{
Insecure Source URI found: git://github.com/rails/jquery-rails.git
Insecure Source URI found: http://rubygems.org/
      }.strip)
    end
  end

  context "when auditing a secure bundle" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command) }
    end

    it "should print nothing when everything is fine" do
      subject.strip.should == "No unpatched versions found"
    end
  end
end
