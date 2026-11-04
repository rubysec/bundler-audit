require 'spec_helper'
require 'bundler/audit/configuration'

describe Bundler::Audit::Configuration do
  describe "when building from a yaml file" do
    let(:fixtures_dir) { File.expand_path('../fixtures/config',__FILE__) }

    subject { described_class.load(path) }

    context "when the file does not exist" do
      let(:path) { File.join(fixtures_dir,'bad','does_not_exist.yml') }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::FileNotFound, /Configuration file '.*' does not exist/)
      end
    end

    context "when the file does exist" do
      let(:path) { File.join(fixtures_dir,'valid.yml')   }

      it { should be_a(described_class) }
    end

    context "validations" do
      context "when the file is empty" do
        let(:path) { File.join(fixtures_dir,'bad','empty.yml') }

        it 'raises a validation error' do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError)
        end
      end

      context "when ignore is not an array" do
        let(:path) { File.join(fixtures_dir,'bad','ignore_is_not_an_array.yml') }

        it 'raises a validation error' do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError)
        end
      end

      context 'when ignore is an array' do
        context 'when ignore only contains strings' do
          let(:path) { File.join(fixtures_dir,'valid.yml')   }

          it { should be_a(described_class) }
        end

        describe "when ignore contains non-strings" do
          let(:path) { File.join(fixtures_dir,'bad','ignore_contains_a_non_string.yml') }

          it "raises a validation error" do
            expect { subject }.to raise_error(described_class::InvalidConfigurationError)
          end
        end
      end

      context "when exclude is not an array" do
        let(:path) { File.join(fixtures_dir,'bad','exclude_is_not_an_array.yml') }

        it 'raises a validation error' do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError)
        end
      end

      context 'when exclude is an array' do
        context 'when exclude only contains strings' do
          let(:path) { File.join(fixtures_dir,'valid_with_exclude.yml') }

          it { should be_a(described_class) }
        end

        describe "when exclude contains non-strings" do
          let(:path) { File.join(fixtures_dir,'bad','exclude_contains_a_non_string.yml') }

          it "raises a validation error" do
            expect { subject }.to raise_error(described_class::InvalidConfigurationError)
          end
        end
      end
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      it "must set @ignore to an empty Set" do
        expect(subject.ignore).to be_kind_of(Set)
        expect(subject.ignore).to be_empty
      end

      it "must set @exclude to an empty Set" do
        expect(subject.exclude).to be_kind_of(Set)
        expect(subject.exclude).to be_empty
      end
    end

    context "when given :ignore" do
      let(:advisory_ids) { %w[CVE-123 CVE-456] }

      subject { described_class.new(ignore: advisory_ids) }

      it "must initialize @ignore to contain :ignore" do
        expect(subject.ignore).to be_kind_of(Set)
        expect(subject.ignore).to be == Set.new(advisory_ids)
      end
    end

    context "when given :exclude" do
      let(:gem_names) { %w[activestorage actiontext] }

      subject { described_class.new(exclude: gem_names) }

      it "must initialize @exclude to contain :exclude" do
        expect(subject.exclude).to be_kind_of(Set)
        expect(subject.exclude).to be == Set.new(gem_names)
      end
    end
  end
end
