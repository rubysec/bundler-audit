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

  describe "initialization with paths" do
    let(:scanner) { described_class.new(*args) }
    let(:expected_lockfile_contents) { File.read(expected_lockfile_path) }

    context "when initialized without a root" do
      let(:args) { [] }
      let(:expected_lockfile_path) { File.expand_path("../../Gemfile.lock", __FILE__) }
      before do
        allow(Dir).to receive(:pwd).and_return(File.expand_path("../..", __FILE__))
      end

      it "defaults to a Gemfile.lock in the cwd" do
        expect(Bundler::LockfileParser).to receive(:new).with(expected_lockfile_contents)
        scanner
      end

      it "sets the root to the cwd" do
        expect(scanner.root).to eq Dir.pwd
      end
    end

    context "when initialized with a directory" do
      let(:args) { [File.expand_path("../fixtures", __FILE__)] }
      let(:expected_lockfile_path) { File.expand_path("../fixtures/Gemfile.lock", __FILE__) }

      it "uses a Gemfile.lock in the supplied directory" do
        expect(Bundler::LockfileParser).to receive(:new).with(expected_lockfile_contents)
        scanner
      end

      it "sets the root to the supplied directory" do
        expect(scanner.root).to eq File.expand_path("../fixtures", __FILE__)
      end
    end

    context "when initialized with a file" do
      let(:args) { [File.expand_path("../fixtures/rails-gemfile.lock", __FILE__)] }
      let(:expected_lockfile_path) { File.expand_path("../fixtures/rails-gemfile.lock", __FILE__) }

      it "uses the supplied filename" do
        expect(Bundler::LockfileParser).to receive(:new).with(expected_lockfile_contents)
        scanner
      end

      it "sets the root to the directory of the supplied file" do
        expect(scanner.root).to eq File.expand_path("../fixtures", __FILE__)
      end
    end
  end
end
