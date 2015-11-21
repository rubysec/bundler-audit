require 'spec_helper'
require 'bundler/audit/cli'

describe Bundler::Audit::CLI do

  context "when update succeeds" do

    before { expect(Bundler::Audit::Database).to receive(:update!).and_return(true) }

    it "prints updated message" do
      expect { subject.update }.to output(/Updated ruby-advisory-db/).to_stdout
    end

    it "prints total advisory count" do
      database = double
      expect(database).to receive(:size).and_return(1234)
      expect(Bundler::Audit::Database).to receive(:new).and_return(database)

      expect { subject.update }.to output(/ruby-advisory-db: 1234 advisories/).to_stdout
    end
  end

  context "when update fails" do

    before { expect(Bundler::Audit::Database).to receive(:update!).and_return(false) }

    it "prints failure message" do
      expect do
        begin
          subject.update
        rescue SystemExit
        end
      end.to output(/Failed updating ruby-advisory-db!/).to_stdout
    end

    it "exits with error status code" do
      expect { subject.update }.to raise_error(SystemExit) do |error|
        expect(error.success?).to eq(false)
        expect(error.status).to eq(1)
      end
    end

  end
end
