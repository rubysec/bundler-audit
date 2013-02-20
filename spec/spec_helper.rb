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

  def advisories_for_gem(gem, database_options={})
    subject = Database.new(database_options)
    advisories = []

    subject.check_gem(gem) do |advisory|
      advisories << advisory
    end
    advisories
  end
end

include Bundler::Audit
