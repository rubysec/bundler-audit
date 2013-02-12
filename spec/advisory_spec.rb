require 'spec_helper'
require 'bundler/audit/database'
require 'bundler/audit/advisory'

describe Bundler::Audit::Advisory do
  let(:root) { Bundler::Audit::Database::PATH }
  let(:gem)  { 'rails' }
  let(:cve)  { '2013-0156' }
  let(:path) { File.join(root,gem,"#{cve}.yml") }

  describe "load" do
    let(:data) { YAML.load_file(path) }

    subject { described_class.load(path) }

    its(:cve)   { should == cve           }
    its(:url)   { should == data['url']   }
    its(:title) { should == data['title'] }
    its(:description) { should == data['description'] }

    describe "#patched_versions" do
      subject { described_class.load(path).patched_versions }

      it "should all be Gem::Requirement objects" do
        subject.all? { |version|
          version.should be_kind_of(Gem::Requirement)
        }.should be_true
      end

      it "should parse the versions" do
        subject.map(&:to_s).should == data['patched_versions']
      end
    end
  end

  describe "#vulnerable?" do
    subject { described_class.load(path) }

    context "when passed a version that matches one patched_version" do
      let(:version) { Gem::Version.new('3.1.11') }

      it "should return false" do
        subject.vulnerable?(version).should be_false
      end
    end

    context "when passed a version that matches no patched_version" do
      let(:version) { Gem::Version.new('3.1.9') }

      it "should return true" do
        subject.vulnerable?(version).should be_true
      end
    end
  end
end
