# frozen_string_literal: true
require 'spec_helper'
require 'tmpdir'
require 'bundler/audit/lockfile_loader'

describe LockfileLoader do
  describe "#initialize" do
    let(:path) { "/path/to/project" }

    subject { described_class.new(path) }

    it "initializes with a path" do
      expect(subject.path).to eq(path)
    end
  end

  describe "#contents" do
    before {
      stub_const("Bundler::VERSION", "1.8.0")
    }

    let(:expected) { "expected lockfile contents" }

    it "takes gems.locked first" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "gems.locked"), expected)
        File.write(File.join(dir, "Gemfile.lock"), "unexpected")

        expect(LockfileLoader.new(dir).contents).to eq(expected)
      end
    end

    it "falls back to Gemfile.lock" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "Gemfile.lock"), expected)

        expect(LockfileLoader.new(dir).contents).to eq(expected)
      end
    end

    it "raises if none are found" do
      Dir.mktmpdir do |dir|
        loader = LockfileLoader.new(dir)
        expect { loader.contents }.to raise_error(StandardError)
      end
    end
  end

  describe ".lockfile_names" do
    subject { described_class.lockfile_names }

    it "returns just the legacy Gemfile.lock for old bundler versions" do
      stub_const("Bundler::VERSION", "1.7.9")
      expect(subject).to eq(["Gemfile.lock"])
    end

    it "returns the order lits of gems.locked then Gemfile.lock for newer bundler versions" do
      stub_const("Bundler::VERSION", "1.8.0")
      expect(subject).to eq(["gems.locked", "Gemfile.lock"])
    end
  end
end
