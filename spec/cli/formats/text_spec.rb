require 'spec_helper'
require 'bundler/audit/cli/formats'
require 'bundler/audit/cli/formats/text'

describe Bundler::Audit::CLI::Formats::Text do
  subject do
    Object.new.tap { |obj| obj.extend(described_class) }
  end

  it "must register the 'text' format" do
    expect(Bundler::Audit::CLI::Formats[:text]).to be described_class
  end

  describe "#print_report" do
  end
end
