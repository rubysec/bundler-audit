require 'spec_helper'
require 'bundler/audit/configuration'

describe Bundler::Audit::Configuration do
  describe 'when building from a yaml file' do
    subject { described_class.from_yaml_file(file_path) }

    describe 'when the file does not exist' do
      let(:file_path) { File.expand_path('./fixtures/config_dot_files/does_not_exist.yml') }

      it 'raises an error' do
        expect { subject }.to raise_error(/Configuration file '.*' does not exist/)
      end
    end

    describe 'when the file does exist' do
      let(:file_path) { File.expand_path('./fixtures/config_dot_files/valid.yml', __dir__) }
      it { should be_a(described_class) }
    end
  end

  describe 'validations' do
    subject { described_class.new(config) }

    describe 'when ignore is not an array' do
      let(:config) do
        { 'ignore' => { hello: 'world' } }
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Bundler::Audit::Configuration::InvalidConfigurationError)
      end
    end

    describe 'when ignore is an array' do
      describe 'when ignore only contains strings' do
        let(:config) do
          { 'ignore' => ['CVE-123', 'cve-432'] }
        end

        it { should be_a(described_class) }
      end

      describe 'when ignore contains non-strings' do
        let(:config) do
          { 'ignore' => ['CVE-123', { hello: 'world' }] }
        end

        it 'raises a validation error' do
          expect { subject }.to raise_error(Bundler::Audit::Configuration::InvalidConfigurationError)
        end
      end
    end
  end

  describe '.ignore' do
    let(:config) { described_class.from_yaml_file(File.expand_path('./fixtures/config_dot_files/valid.yml', __dir__)) }

    describe 'when overrides passed' do
      subject { config.ignore(overrides) }

      describe 'when overrides are invalid' do
        let(:overrides) { { invalid: 'config' } }
        before { expect(config).to receive(:warn).with('Invalid --ignore value provided') }
        it { should eq(['CVE-123', 'CVE-456']) }
      end

      describe 'when overrides is nil' do
        let(:overrides) { nil }
        it { should eq(['CVE-123', 'CVE-456']) }
      end

      describe 'when overrides is an empty array' do
        let(:overrides) { [] }
        it { should eq(['CVE-123', 'CVE-456']) }
      end

      describe 'when overrides is a string' do
        let(:overrides) { 'cve-override1' }
        it { should eq([overrides]) }
      end

      describe 'when overrides are an array of strings' do
        let(:overrides) { ['cve-override1', 'cve-override2'] }
        it { should eq(overrides) }
      end
    end

    describe 'when overrides not passed' do
      subject { config.ignore }
      it { should eq(['CVE-123', 'CVE-456']) }
    end
  end
end
