# bundler-audit

* [Homepage](https://github.com/rubysec/bundler-audit#readme)
* [Issues](https://github.com/rubysec/bundler-audit/issues)
* [Documentation](http://rubydoc.info/gems/bundler-audit/frames)
* [Email](mailto:rubysec.mod3 at gmail.com)
* [![Build Status](https://travis-ci.org/rubysec/bundler-audit.svg)](https://travis-ci.org/rubysec/bundler-audit)
* [![Code Climate](https://codeclimate.com/github/rubysec/bundler-audit.svg)](https://codeclimate.com/github/rubysec/bundler-audit)

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

    $ bundle-audit
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

Update the [ruby-advisory-db] that `bundle-audit` uses:

    $ bundle-audit update
    Updating ruby-advisory-db ...
    remote: Counting objects: 44, done.
    remote: Compressing objects: 100% (24/24), done.
    remote: Total 39 (delta 19), reused 29 (delta 10)
    Unpacking objects: 100% (39/39), done.
    From https://github.com/rubysec/ruby-advisory-db
     * branch            master     -> FETCH_HEAD
    Updating 5f8225e..328ca86
    Fast-forward
     CONTRIBUTORS.md                    |  1 +
     gems/actionmailer/OSVDB-98629.yml  | 17 +++++++++++++++++
     gems/cocaine/OSVDB-98835.yml       | 15 +++++++++++++++
     gems/fog-dragonfly/OSVDB-96798.yml | 13 +++++++++++++
     gems/sounder/OSVDB-96278.yml       | 13 +++++++++++++
     gems/wicked/OSVDB-98270.yml        | 14 ++++++++++++++
     6 files changed, 73 insertions(+)
     create mode 100644 gems/actionmailer/OSVDB-98629.yml
     create mode 100644 gems/cocaine/OSVDB-98835.yml
     create mode 100644 gems/fog-dragonfly/OSVDB-96798.yml
     create mode 100644 gems/sounder/OSVDB-96278.yml
     create mode 100644 gems/wicked/OSVDB-98270.yml
    ruby-advisory-db: 64 advisories

Update the [ruby-advisory-db] and check `Gemfile.lock` (useful for CI runs):

    $ bundle-audit check --update

Ignore specific advisories:

    $ bundle-audit check --ignore OSVDB-108664

Rake task:

```ruby
require_relative 'lib/bundler/audit/task'
Bundler::Audit::Task.new

task default: 'bundle:audit'
```

## Requirements

* [Ruby] >= 1.9.3
* [RubyGems] >= 1.8
* [thor] ~> 0.18
* [bundler] ~> 1.2

## Install

    $ gem install bundler-audit

## License

Copyright (c) 2013-2016 Hal Brodigan (postmodern.mod3 at gmail.com)

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

[Ruby]: https://ruby-lang.org
[RubyGems]: https://rubygems.org
[thor]: http://whatisthor.com/
[bundler]: https://github.com/carlhuda/bundler#readme

[OSVDB]: http://osvdb.org/
[ruby-advisory-db]: https://github.com/rubysec/ruby-advisory-db
