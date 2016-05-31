require 'spec_helper'
require 'bundler/audit/scanner'

describe Scanner do
  # The matrix build includes versions of Ruby with advisories. Stub to
  # versions without.
  before(:each) do
    stub_const('RUBY_VERSION', '2.2.3')
    stub_const('RUBY_ENGINE', 'ruby')
    stub_const('RUBY_PATCHLEVEL', 173)
    allow_any_instance_of(Bundler::Audit::Scanner)
      .to receive(:rubygems_version).and_return('2.4.8')
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

  context "when auditing an unpatched Ruby" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    before(:each) do
      stub_const('RUBY_VERSION', '2.2.1')
      stub_const('RUBY_ENGINE', 'ruby')
      stub_const('RUBY_PATCHLEVEL', 85)
    end

    it "should match an unpatched Ruby to its advisories" do
      expect(subject.all? { |result|
        result.advisory.vulnerable?(result.gem.version)
      }).to be_truthy
      expect(subject.map { |r| r.advisory.id }).to include("OSVDB-120541")
    end

    it "respects patch level" do
      stub_const('RUBY_VERSION', '1.9.3')
      stub_const('RUBY_PATCHLEVEL', 392)
      expect(subject.map { |r| r.advisory.id }).to include("OSVDB-113747")
    end

    it "handles preview versions" do
      stub_const('RUBY_VERSION', '2.1.0')
      stub_const('RUBY_PATCHLEVEL', -1)
      allow_any_instance_of(Bundler::Audit::Scanner)
        .to receive(:ruby_version).and_return('2.1.0.dev')
      expect(subject.map { |r| r.advisory.id }).to include("OSVDB-100113")
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['OSVDB-120541']) }

      it "should ignore the specified advisories" do
        expect(subject.map { |r| r.advisory.id }).not_to include('OSVDB-120541')
      end
    end
  end

  context "when auditing an unpatched RubyGems" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    before(:each) do
      allow_any_instance_of(Bundler::Audit::Scanner)
        .to receive(:rubygems_version).and_return('2.4.5')
    end

    it "should match an unpatched RubyGems to its advisories" do
      expect(subject.all? { |result|
        result.advisory.vulnerable?(result.gem.version)
      }).to be_truthy
      expect(subject.map { |r| r.advisory.id }).to include("CVE-2015-3900")
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['CVE-2015-3900']) }

      it "should ignore the specified advisories" do
        expect(subject.map { |r| r.advisory.id }).not_to include('CVE-2015-3900')
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
