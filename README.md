# bundler-audit

* [Homepage](https://github.com/rubysec/bundler-audit#readme)
* [Issues](https://github.com/rubysec/bundler-audit/issues)
* [Documentation](http://rubydoc.info/gems/bundler-audit/frames)
* [Email](mailto:rubysec.mod3 at gmail.com)
* [![Build Status](https://travis-ci.org/rubysec/bundler-audit.png)](https://travis-ci.org/rubysec/bundler-audit)
* [![Code Climate](https://codeclimate.com/github/rubysec/bundler-audit.png)](https://codeclimate.com/github/rubysec/bundler-audit)

## Description

Patch-level verification for [Bundler][bundler].

## Features

* Checks for vulnerable versions of gems in `Gemfile.lock`.
* Checks for insecure gem sources (`http://`).
* Allows ignoring certain advisories that have been manually worked around.
* Prints advisory information.
* Does not require a network connection.

## Synopsis

Audit a projects `Gemfile.lock`:

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

## Requirements

* [bundler] ~> 1.2

## Install

    $ gem install bundler-audit

## License

Copyright (c) 2013 Hal Brodigan (postmodern.mod3 at gmail.com)

bundler-audit is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

bundler-audit is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with bundler-audit.  If not, see <http://www.gnu.org/licenses/>.

[bundler]: https://github.com/carlhuda/bundler#readme

[OSVDB]: http://osvdb.org/
