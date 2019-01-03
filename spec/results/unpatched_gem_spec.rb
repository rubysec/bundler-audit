require 'spec_helper'
require 'bundler/audit/results/unpatched_gem'

describe Bundler::Audit::Results::UnpatchedGem do
  describe "#==" do
    context "when an object of a different class is given" do
      let(:other) { Object.new }

      it { expect(subject == other).to be(false) }
    end
  end

  describe "#to_s" do
    it "should return the advisory ID" do
      expect(subject.to_s).to be == advisory.id
    end
  end
end
