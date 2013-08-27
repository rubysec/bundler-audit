require 'spec_helper'

describe "CLI" do
  include Helpers

  let(:command) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundle-audit'))
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print a warning" do
      subject.should include("Unpatched versions found!")
    end

    it "should print advisory information for the vulnerable gems" do
      expect = %{
Name: actionpack
Version: 3.2.10
Advisory: OSVDB-91452
Criticality: Medium
URL: http://www.osvdb.org/show/osvdb/91452
Title: XSS vulnerability in sanitize_css in Action Pack
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

Name: actionpack
Version: 3.2.10
Advisory: OSVDB-91454
Criticality: Medium
URL: http://osvdb.org/show/osvdb/91454
Title: XSS Vulnerability in the `sanitize` helper of Ruby on Rails
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

Name: actionpack
Version: 3.2.10
Advisory: OSVDB-89026
Criticality: High
URL: http://osvdb.org/show/osvdb/89026
Title: Ruby on Rails params_parser.rb Action Pack Type Casting Parameter Parsing Remote Code Execution
Solution: upgrade to ~> 2.3.15, ~> 3.0.19, ~> 3.1.10, >= 3.2.11

Name: activerecord
Version: 3.2.10
Advisory: OSVDB-91453
Criticality: High
URL: http://osvdb.org/show/osvdb/91453
Title: Symbol DoS vulnerability in Active Record
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

Name: activerecord
Version: 3.2.10
Advisory: OSVDB-90072
Criticality: Medium
URL: http://direct.osvdb.org/show/osvdb/90072
Title: Ruby on Rails Active Record attr_protected Method Bypass
Solution: upgrade to ~> 2.3.17, ~> 3.1.11, >= 3.2.12

Name: activerecord
Version: 3.2.10
Advisory: OSVDB-89025
Criticality: High
URL: http://osvdb.org/show/osvdb/89025
Title: Ruby on Rails Active Record JSON Parameter Parsing Query Bypass
Solution: upgrade to ~> 2.3.16, ~> 3.0.19, ~> 3.1.10, >= 3.2.11

Name: activesupport
Version: 3.2.10
Advisory: OSVDB-91451
Criticality: High
URL: http://www.osvdb.org/show/osvdb/91451
Title: XML Parsing Vulnerability affecting JRuby users
Solution: upgrade to ~> 3.1.12, >= 3.2.13

Unpatched versions found!
      }.strip.split "\n\n"

      subject.strip.split("\n\n").should =~ expect
    end
  end

  context "when auditing a bundle with ignored gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    let(:command) do
      File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundle-audit -i OSVDB-89026'))
    end

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should not print advisory information for ignored gem" do
      subject.should_not include("OSVDB-89026")
    end
  end

  context "when auditing a bundle with insecure sources" do
    let(:bundle)    { 'insecure_sources' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print warnings about insecure sources" do
      subject.should include(%{
Insecure Source URI found: git://github.com/rails/jquery-rails.git
Insecure Source URI found: http://rubygems.org/
      }.strip)
    end
  end

  context "when auditing a secure bundle" do
    let(:bundle)    { 'secure' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(command) }
    end

    it "should print nothing when everything is fine" do
      subject.strip.should == "No unpatched versions found"
    end
  end
end
