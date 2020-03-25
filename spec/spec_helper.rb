require 'simplecov'
SimpleCov.start

require 'rspec'
require 'bundler/audit/version'

module Fixtures
  ROOT = File.expand_path('../fixtures',__FILE__)

  DATABASE_PATH = File.join(ROOT,'database')

  DATABASE_COMMIT = '89cdde9a725bb6f8a483bca97c5da344e060ac61'

  TMP_DIR = File.expand_path('../tmp',__FILE__)

  def self.join(*paths)
    File.join(ROOT,*paths)
  end
end

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
  include Helpers

  config.before(:suite) do
    unless File.directory?(Fixtures::DATABASE_PATH)
      system 'git', 'clone', '--quiet', Bundler::Audit::Database::URL,
                                        Fixtures::DATABASE_PATH
    end

    Dir.chdir(Fixtures::DATABASE_PATH) do
      system 'git', 'reset', '--hard', Fixtures::DATABASE_COMMIT
    end

    FileUtils.mkdir_p(Fixtures::TMP_DIR)
  end

  config.before(:each) do
    stub_const("Bundler::Audit::Database::DEFAULT_PATH",Fixtures::DATABASE_PATH)
  end
end
