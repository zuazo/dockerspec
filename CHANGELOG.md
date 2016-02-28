# CHANGELOG for Dockerspec

This file is used to list changes made in each version of `dockerspec` Ruby Gem.

## 0.3.0 (2016-02-28)

### Breaking Changes on 0.3.0

* Enable `options[:rm]` by default.

### New Features on 0.3.0

* Add Docker Compose support.
* Add Infrataster and Capybara support.
* Add `:wait` option to `docker_run` and `docker_compose`.
* Add `described_image` helper for `docker_run`.
* Support integer values with `have_expose` matcher.
* Make `require 'dockerspec'` optional.

### Fixes on 0.3.0

* Fix `:env` in `docker_run` with Serverspec.
* Fix *Must have id* error when building images from IDs with tags.

### Improvements on 0.3.0

* Update RuboCop to `0.37`, fix new offenses.
* `Runner` classes split into `Engine::Base` and `Runner::Base`.
* Add support for multiple testing engines.
* Add a `Configuration` class to setup the internal modularization.
* Rename many classes.

### Documentation Changes on 0.3.0

* README:
 * Move the documentation below examples.
 * Add many examples.

## 0.2.0 (2015-12-11)

### New Features on 0.2.0

* Set some opinionated RSpec configurations.
* Print Docker errors in a more readable format.

### Fixes on 0.2.0

* Fix *undefined method* error in the outermost examples.

### Documentation Changes on 0.2.0

* Add examples for `#have_cmd` using string format.
* README:
 * Improve Ruby documentation.
 * Change gem badge to point to RubyGems.
 * Add Real-world examples section.

## 0.1.0 (2015-12-09)

* Initial release of `dockerspec`.
