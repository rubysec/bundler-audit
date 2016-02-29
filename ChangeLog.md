### 0.5.0 / 2015-02-28

* Added {Bundler::Audit::Task}.
* Added {Bundler::Audit::Advisory#date}.
* Added {Bundler::Audit::Advisory#cve_id}.
* Added {Bundler::Audit::Advisory#osvdb_id}.
* Allow insecure gem sources (`http://` and `git://`), if they are hosted on a
  private network.

#### CLI

* Added the `--update` option to `bundle-audit check`.
* `bundle-audit update` now returns a non-zero exit status on error.
* `bundle-audit update` only updates `~/.local/share/ruby-advisory-db`, if it is a git
  repository.

### 0.4.0 / 2015-06-30

* Require ruby >= 1.9.3 due to i18n gem deprecating < 1.9.3.
* Added {Bundler::Audit::Advisory#osvdb}.
* Resolve the IP addresses of gem sources and ignore intranet gem sources.
  (PR #90)
* Use ISO8601 date format when querying the git timestamp of ruby-advisory-db.
  (PR #92)

#### CLI

* Print the CVE or OSVDB id.
* No longer print "Unpatched versions found!" when an insecure gem source
  is detected. (PR #84)

### 0.3.1 / 2014-04-20

* Added thor ~> 0.18 as a dependency.
* No longer rely on the vendored version of thor within bundler.
* Store the timestamp of when `data/ruby-advisory-db` was last updated in
  `data/ruby-advisory-db.ts`.
* Use `data/ruby-advisory-db.ts` instead of the creation time of the
  `dataruby-advisory-db` directory, which is always the install time
  of the rubygem.

### 0.3.0 / 2013-10-31

* Added {Bundler::Audit::Database.update!} which uses `git` to download
  [ruby-advisory-db] to `~/.local/share/ruby-advisory-db`.
* {Bundler::Audit::Database.path} now returns the path to either
  `~/.local/share/ruby-advisory-db` or the vendored copy, depending on which
  is more recent.

#### CLI

* Added the `bundle-audit update` sub-command.

### 0.2.0 / 2013-03-05

* Require RubyGems >= 1.8.0. Prior versions of RubyGems could not correctly
  parse approximate version requirements (`~> 1.2.3`).
* Updated the [ruby-advisory-db].
* Added {Bundler::Audit::Advisory#unaffected_versions}.
* Added {Bundler::Audit::Advisory#unaffected?}.
* Added {Bundler::Audit::Advisory#patched?}.
* Renamed `Advisory#cve` to {Bundler::Audit::Advisory#id}.

### 0.1.2 / 2013-02-17

* Require [bundler] ~> 1.2.
* Vendor a full copy of the [ruby-advisory-db].
* Added {Bundler::Audit::Advisory#path} for debugging purposes.
* Added {Bundler::Audit::Advisory#to_s} for debugging purposes.

#### CLI

* Simply parse the `Gemfile.lock` instead of loading the bundle (@grosser).
* Exit with non-zero status on failure (@grosser).

### 0.1.1 / 2013-02-12

* Fixed a Ruby 1.8 syntax error.

### Advisories

* Imported advisories from the [Ruby Advisory DB][ruby-advisory-db].
  * [CVE-2011-0739](http://www.osvdb.org/show/osvdb/70667)
  * [CVE-2012-2139](http://www.osvdb.org/show/osvdb/81631)
  * [CVE-2012-2140](http://www.osvdb.org/show/osvdb/81632)
  * [CVE-2012-267](http://osvdb.org/83077)
  * [CVE-2012-1098](http://osvdb.org/79726)
  * [CVE-2012-1099](http://www.osvdb.org/show/osvdb/79727)
  * [CVE-2012-2660](http://www.osvdb.org/show/osvdb/82610)
  * [CVE-2012-2661](http://www.osvdb.org/show/osvdb/82403)
  * [CVE-2012-3424](http://www.osvdb.org/show/osvdb/84243)
  * [CVE-2012-3463](http://osvdb.org/84515)
  * [CVE-2012-3464](http://www.osvdb.org/show/osvdb/84516)
  * [CVE-2012-3465](http://www.osvdb.org/show/osvdb/84513)

### CLI

* If the advisory has no `patched_versions`, recommend removing or disabling
  the gem until a patch is made available.

### 0.1.0 / 2013-02-11

* Initial release:
  * Checks for vulnerable versions of gems in `Gemfile.lock`.
  * Prints advisory information.
  * Does not require a network connection.

#### Advisories

* [CVE-2013-0269](http://direct.osvdb.org/show/osvdb/90074)
* [CVE-2013-0263](http://osvdb.org/show/osvdb/89939)
* [CVE-2013-0155](http://osvdb.org/show/osvdb/89025)
* [CVE-2013-0156](http://osvdb.org/show/osvdb/89026)
* [CVE-2013-0276](http://direct.osvdb.org/show/osvdb/90072)
* [CVE-2013-0277](http://direct.osvdb.org/show/osvdb/90073)
* [CVE-2013-0333](http://osvdb.org/show/osvdb/89594)

[bundler]: http://gembundler.com/
[ruby-advisory-db]: https://github.com/rubysec/ruby-advisory-db#readme
