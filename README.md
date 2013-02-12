# bundler-audit

* [Homepage](https://github.com/postmodern/bundler-audit#readme)
* [Issues](https://github.com/postmodern/bundler-audit/issues)
* [Documentation](http://rubydoc.info/gems/bundler-audit/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

Patch-level verification for [Bundler][bundler].

## Features

* Checks for vulnerable versions of gems in `Gemfile.lock`.
* Prints advisory information.
* Does not require a network connection.

## Synopsis

Audit a projects `Gemfile.lock`:

    $ bundle-audit
    Name: rack
    Version: 1.4.4
    CVE: 2013-0263
    Criticality: High
    URL: http://osvdb.org/show/osvdb/89939
    Title: Rack Rack::Session::Cookie Function Timing Attack Remote Code Execution 
    Patched Versions: ~> 1.1.6, ~> 1.2.8, ~> 1.3.10, ~> 1.4.5, >= 1.5.2
    
    Name: json
    Version: 1.7.6
    CVE: 2013-0269
    Criticality: High
    URL: http://direct.osvdb.org/show/osvdb/90074
    Title: Ruby on Rails JSON Gem Arbitrary Symbol Creation Remote DoS
    Patched Versions: ~> 1.5.4, ~> 1.6.7, >= 1.7.7
    
    Name: rails
    Version: 3.2.10
    CVE: 2013-0155
    Criticality: High
    URL: http://osvdb.org/show/osvdb/89025
    Title: Ruby on Rails Active Record JSON Parameter Parsing Query Bypass 
    Patched Versions: ~> 3.0.19, ~> 3.1.10, >= 3.2.11
    
    Name: rails
    Version: 3.2.10
    CVE: 2013-0156
    Criticality: High
    URL: http://osvdb.org/show/osvdb/89026
    Title: Ruby on Rails params_parser.rb Action Pack Type Casting Parameter Parsing
    Remote Code Execution 
    Patched Versions: ~> 2.3.15, ~> 3.0.19, ~> 3.1.10, >= 3.2.11
    
    Name: rails
    Version: 3.2.10
    CVE: 2013-0276
    Criticality: Medium
    URL: http://direct.osvdb.org/show/osvdb/90072
    Title: Ruby on Rails Active Record attr_protected Method Bypass
    Patched Versions: ~> 2.3.17, ~> 3.1.11, >= 3.2.12
    
    Unpatched versions found!

## Requirements

* [bundler] ~> 1.0

## Install

    $ gem install bundler-audit

## Contributing Advisories

For an advisory to be added to the Database, it must match the following
format:

* Must be a YAML file.
* Must be placed in the `data/bundler/audit/$gem/` directory.
* Must be named after the CVE number (`2013-0156.yml`):
  * Must contain a URL to the [OSVDB] advisory.
  * Must contain the `title` and `description`.
  * Must contain the `title` and `description`.
  * Must contain the CVSSv2 Score.
  * Must contain the patched versions ranges.

### Example

    ---
    url: http://osvdb.org/show/osvdb/89026
    title: |
      Ruby on Rails params_parser.rb Action Pack Type Casting Parameter Parsing
      Remote Code Execution 
    
    description: |
      Ruby on Rails contains a flaw in params_parser.rb of the Action Pack.
      The issue is triggered when a type casting error occurs during the parsing
      of parameters. This may allow a remote attacker to potentially execute
      arbitrary code.
    
    cvss_v2: 10.0

    patched_versions:
      - "~> 2.3.15"
      - "~> 3.0.19"
      - "~> 3.1.10"
      - ">= 3.2.11"

## License: GNU GPL v3+

[bundler]: https://github.com/carlhuda/bundler#readme

[OSVDB]: http://osvdb.org/
