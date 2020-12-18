require 'spec_helper'
require 'bundler/audit/database'
require 'tmpdir'

describe Bundler::Audit::Database do
  let(:vendored_advisories) do
    Dir[File.join(Fixtures::DATABASE_PATH, 'gems/*/*.yml')].sort
  end

  describe ".path" do
    subject { described_class.path }

    it "it should be a directory" do
      expect(described_class.path).to be_truthy
    end
  end

  describe ".exists?" do
  end

  describe ".download" do
  end

  describe ".update!" do
    subject { described_class }

    context "when :path does not yet exist" do
      let(:dest_dir) { Fixtures.join('new-ruby-advisory-db') }

      before { stub_const("#{described_class}::DEFAULT_PATH",dest_dir) }

      let(:url)  { described_class::URL          }
      let(:path) { described_class::DEFAULT_PATH }

      it "should execute `git clone` and call .new" do
        expect(subject).to receive(:system).with('git', 'clone', url, path).and_return(true)
        expect(subject).to receive(:new)

        subject.update!(quiet: false)
      end

      context "when the `git clone` fails" do
        before { stub_const("#{described_class}::URL",'https://example.com/') }

        it do
          expect(subject).to receive(:system).with('git', 'clone', url, path).and_return(false)

          expect(subject.update!(quiet: false)).to eq(false)
        end
      end

      after { FileUtils.rm_rf(dest_dir) }
    end

    context "when :path already exists" do
      let(:dest_dir) { Fixtures.join('existing-ruby-advisory-db') }

      before { FileUtils.cp_r(Fixtures::DATABASE_PATH,dest_dir) }
      before { stub_const("#{described_class}::DEFAULT_PATH",dest_dir) }

      it "should execute `git pull`" do
        expect_any_instance_of(subject).to receive(:system).with('git', 'pull', 'origin', 'master').and_return(true)

        subject.update!(quiet: false)
      end

      after { FileUtils.rm_rf(dest_dir) }

      context "when the `git pull` fails" do
        it do
          expect_any_instance_of(subject).to receive(:system).with('git', 'pull', 'origin', 'master').and_return(false)

          expect(subject.update!(quiet: false)).to eq(false)
        end
      end
    end

    context "when given an invalid option" do
      it do
        expect { subject.update!(foo: 1) }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      subject { described_class.new }

      it "should default path to path" do
        expect(subject.path).to eq(described_class.path)
      end
    end

    context "when given a directory" do
      let(:path ) { Dir.tmpdir }

      subject { described_class.new(path) }

      it "should set #path" do
        expect(subject.path).to eq(path)
      end
    end

    context "when given an invalid directory" do
      it "should raise an ArgumentError" do
        expect {
          described_class.new('/foo/bar/baz')
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#git?" do
  end

  describe "#update!" do
  end

  describe "#last_updated_at" do
  end

  describe "#advisories" do
    subject { super().advisories }

    it "should return a list of all advisories." do
      expect(subject.map(&:path)).to match_array(vendored_advisories)
    end
  end

  describe "#advisories_for" do
    let(:gem) { 'activesupport' }
    let(:vendored_advisories_for) do
      Dir[File.join(Fixtures::DATABASE_PATH, "gems/#{gem}/*.yml")].sort
    end

    subject { super().advisories_for(gem) }

    it "should return a list of all advisories." do
      expect(subject.map(&:path)).to match_array(vendored_advisories_for)
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

        expect(advisories).not_to be_empty
        expect(advisories.all? { |advisory|
          advisory.kind_of?(Bundler::Audit::Advisory)
        }).to be_truthy
      end
    end

    context "when given no block" do
      it "should return an Enumerator" do
        expect(subject.check_gem(gem)).to be_kind_of(Enumerable)
      end
    end
  end

  describe "#size" do
    it { expect(subject.size).to eq vendored_advisories.count }
  end

  describe "#to_s" do
    it "should return the Database path" do
      expect(subject.to_s).to eq(subject.path)
    end
  end

  describe "#inspect" do
    it "should produce a Ruby-ish instance descriptor" do
      expect(subject.inspect).to eq("#<#{described_class}:#{subject.path}>")
    end
  end
end
