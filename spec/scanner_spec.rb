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
      subject.all? { |result|
        result.advisory.vulnerable?(result.gem.version)
      }.should be_true
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['OSVDB-89026']) }

      it "should ignore the specified advisories" do
        ids = subject.map { |result| result.advisory.id }
        
        ids.should_not include('OSVDB-89026')
      end
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should match unpatched gems to their advisories" do
      subject[0].source.should == 'git://github.com/rails/jquery-rails.git'
      subject[1].source.should == 'http://rubygems.org/'
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
