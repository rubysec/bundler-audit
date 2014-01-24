require 'spec_helper'
require 'bundler/audit/database'
require 'tmpdir'
require 'rake/file_list'

describe Bundler::Audit::Database do
  let(:vendored_advisories) do
    Rake::FileList[File.join(Bundler::Audit::Database::VENDORED_PATH, '**/*.yml')].sort
  end

  describe "path" do
    subject { described_class.path }

    it "it should be a directory" do
      File.directory?(subject).should be_true
    end

    it "should prefer the user repo, iff it's as up to date, or more up to date than the vendored one" do
      Bundler::Audit::Database.update!

      # As up to date...
      expect do
        # Stub the Vendor copy to be the exact same as the user path copy
        stub_const("Bundler::Audit::Database::VENDORED_TIMESTAMP", Dir.chdir(mocked_user_path) { Time.parse(`git log --pretty="%cd" -1`) })
        # When they are the exact same prefer the user copy
        expect(Bundler::Audit::Database.path).to eq mocked_user_path
      end

      # More up to date...
      fake_a_commit_in_the_user_repo
      # Prefer the newset, in this case user repo
      expect(Bundler::Audit::Database.path).to eq mocked_user_path

      # Roll the advisory-db back until its older than the one checked in this could
      # be any number of commits, not just 2
      roll_user_repo_back_until do
        t1 = Dir.chdir(Bundler::Audit::Database::USER_PATH) { Time.parse(`git log --pretty="%cd" -1`) }
        t2 = Time.parse(File.read("#{Bundler::Audit::Database::VENDORED_PATH}.ts")).utc
        t2 > t1
      end

      # Now the Advisory db is older than the one checked into vendor. We should expect
      # the Database to favour the newest (ie Vendor)
      expect(Bundler::Audit::Database.path).to eq Bundler::Audit::Database::VENDORED_PATH
    end
  end

  describe "update!" do
    it "should create the USER_PATH path as needed" do
      Bundler::Audit::Database.update!
      expect(File.directory?(mocked_user_path)).to be true
    end

    it "should create the repo, then update it given multple successive calls." do
      expect_update_to_clone_repo!
      Bundler::Audit::Database.update!
      expect(File.directory?(mocked_user_path)).to be true

      expect_update_to_update_repo!
      Bundler::Audit::Database.update!
      expect(File.directory?(mocked_user_path)).to be true
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      subject { described_class.new }

      it "should default path to path" do
        subject.path.should == described_class.path
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
        s.name    = 'actionpack'
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

  describe "#size" do
    it { expect(subject.size).to eq vendored_advisories.count }
  end

  describe "#advisories" do
    it "should return a list of all advisories." do
      actual_advisories = Bundler::Audit::Database.new.
        advisories.
        map(&:path).
        sort

      expect(actual_advisories).to eq vendored_advisories
    end
  end

  describe "#to_s" do
    it "should return the Database path" do
      subject.to_s.should == subject.path
    end
  end

  describe "#inspect" do
    it "should produce a Ruby-ish instance descriptor" do
      expect(Bundler::Audit::Database.new.inspect).to eq("#<Bundler::Audit::Database:#{Bundler::Audit::Database::VENDORED_PATH}>")
    end
  end
end
