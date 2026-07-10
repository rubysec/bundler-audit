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

      context "when inherit is not an Array" do
        let(:path) { File.join(fixtures_dir,'bad','inherit_is_not_an_array.yml') }

        it "raises a validation error" do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError,
                                            /'inherit' key found in config file, but is not an Array/)
        end
      end

      context "when inherit array contains a non-String" do
        let(:path) { File.join(fixtures_dir,'bad','inherit_contains_a_non_string.yml') }

        it "raises a validation error" do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError,
                                            /'inherit' array in config file contains a non-String/)
        end
      end

      context "when an inherited file does not exist" do
        let(:path) { File.join(fixtures_dir,'bad','inherit_missing_target.yml') }

        it "raises a FileNotFound error" do
          expect { subject }.to raise_error(described_class::FileNotFound,
                                            /Configuration file '.*does_not_exist\.yml' does not exist/)
        end
      end

      context "when the inherit chain forms a cycle" do
        let(:path) { File.join(fixtures_dir,'bad','inherit_cycle_a.yml') }

        it "raises a validation error identifying the cycle" do
          expect { subject }.to raise_error(described_class::InvalidConfigurationError,
                                            /Cycle detected in 'inherit'/)
        end
      end
    end

    context "when a file inherits another" do
      let(:path) { File.join(fixtures_dir,'inherit','child.yml') }

      it { should be_a(described_class) }

      it "must merge the parent's ignore list with the child's" do
        expect(subject.ignore).to eq(Set.new(%w[CVE-BASE-1 CVE-BASE-2 CVE-CHILD-1]))
      end
    end

    context "when the inherit chain is 3 deep" do
      let(:path) { File.join(fixtures_dir,'inherit','grandchild.yml') }

      it "must transitively merge the ignore lists" do
        expect(subject.ignore).to eq(Set.new(%w[CVE-BASE-1 CVE-BASE-2 CVE-MIDDLE-1 CVE-GRANDCHILD-1]))
      end
    end

    context "when the inherit path is relative" do
      let(:path) { File.join(fixtures_dir,'inherit','child.yml') }

      it "must resolve inherited paths relative to the including file" do
        Dir.chdir('/tmp') do
          expect(subject.ignore).to eq(Set.new(%w[CVE-BASE-1 CVE-BASE-2 CVE-CHILD-1]))
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
    end

    context "when given :ignore" do
      let(:advisory_ids) { %w[CVE-123 CVE-456] }

      subject { described_class.new(ignore: advisory_ids) }

      it "must initialize @ignore to contain :ignore" do
        expect(subject.ignore).to be_kind_of(Set)
        expect(subject.ignore).to be == Set.new(advisory_ids)
      end
    end
  end
end
