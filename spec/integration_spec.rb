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
      expect(subject).to include("Vulnerabilities found!")
    end

    it "should print advisory information for the vulnerable gems" do
      advisory_pattern = /(Name: [^\n]+
Version: \d+.\d+.\d+
Advisory: CVE-[0-9]{4}-[0-9]{4}
Criticality: (High|Medium)
URL: http:\/\/(direct|www\.)?osvdb.org\/show\/osvdb\/\d+
Title: [^\n]*?
Solution: upgrade to ((~>|=>) \d+.\d+.\d+, )*(~>|=>) \d+.\d+.\d+[\s\n]*?)+/

      expect(subject).to match(advisory_pattern)
      expect(subject).to include("Vulnerabilities found!")
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
      expect(subject).not_to include("OSVDB-89026")
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print warnings about insecure sources" do
      expect(subject).to include(%{
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
      expect(subject.strip).to eq("No vulnerabilities found")
    end
  end
end
