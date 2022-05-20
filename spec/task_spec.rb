require 'spec_helper'
require 'bundler/audit/task'

require 'rake'

describe Bundler::Audit::Task do
  before { subject }

  it "must define a 'bundle:audit:check' task" do
    expect(Rake::Task['bundle:audit:check']).to_not be_nil
  end

  it "must define a 'bundle:audit:update' task" do
    expect(Rake::Task['bundle:audit:update']).to_not be_nil
  end

  it "must define a 'bundle:audit' task" do
    expect(Rake::Task['bundle:audit']).to_not be_nil
  end

  it "must define a 'bundler:audit:check' task" do
    expect(Rake::Task['bundler:audit:check']).to_not be_nil
  end

  it "must define a 'bundler:audit:update' task" do
    expect(Rake::Task['bundler:audit:update']).to_not be_nil
  end

  it "must define a 'bundler:audit' task" do
    expect(Rake::Task['bundler:audit']).to_not be_nil
  end

  describe "#bundler_audit" do
    let(:subcommand) { 'subcommand' }
    context "when the command exits successfully" do
      before do
        allow(subject).to receive(:system).with('bundler-audit',subcommand).and_return(true)
      end

      it "must return true" do
        expect(subject.bundler_audit(subcommand)).to be(true)
      end
    end

    context "when there vulnerabilities are found" do
      before do
        allow(subject).to receive(:system).with('bundler-audit',subcommand).and_return(false)
      end

      it "must exit with a non-zero error code" do
        expect(subject).to receive(:exit).with($?.exitstatus)

        subject.bundler_audit(subcommand)
      end
    end

    context "when the bundler-audit command cannot be executed" do
      before do
        allow(subject).to receive(:system).with('bundler-audit',subcommand).and_return(nil)
      end

      it do
        expect {
          subject.bundler_audit(subcommand)
        }.to raise_error(described_class::CommandNotFound,"bundler-audit could not be executed")
      end
    end
  end

  describe "#check" do
    context "when the command exits successfully" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','check').and_return(true)
      end

      it "must return true" do
        expect(subject.check).to be(true)
      end
    end

    context "when there vulnerabilities are found" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','check').and_return(false)
      end

      it "must exit with a non-zero error code" do
        expect(subject).to receive(:exit).with($?.exitstatus)

        subject.check
      end
    end

    context "when the bundler-audit command cannot be executed" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','check').and_return(nil)
      end

      it do
        expect {
          subject.check
        }.to raise_error(described_class::CommandNotFound,"bundler-audit could not be executed")
      end
    end
  end

  describe "#update" do
    context "when the command exits successfully" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','update').and_return(true)
      end

      it "must return true" do
        expect(subject.update).to be(true)
      end
    end

    context "when there vulnerabilities are found" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','update').and_return(false)
      end

      it "must exit with a non-zero error code" do
        expect(subject).to receive(:exit).with($?.exitstatus)

        subject.update
      end
    end

    context "when the bundler-audit command cannot be executed" do
      before do
        allow(subject).to receive(:system).with('bundler-audit','update').and_return(nil)
      end

      it do
        expect {
          subject.update
        }.to raise_error(described_class::CommandNotFound,"bundler-audit could not be executed")
      end
    end
  end
end
