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

## Requirements

* [bundler] ~> 1.0

## Install

    $ gem install bundler-audit

## Contributing Advisories

For an advisory to be added to the Database, it must match the following
format:

* Be a YAML file.
* Placed in the `data/bundler/audit/$gem/` directory.
* Named after the CVE number (`2013-0156.yml`):
  * Containing a URL to [OSVDB].
  * Containing `title` and `description`.
  * Containing the versions ranges which are not effected by the advisory.

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
