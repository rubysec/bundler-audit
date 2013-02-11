require 'spec_helper'
require 'bundler/audit/database'

require 'bundler'
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

  describe "#check_gem" do
    let(:gem) do
      Gem::Specification.new do |s|
        s.name    = 'rails'
        s.version = '3.1.9'
      end
    end

    context "when given a block" do
      it "should yield every advisory effecting the gem" do
        advisories = []

        subject.check_gem(gem) do |advisory|
          advisories << advisory
        end

        advisories.should_not be_empty
        advisories.all? { |advisory|
          advisory.kind_of?(Bundler::Audit::Advisory)
        }.should be_true
      end
    end

    context "when given no block" do
      it "should return an Enumerator" do
        subject.check_gem(gem).should be_kind_of(Enumerable)
      end
    end
  end

  describe "#check_bundle" do
    let(:path) { File.join(File.dirname(__FILE__),'bundle') }
    let(:bundle) do
      Dir.chdir(path) { Bundler.load }
    end

    context "when given a block" do
      it "should yield every advisory effecting the bundle" do
        advisories = []

        subject.check_bundle(bundle) do |gem,advisory|
          advisories << [gem, advisory]
        end

        advisories.should_not be_empty
        advisories.all? { |gem,advisory|
          gem.kind_of?(Gem::Specification) &&
            advisory.kind_of?(Bundler::Audit::Advisory)
        }.should be_true
      end
    end

    context "when given no block" do
      it "should return an Enumerator" do
        subject.check_bundle(bundle).should be_kind_of(Enumerable)
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
