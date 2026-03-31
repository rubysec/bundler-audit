require 'spec_helper'
require 'bundler/audit/scanner'

describe "gems.rb and gems.locked support" do
  let(:fixtures_dir) { File.join(__dir__, 'fixtures') }
  
  describe Bundler::Audit::Scanner do
    context "when only gems.locked exists" do
      let(:bundle_dir) { File.join(fixtures_dir, 'gems_locked_only') }
      
      before do
        FileUtils.mkdir_p(bundle_dir)
        File.write(File.join(bundle_dir, 'gems.locked'), <<~LOCKFILE)
          GEM
            remote: https://rubygems.org/
            specs:
              thor (1.1.0)
          
          PLATFORMS
            ruby
          
          DEPENDENCIES
            thor
          
          BUNDLED WITH
             2.2.33
        LOCKFILE
      end
      
      after do
        FileUtils.rm_rf(bundle_dir)
      end
      
      it "should detect and use gems.locked file" do
        scanner = described_class.new(bundle_dir)
        expect(scanner.lockfile).to be_a(Bundler::LockfileParser)
        expect(scanner.lockfile.specs.map(&:name)).to include('thor')
      end
    end
    
    context "when both Gemfile.lock and gems.locked exist" do
      let(:bundle_dir) { File.join(fixtures_dir, 'both_lock_files') }
      
      before do
        FileUtils.mkdir_p(bundle_dir)
        File.write(File.join(bundle_dir, 'Gemfile.lock'), <<~LOCKFILE)
          GEM
            remote: https://rubygems.org/
            specs:
              rake (13.0.6)
          
          PLATFORMS
            ruby
          
          DEPENDENCIES
            rake
          
          BUNDLED WITH
             2.2.33
        LOCKFILE
        
        File.write(File.join(bundle_dir, 'gems.locked'), <<~LOCKFILE)
          GEM
            remote: https://rubygems.org/
            specs:
              thor (1.1.0)
          
          PLATFORMS
            ruby
          
          DEPENDENCIES
            thor
          
          BUNDLED WITH
             2.2.33
        LOCKFILE
      end
      
      after do
        FileUtils.rm_rf(bundle_dir)
      end
      
      it "should prioritize Gemfile.lock over gems.locked" do
        scanner = described_class.new(bundle_dir)
        expect(scanner.lockfile.specs.map(&:name)).to include('rake')
        expect(scanner.lockfile.specs.map(&:name)).not_to include('thor')
      end
    end
    
    context "when gems.rb exists but gems.locked is missing" do
      let(:bundle_dir) { File.join(fixtures_dir, 'gems_rb_no_lock') }
      
      before do
        FileUtils.mkdir_p(bundle_dir)
        File.write(File.join(bundle_dir, 'gems.rb'), <<~GEMFILE)
          source 'https://rubygems.org'
          gem 'thor'
        GEMFILE
      end
      
      after do
        FileUtils.rm_rf(bundle_dir)
      end
      
      it "should provide helpful error message" do
        expect {
          described_class.new(bundle_dir)
        }.to raise_error(Bundler::GemfileLockNotFound, /gems.rb found but gems.locked is missing/)
      end
    end
    
    context "when Gemfile exists but Gemfile.lock is missing" do
      let(:bundle_dir) { File.join(fixtures_dir, 'gemfile_no_lock') }
      
      before do
        FileUtils.mkdir_p(bundle_dir)
        File.write(File.join(bundle_dir, 'Gemfile'), <<~GEMFILE)
          source 'https://rubygems.org'
          gem 'thor'
        GEMFILE
      end
      
      after do
        FileUtils.rm_rf(bundle_dir)
      end
      
      it "should provide helpful error message" do
        expect {
          described_class.new(bundle_dir)
        }.to raise_error(Bundler::GemfileLockNotFound, /Gemfile found but Gemfile.lock is missing/)
      end
    end
    
    context "when neither gemfile nor lock files exist" do
      let(:bundle_dir) { File.join(fixtures_dir, 'empty_dir') }
      
      before do
        FileUtils.mkdir_p(bundle_dir)
      end
      
      after do
        FileUtils.rm_rf(bundle_dir)
      end
      
      it "should provide standard error message" do
        expect {
          described_class.new(bundle_dir)
        }.to raise_error(Bundler::GemfileLockNotFound, /neither Gemfile.lock nor gems.locked found/)
      end
    end
  end
end