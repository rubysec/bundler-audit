require 'spec_helper'
require 'bundler/audit/results/unpatched_gem'

describe Bundler::Audit::Results::UnpatchedGem do
  let(:gem) do
    instance_double(
      'Gem::Specification', name: 'foo',
                            version: '1.2.3'
    )
  end

  let(:advisory) do
    instance_double(
      'Bundler::Audit::Advisory', id: 'CVE-YYYY-XYZ',
    )
  end

  subject { described_class.new(gem,advisory) }

  describe "#==" do
    context "when an object of a different class is given" do
      let(:other) { Object.new }

      it { expect(subject == other).to be(false) }
    end
  end

  describe "#to_h" do
    subject { super().to_h }

    let(:advisory_hash) { {id: advisory.id} }
    before { expect(advisory).to receive(:to_h).and_return(advisory_hash) }

    it "must inclide type: :unpatched_gem" do
      expect(subject[:type]).to be :unpatched_gem
    end

    it "must include a :gem key containing a Hash" do
      expect(subject[:gem]).to be_kind_of(Hash)
    end

    context ":gem" do
      it "must contain a :name key of the gem name" do
        expect(subject[:gem][:name]).to be == gem.name
      end

      it "must contain a :version key of the gem name" do
        expect(subject[:gem][:version]).to be == gem.version
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
