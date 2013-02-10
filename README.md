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
