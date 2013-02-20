require 'spec_helper'
require 'bundler/audit/database'
require 'tmpdir'

describe Bundler::Audit::Database do
  include Helpers

  describe "PATH" do
    subject { described_class::PATH }

    it "it should be a directory" do
      File.directory?(subject).should be_true
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      it "should default path to PATH" do
        subject.path.should == described_class::PATH
      end
    end

    context "when given a directory" do
      let(:path ) { Dir.tmpdir }

      subject { described_class.new(:path => path) }

      it "should set #path" do
        subject.path.should == path
      end
    end

    context "when given an invalid directory" do
      it "should raise an ArgumentError" do
        lambda {
          described_class.new(:path => '/foo/bar/baz')
        }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#check_gem" do
    let(:gem) do
      Gem::Specification.new do |s|
        s.name    = 'actionpack'
        s.version = '3.1.9'
      end
    end

    context "when given a block" do
      it "should yield every advisory effecting the gem" do
        advisories = advisories_for_gem(gem)
        advisories.all? { |advisory|
          advisory.kind_of?(Bundler::Audit::Advisory)
        }.should be_true
      end

      it "should yield advisories considered not safe by the user" do
        advisories = advisories_for_gem(gem, :user_considers_safe => ["XXXX-0156@3.1.9"])
        advisories.map(&:cve).should include("2013-0156")
      end

      it "should yield version of advisories considered not safe by the user" do
        advisories = advisories_for_gem(gem, :user_considers_safe => ["2013-0156@3.1.8"])
        advisories.map(&:cve).should include("2013-0156")
      end

      it "should not yield advisories considered safe by the user" do
        advisories = advisories_for_gem(gem, :user_considers_safe => ["2013-0156@3.1.9"])
        advisories.map(&:cve).should_not include("2013-0156")
      end

      it "should ignore all versions of a gem when no version was given for advisory ignore" do
        advisories = advisories_for_gem(gem, :user_considers_safe => ["2013-0156"])
        advisories.map(&:cve).should_not include("2013-0156")
      end
    end

    context "when given no block" do
      it "should return an Enumerator" do
        subject.check_gem(gem).should be_kind_of(Enumerable)
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
