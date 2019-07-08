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

      expect(results).not_to be_empty
    end

    context "when not called with a block" do
      it "should return an Enumerator" do
        expect(subject.scan).to be_kind_of(Enumerable)
      end
    end
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)  { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should match unpatched gems to their advisories" do
      expect(subject.all? { |result|
        result.advisory.vulnerable?(result.gem.version)
      }).to be_truthy
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['OSVDB-89026']) }

      it "should ignore the specified advisories" do
        ids = subject.map { |result| result.advisory.id }

        expect(ids).not_to include('OSVDB-89026')
      end
    end

    context "with ignore file" do
      let(:bundle)    { 'unpatched_gems_with_ignore' }
      let(:ignorefile_path) { File.join(directory, described_class::IGNOREFILE_NAME) }
      let(:advisories_to_ignore) { File.read(ignorefile_path).split }

      it "should ignore the specified advisories" do
        ids = subject.map { |result| result.advisory.id }

        advisories_to_ignore.each do |advisory_to_ignore|
          expect(ids).not_to include(advisory_to_ignore)
        end
      end

      # this example is here to make sure the previous example is not a false positive
      it "should not ignore the advisories when ignore file is not present" do
        # stubs out file call to bypass the ignore file
        allow(File).to receive(:exist?).with(
          a_string_ending_with(described_class::IGNOREFILE_NAME)
        ) { false }

        ids = subject.map { |result| result.advisory.id }

        advisories_to_ignore.each do |advisory_to_ignore|
          expect(ids).to include(advisory_to_ignore)
        end
      end
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should match unpatched gems to their advisories" do
      expect(subject[0].source).to eq('git://github.com/rails/jquery-rails.git')
      expect(subject[1].source).to eq('http://rubygems.org/')
    end
  end

  context "when auditing a secure bundle" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should print nothing when everything is fine" do
      expect(subject).to be_empty
    end
  end
end
