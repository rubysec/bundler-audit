require 'rspec'
require 'bundler/audit/version'

module Helpers
  def sh(command, options={})
    Bundler.with_clean_env do
      result = `#{command} 2>&1`
      raise "FAILED #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end
  end

  def decolorize(string)
    string.gsub(/\e\[\d+m/, "")
  end
end

include Bundler::Audit

RSpec.configure do |config|
  config.before(:suite) do
    unless File.exist?("spec/fixtures/ruby-advisory-db/gems")
      FileUtils.mkdir_p("spec/fixtures")

      Dir.chdir("spec/fixtures") do
        system "git clone git://github.com/rubysec/ruby-advisory-db.git"
      end
    end
  end

  config.before do
    Bundler::Audit::Database.stub(path: File.expand_path(File.join(File.dirname(__FILE__),'fixtures','ruby-advisory-db','gems')))
  end
end
