require 'simplecov'
SimpleCov.start

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

  def mocked_user_path
    File.expand_path('../../tmp/ruby-advisory-db', __FILE__)
  end

  def expect_update_to_clone_repo!
    expect(Bundler::Audit::Database).
      to receive(:system).
      with('git', 'clone', Bundler::Audit::Database::VENDORED_PATH, mocked_user_path).
      and_call_original
  end

  def expect_update_to_update_repo!
    expect(Bundler::Audit::Database).
      to receive(:system).
      with('git', 'pull', 'origin', 'master').
      and_call_original
  end

  def fake_a_commit_in_the_user_repo
    Dir.chdir(mocked_user_path) do
      system 'git', 'commit', '--allow-empty', '-m', 'Dummy commit.'
    end
  end

  def roll_user_repo_back(num_commits)
    Dir.chdir(mocked_user_path) do
      system 'git', 'reset', '--hard', "HEAD~#{num_commits}"
    end
  end
end

include Bundler::Audit

RSpec.configure do |config|
  include Helpers

  config.before(:each) do
    stub_const("Bundler::Audit::Database::URL", Bundler::Audit::Database::VENDORED_PATH)
    stub_const("Bundler::Audit::Database::USER_PATH", mocked_user_path)
    FileUtils.rm_rf(mocked_user_path) if File.exist?(mocked_user_path)
  end
end
