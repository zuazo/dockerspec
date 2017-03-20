# CHANGELOG for Dockerspec

All notable changes to the [`dockerspec`](https://rubygems.org/gems/dockerspec/) RubyGem will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
[![Travis CI master Build Status](http://img.shields.io/travis/zuazo/dockerspec.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)

### Added in Unreleased
- Integrate with [rspec-retry](https://github.com/NoRedInk/rspec-retry) gem.
- Docker logs support ([issue #3](https://github.com/zuazo/dockerspec/issues/3), thanks [@axi43](https://github.com/axi43) for the idea).

### Changed in Unreleased
- Let user choose RSpec formatter ([issue #4](https://github.com/zuazo/dockerspec/issues/4), thanks [Luis Sagastume](https://github.com/zuazo/dockerspec/pull/4) for the help).

### Removed in Unreleased
- Drop Ruby `< 2.2` support.

### Fixed in Unreleased
- Be able to use os detection within test blocks ([issue #2](https://github.com/zuazo/dockerspec/issues/2), **special thanks to [Nan Liu](https://github.com/nanliu)** for his help and [his astonishing presentation](https://www.slideshare.net/NanLiu1/trust-but-verify-testing-with-docker-containers)).
- Use `Integer` instead of `Fixnum`.

### Improved in Unreleased
- `ItsContainer`: rename container_name variable to avoid confussion.

### Documentation Changes in Unreleased
- Document `dir` parameter in `Builder#build_from_string`.
- CHANGELOG: Follow "Keep a CHANGELOG".
- Add GitHub templates.
- README:
  - Document how to require the gem.
  - Add Presentations section.
  - Add a TOC.
  - Add documentation links.

## [0.3.0] - 2016-02-28
[![Travis CI 0.3.0 Build Status](http://img.shields.io/travis/zuazo/dockerspec/0.3.0.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)

### Breaking Changes in 0.3.0
- Enable `options[:rm]` by default.

### Added in 0.3.0
- Add Docker Compose support.
- Add Infrataster and Capybara support.
- Add `:wait` option to `docker_run` and `docker_compose`.
- Add `described_image` helper for `docker_run`.
- Support integer values with `have_expose` matcher.
- Make `require 'dockerspec'` optional.
- Add support for multiple testing engines.
- Add a `Configuration` class to setup the internal modularization.

### Fixed in 0.3.0
- Fix `:env` in `docker_run` with Serverspec.
- Fix *Must have id* error when building images from IDs with tags.

### Improved in 0.3.0
- Update RuboCop to `0.37`, fix new offenses.
- `Runner` classes split into `Engine::Base` and `Runner::Base`.
- Rename many classes.

### Documentation Changes in 0.3.0
- README:
  - Move the documentation below examples.
  - Add many examples.

## [0.2.0] - 2015-12-11
[![Travis CI 0.2.0 Build Status](http://img.shields.io/travis/zuazo/dockerspec/0.2.0.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)

### Added in 0.2.0
- Print Docker errors in a more readable format.

### Changed in 0.2.0
- Set some opinionated RSpec configurations.

### Fixed in 0.2.0
- Fix *undefined method* error in the outermost examples.

### Documentation Changes in 0.2.0
- Add examples for `#have_cmd` using string format.
- README:
  - Improve Ruby documentation.
  - Change gem badge to point to RubyGems.
  - Add Real-world examples section.

## 0.1.0 - 2015-12-09
[![Travis CI 0.1.0 Build Status](http://img.shields.io/travis/zuazo/dockerspec/0.1.0.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)

- Initial release of `dockerspec`.

[Unreleased]: https://github.com/zuazo/dockerspec/compare/0.3.0...HEAD
[0.3.0]: https://github.com/zuazo/dockerspec/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/zuazo/dockerspec/compare/0.1.0...0.2.0
