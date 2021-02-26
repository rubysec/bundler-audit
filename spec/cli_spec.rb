require 'spec_helper'
require 'bundler/audit/cli'

describe Bundler::Audit::CLI do
  describe ".start" do
    context "with wrong arguments" do
      it "exits with error status code" do
        expect {
          described_class.start ["check", "foo/bar/baz"]
        }.to raise_error(SystemExit) do |error|
          expect(error.success?).to eq(false)
          expect(error.status).to eq(1)
        end
      end
    end
  end

  describe "#update" do
    context "not --quiet (the default)" do
      context "when update succeeds" do
        before do
          expect_any_instance_of(Bundler::Audit::Database).to receive(:update!).and_return(true)
        end

        it "prints updated message" do
          expect { subject.update }.to output(/Updated ruby-advisory-db/).to_stdout
        end

        it "prints total advisory count" do
          size = 1234
          expect_any_instance_of(Bundler::Audit::Database).to receive(:size).and_return(size)

          expect { subject.update }.to output(/advisories:\t#{size} advisories/).to_stdout
        end
      end

      context "when update fails" do
        before do
          expect_any_instance_of(Bundler::Audit::Database).to receive(:update!).and_return(false)
        end

        it "prints failure message" do
          expect {
            begin
              subject.update
            rescue SystemExit
            end
          }.to output(/Failed updating ruby-advisory-db!/).to_stderr
        end

        it "exits with error status code" do
          expect {
            # Capture output of `update` only to keep spec output clean.
            # The test regarding specific output is above.
            expect { subject.update }.to output.to_stdout
          }.to raise_error(SystemExit) do |error|
            expect(error.success?).to eq(false)
            expect(error.status).to eq(1)
          end
        end

      end

      context "when git is not installed" do
        before do
          expect_any_instance_of(Bundler::Audit::Database).to receive(:update!).and_return(nil)
          expect(Bundler).to receive(:git_present?).and_return(false)
        end

        it "prints failure message" do
          expect do
            begin
              subject.update
            rescue SystemExit
            end
          end.to output(/Git is not installed!/).to_stderr
        end

        it "exits with error status code" do
          expect {
            # Capture output of `update` only to keep spec output clean.
            # The test regarding specific output is above.
            expect { subject.update }.to output.to_stdout
          }.to raise_error(SystemExit) do |error|
            expect(error.success?).to eq(false)
            expect(error.status).to eq(1)
          end
        end
      end
    end

    context "--quiet" do
      subject do
        described_class.new([], {quiet: true})
      end

      context "when update succeeds" do
        before do
          expect_any_instance_of(Bundler::Audit::Database).to(
            receive(:update!).with(quiet: true).and_return(true)
          )
        end

        it "does not print any output" do
          expect { subject.update }.to_not output.to_stdout
        end
      end

      context "when update fails" do
        before do
          expect_any_instance_of(Bundler::Audit::Database).to(
            receive(:update!).with(quiet: true).and_return(false)
          )
        end

        it "prints failure message" do
          expect {
            begin
              subject.update
            rescue SystemExit
            end
          }.to_not output.to_stderr
        end

        it "exits with error status code" do
          expect {
            # Capture output of `update` only to keep spec output clean.
            # The test regarding specific output is above.
            expect { subject.update }.to output.to_stdout
          }.to raise_error(SystemExit) do |error|
            expect(error.success?).to eq(false)
            expect(error.status).to eq(1)
          end
        end
      end
    end
  end
end
