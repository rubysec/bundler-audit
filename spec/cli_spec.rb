require 'spec_helper'
require 'bundler/audit/cli'

describe CLI do
  describe "#check" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)   { double(Scanner).as_null_object }

    subject { described_class.new }

    it "defaults to the current working directory" do
      Scanner.should_receive(:new).with(Dir.pwd).and_return(scanner)
      subject.check
    end

    it "takes an optional directory argument" do
      Scanner.should_receive(:new).with(directory).and_return(scanner)
      subject.check(directory)
    end
  end
end
