require 'spec_helper'
require 'bundler/audit/cli/printers'

describe Bundler::Audit::CLI::Printers do
  describe ".[]" do
    context "when given the name of a registered printer" do
      it "should return the printer" do
        expect(subject[:text]).to be described_class::Text
      end
    end

    context "when given an unknown name" do
      it { expect(subject[:foo]).to be(nil) }
    end
  end

  describe ".register" do
    context "when given a valid printer module" do
      module GoodModule
        def print_report(report)
        end
      end

      let(:name)    { :good_module }
      let(:printer) { GoodModule   }

      it "should register the module" do
        subject.register name, printer

        expect(subject[name]).to be printer
      end
    end

    context "when given a printer module that does not define #print_report" do
      module BadModule
        def pront_report(report)
        end
      end

      let(:name)    { :bad_module }
      let(:printer) { BadModule   }

      it do
        expect { subject.register(name,printer) }.to raise_error(
          NotImplementedError, "#{printer.inspect} does not define #print_report"
        )
      end
    end
  end

  describe ".load" do
    PRINTERS_DIR = File.expand_path('../fixtures/lib',File.dirname(__FILE__))

    before(:all) { $LOAD_PATH.unshift(PRINTERS_DIR) }

    context "when given the name of a valid printer" do
      let(:name) { :good }

      it "should require and return the printer" do
        expect(subject.load(name)).to be described_class::Good
      end
    end

    context "when given the name of a non-existant printer" do
      let(:name) { :foo }

      it do
        expect { subject.load(name) }.to raise_error(
          described_class::PrinterNotFound, "could not load printer \"#{name}\""
        )
      end
    end

    context "when given the name of a printer which incorrectly registers itself" do
      let(:name) { :bad }

      it do
        expect { subject.load(name) }.to raise_error(
          described_class::PrinterNotFound, "unknown printer \"#{name}\""
        )
      end
    end

    after(:all) { $LOAD_PATH.delete(PRINTERS_DIR) }
  end
end
