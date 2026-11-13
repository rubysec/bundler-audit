require 'spec_helper'
require 'bundler/audit/report'

describe Bundler::Audit::Report do
  let(:uri) { URI('git://github.com/foo/bar.git') }
  let(:insecure_source) do
    Bundler::Audit::Results::InsecureSource.new(uri)
  end

  let(:gem) do
    Gem::Specification.new do |spec|
      spec.name = 'test'
      spec.version = '0.0.0'
    end
  end
  let(:gem_advisory) { double('Bundler::Audit::Advisory', id: 'CVE-3000-1234') }
  let(:unpatched_gem) do
    Bundler::Audit::Results::UnpatchedGem.new(gem,gem_advisory)
  end

  let(:ruby_version) { Bundler::RubyVersion.new('2.3.0', '0', nil, nil) }
  let(:engine_advisory) { double('Bundler::Audit::Advisory', id: 'CVE-2018-8779') }
  let(:unpatched_engine) do
    Bundler::Audit::Results::UnpatchedEngine.new(ruby_version,engine_advisory)
  end

  let(:results) do
    [insecure_source, unpatched_gem, unpatched_engine]
  end

  subject { described_class.new(results) }

  describe "#version" do
    it "should be the VERSION constant" do
      expect(subject.version).to be(Bundler::Audit::VERSION)
    end
  end

  describe "#time" do
    it { expect(subject.created_at).to be_kind_of(Time) }
  end

  describe "#<<" do
    subject { described_class.new }

    it "should return self" do
      expect(subject << insecure_source).to be(subject)
    end

    context "when given a Result::InsecureSource" do
      let(:result) { insecure_source }

      before { subject << result }

      it "should add the result to the report" do
        expect(subject.results.last).to be(result)
      end

      it "should also add the result to #insecure_sources" do
        expect(subject.insecure_sources.last).to be(result)
      end
    end

    context "when given a Result::UnpatchedGem" do
      let(:result) { unpatched_gem }

      before { subject << result }

      it "should add the result to the report" do
        expect(subject.results.last).to be(result)
      end

      it "should also add the result to #unpatched_gems" do
        expect(subject.unpatched_gems.last).to be(result)
      end
    end

    context "when given a Result::UnpatchedEngine" do
      let(:result) { unpatched_engine }

      before { subject << result }

      it "should add the result to the report" do
        expect(subject.results.last).to be(result)
      end

      it "should also add the result to #unpatched_engines" do
        expect(subject.unpatched_engines.last).to be(result)
      end
    end
  end

  describe "#each" do
    context "when given a block" do
      it "should enumerate over each result in the report" do
        expect { |b| subject.each(&b) }.to yield_successive_args(*results)
      end
    end

    context "when no block is given" do
      it "should return an Enumerator" do
        expect(subject.each).to be_kind_of(Enumerator)
      end
    end
  end

  describe "#vulnerable?" do
    context "when the report is empty" do
      subject { described_class.new }

      it { expect(subject.vulnerable?).to be false }
    end

    context "when then report contains results" do
      it { expect(subject.vulnerable?).to be true }
    end
  end

  describe "#each_advisory" do
    it "includes gem advisories" do
      advisories = []
      subject.each_advisory do |advisory|
        advisories << advisory
      end
      expect(advisories).to include(gem_advisory)
    end

    it "includes engine advisories" do
      advisories = []
      subject.each_advisory do |advisory|
        advisories << advisory
      end
      expect(advisories).to include(engine_advisory)
    end
  end

  describe "#advisories" do
    it "includes gem advisories" do
      expect(subject.advisories).to include(gem_advisory)
    end

    it "includes engine advisories" do
      expect(subject.advisories).to include(engine_advisory)
    end
  end
end
