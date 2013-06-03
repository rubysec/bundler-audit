require 'spec_helper'
require 'bundler/audit/scanner'

describe Scanner do
  describe "#scan" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject { described_class.new(directory) }

    it "should yield results" do
      results = []

      subject.scan { |result| results << result }

      results.should_not be_empty
    end

    context "when not called with a block" do
      it "should return an Enumerator" do
        subject.scan.should be_kind_of(Enumerable)
      end
    end
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)  { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should match unpatched gems to their advisories" do
      subject[0].gem.name.should == 'actionpack'
      subject[0].gem.version.to_s.should == '3.2.10'
      subject[0].advisory.cve.should == '2013-0156'
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['CVE-2013-0156']) }

      it "should ignore the specified advisories" do
        cves = subject.map { |result| result.advisory.cve }
        
        cves.should_not include('2013-0156')
      end
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should warn about the insecure sources" do
      subject[0].source.should == 'git://github.com/rails/jquery-rails.git'
      subject[1].source.should == 'http://rubygems.org/'
    end

    context "when the :consider_git_uris_safe option is given" do
      subject { scanner.scan(:consider_git_uris_safe => true).to_a }

      it "should only warn about http sources" do
        subject.map(&:source).should == ['http://rubygems.org/']
      end
    end
  end

  context "when auditing a secure bundle" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should print nothing when everything is fine" do
      subject.should be_empty
    end
  end
end
