require 'spec_helper'
require 'bundler/audit/cli/formats'
require 'bundler/audit/cli/formats/json'

describe Bundler::Audit::CLI::Formats::JSON do
  subject do
    Object.new.tap { |obj| obj.extend(described_class) }
  end

  it "must register the 'json' format" do
    expect(Bundler::Audit::CLI::Formats[:json]).to be described_class
  end

  describe "#print_report" do
  end
end
