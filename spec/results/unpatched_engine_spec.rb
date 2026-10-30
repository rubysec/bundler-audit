require 'spec_helper'
require 'bundler/audit/results/unpatched_engine'

describe Bundler::Audit::Results::UnpatchedEngine do
  let(:ruby_version) do
    Bundler::RubyVersion.new('2.3.0', '0', nil, nil)
  end

  let(:advisory) do
    double('Bundler::Audit::Advisory', id: 'CVE-3000-1234')
  end

  subject { described_class.new(ruby_version,advisory) }

  describe "#initialize" do
    it "must set the ruby_version attribute" do
      expect(subject.ruby_version).to be(ruby_version)
    end

    it "must set the advisory attribute" do
      expect(subject.advisory).to be(advisory)
    end
  end

  describe "#==" do
    context "when the other class is different" do
      let(:other) { Object.new }

      it "should return false" do
        expect(subject).to_not be == other
      end
    end

    context "when the other ruby version is different" do
      let(:other_ruby_version) do
        Bundler::RubyVersion.new('2.3.1', '0', nil, nil)
      end

      let(:other) { described_class.new(other_ruby_version,advisory) }

      it "must return false" do
        expect(subject).to_not be == other
      end
    end

    context "when the other advisory is different" do
      let(:other_advisory) do
        double('Bundler::Audit::Advisory', id: 'CVE-3000-9876')
      end

      let(:other) { described_class.new(ruby_version,other_advisory) }

      it "must return false" do
        expect(subject).to_not be == other
      end
    end

    context "when the ruby version and advisory are the same" do
      let(:other) { described_class.new(ruby_version,advisory) }

      it "must return true" do
        expect(subject).to be == other
      end
    end
  end

  describe "#to_h" do
    subject { super().to_h }

    let(:advisory_hash) { {id: advisory.id} }

    before { expect(advisory).to receive(:to_h).and_return(advisory_hash) }

    it "must include type: :unpatched_engine" do
      expect(subject[:type]).to be :unpatched_engine
    end

    it "must include a :engine key containing a Hash" do
      expect(subject[:engine]).to be_kind_of(Hash)
    end

    context ":engine" do
      it "must contain a :name key of the engine name" do
        expect(subject[:engine][:name]).to be == ruby_version.engine
      end

      it "must contain a :version key of the engine version" do
        expect(subject[:engine][:version]).to be == ruby_version.engine_gem_version.version
      end
    end

    it "must include a :advisory key containing a Hash of the advisory" do
      expect(subject[:advisory]).to be == advisory_hash
    end
  end

  describe "#to_s" do
    it "should return the advisory ID" do
      expect(subject.to_s).to be == advisory.id
    end
  end
end
