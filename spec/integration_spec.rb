require 'spec_helper'

describe "bin/bundler-audit" do
  let(:name) { 'bundler-audit' }
  let(:path) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin',name))
  end

  let(:command) { "#{path} version" }

  subject { sh(command) }

  it "must invoke the CLI class" do
    expected = "bundler-audit #{Bundler::Audit::VERSION}#{$/}"

    if RUBY_VERSION.start_with?("3.0") || RUBY_ENGINE == "truffleruby"
      # Allow `WARN: Unresolved or ambiguous specs during Gem::Specification.reset:` for Ruby 3.0.x and TruffleRuby
      expect(subject).to include(expected)
    else
      expect(subject).to eq(expected)
    end
  end
end

describe "bin/bundle-audit" do
  let(:name) { 'bundle-audit' }
  let(:path) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin',name))
  end

  let(:command) { "#{path} version" }

  subject { sh(command) }

  it "must invoke the CLI class" do
    expected = "bundler-audit #{Bundler::Audit::VERSION}#{$/}"

    if RUBY_VERSION.start_with?("3.0") || RUBY_ENGINE == "truffleruby"
      # Allow `WARN: Unresolved or ambiguous specs during Gem::Specification.reset:` for Ruby 3.0.x and TruffleRuby
      expect(subject).to include(expected)
    else
      expect(subject).to eq(expected)
    end
  end
end
