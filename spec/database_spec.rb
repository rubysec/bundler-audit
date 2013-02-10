require 'spec_helper'
require 'bundler/audit/database'

require 'tmpdir'

describe Bundler::Audit::Database do
  describe "PATH" do
    subject { described_class::PATH }

    it "it should be a directory" do
      File.directory?(subject).should be_true
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      subject { described_class.new }

      it "should default path to PATH" do
        subject.path.should == described_class::PATH
      end
    end

    context "when given a directory" do
      let(:path ) { Dir.tmpdir }

      subject { described_class.new(path) }

      it "should set #path" do
        subject.path.should == path
      end
    end

    context "when given an invalid directory" do
      it "should raise an ArgumentError" do
        lambda {
          described_class.new('/foo/bar/baz')
        }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#size" do
    it { subject.size.should > 0 }
  end

  describe "#to_s" do
    it "should return the Database path" do
      subject.to_s.should == subject.path
    end
  end
end
