require 'spec_helper'
require 'bundler/audit/scanner'

describe Scanner do
  context "lockfile" do
    def with_lockfile(name)
      FileUtils.touch("spec/bundle/lockfiles/#{name}")
      yield
    ensure
      FileUtils.rm("spec/bundle/lockfiles/#{name}")
    end

    let(:directory) { File.join('spec','bundle','lockfiles') }

    subject { described_class.new(directory) }

    context "Gemfile.lock" do
      let(:lockfile) { 'Gemfile.lock' }
      let(:lockfile_content) { File.read(File.join(directory,lockfile)) }

      it "set lockfile from Gemfile.lock" do
        with_lockfile(lockfile) do
          expect(Bundler::LockfileParser).to receive(:new).with(lockfile_content)

          subject
        end
      end
    end

    context "gems.locked" do
      let(:lockfile) { 'gems.locked' }
      let(:lockfile_content) { File.read(File.join(directory,lockfile)) }

      context "with Bundler version that supports gems.locked" do
        it "set lockfile from gems.locked" do
          with_lockfile(lockfile) do
            stub_const("Bundler::VERSION", "1.8.0.pre")
            expect(Bundler::LockfileParser).to receive(:new).with(lockfile_content)

            subject
          end
        end
      end

      context "with Bundler version < 1.8.0.pre" do
        let(:lockfile) { 'Gemfile.lock' }
        let(:lockfile_content) { File.read(File.join(directory,lockfile)) }

        it "fallback to Gemfile.lock" do
          with_lockfile(lockfile) do
            stub_const("Bundler::VERSION", "1.7.15")
            expect(Bundler::LockfileParser).to receive(:new).with(lockfile_content)

            subject
          end
        end
      end
    end
  end

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
end
