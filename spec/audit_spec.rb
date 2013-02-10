require 'spec_helper'
require 'bundler/audit'

describe Bundler::Audit do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
