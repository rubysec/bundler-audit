require 'spec_helper'
require 'bundler/audit/results/insecure_source'

describe Bundler::Audit::Results::InsecureSource do
  let(:source) { URI('http://github.com/foo/bar.git') }

  subject { described_class.new(source) }

  describe "#==" do
    let(:other_subject) { described_class.new(other_source) }

    context "when the sources are the same" do
      let(:other_source)  { source }

      it { expect(subject).to be == other_subject }
    end

    context "when the sources are different" do
      let(:other_source)  { URI('http://github.com/other/baz.git') }

      it { expect(subject).to_not be == other_subject }
    end
  end

  describe "#to_s" do
    it "should return the source" do
      expect(subject.to_s).to be == source.to_s
    end
  end
end
