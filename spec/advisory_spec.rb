require 'spec_helper'
require 'bundler/audit/database'
require 'bundler/audit/advisory'

describe Bundler::Audit::Advisory do
  let(:root) { Bundler::Audit::Database::VENDORED_PATH }
  let(:gem)  { 'actionpack' }
  let(:id)   { 'OSVDB-84243' }
  let(:path) { File.join(root,'gems',gem,"#{id}.yml") }

  describe "load" do
    let(:data) { YAML.load_file(path) }

    subject { described_class.load(path) }

    its(:id)          { should == id                  }
    its(:url)         { should == data['url']         }
    its(:title)       { should == data['title']       }
    its(:cvss_v2)     { should == data['cvss_v2']     }
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

  describe "#criticality" do
    context "when cvss_v2 is between 0.0 and 3.3" do
      before { subject.stub(:cvss_v2).and_return(3.3) }

      its(:criticality) { should == :low }
    end

    context "when cvss_v2 is between 3.3 and 6.6" do
      before { subject.stub(:cvss_v2).and_return(6.6) }

      its(:criticality) { should == :medium }
    end

    context "when cvss_v2 is between 6.6 and 10.0" do
      before { subject.stub(:cvss_v2).and_return(10.0) }

      its(:criticality) { should == :high }
    end
  end

  describe "#unaffected?" do
    subject { described_class.load(path) }

    context "when passed a version that matches one unaffected version" do
      let(:version) { Gem::Version.new('2.3.10') }

      it "should return true" do
        subject.unaffected?(version).should be_true
      end
    end

    context "when passed a version that matches no unaffected version" do
      let(:version) { Gem::Version.new('3.0.9') }

      it "should return false" do
        subject.unaffected?(version).should be_false
      end
    end
  end

  describe "#patched?" do
    subject { described_class.load(path) }

    context "when passed a version that matches one patched version" do
      let(:version) { Gem::Version.new('3.1.11') }

      it "should return true" do
        subject.patched?(version).should be_true
      end
    end

    context "when passed a version that matches no patched version" do
      let(:version) { Gem::Version.new('2.9.0') }

      it "should return false" do
        subject.patched?(version).should be_false
      end
    end
  end

  describe "#vulnerable?" do
    subject { described_class.load(path) }

    context "when passed a version that matches one patched version" do
      let(:version) { Gem::Version.new('3.1.11') }

      it "should return false" do
        subject.vulnerable?(version).should be_false
      end
    end

    context "when passed a version that matches no patched version" do
      let(:version) { Gem::Version.new('2.9.0') }

      it "should return true" do
        subject.vulnerable?(version).should be_true
      end

      context "when unaffected_versions is not empty" do
        subject { described_class.load(path) }

        context "when passed a version that matches one unaffected version" do
          let(:version) { Gem::Version.new('2.3.12') }

          it "should return false" do
            subject.vulnerable?(version).should be_false
          end
        end

        context "when passed a version that matches no unaffected version" do
          let(:version) { Gem::Version.new('1.2.3') }

          it "should return true" do
            subject.vulnerable?(version).should be_true
          end
        end
      end
    end
  end
end
