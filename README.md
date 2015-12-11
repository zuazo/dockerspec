# Dockerspec
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg?style=flat)](http://www.rubydoc.info/gems/dockerspec)
[![GitHub](http://img.shields.io/badge/github-zuazo/dockerspec-blue.svg?style=flat)](https://github.com/zuazo/dockerspec)
[![License](https://img.shields.io/github/license/zuazo/dockerspec.svg?style=flat)](#license-and-author)

[![Gem Version](https://badge.fury.io/rb/dockerspec.svg)](https://rubygems.org/gems/dockerspec)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/dockerspec.svg?style=flat)](https://gemnasium.com/zuazo/dockerspec)
[![Code Climate](http://img.shields.io/codeclimate/github/zuazo/dockerspec.svg?style=flat)](https://codeclimate.com/github/zuazo/dockerspec)
[![Travis CI Build Status](http://img.shields.io/travis/zuazo/dockerspec/0.2.0.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)
[![Circle CI Build Status](https://circleci.com/gh/zuazo/dockerspec/tree/master.svg?style=shield)](https://circleci.com/gh/zuazo/dockerspec/tree/master)
[![Coverage Status](http://img.shields.io/coveralls/zuazo/dockerspec/0.2.0.svg?style=flat)](https://coveralls.io/r/zuazo/dockerspec?branch=0.2.0)
[![Inline docs](http://inch-ci.org/github/zuazo/dockerspec.svg?branch=master&style=flat)](http://inch-ci.org/github/zuazo/dockerspec)

## Description

A small Ruby Gem to run RSpec and [Serverspec](http://serverspec.org/) tests against Dockerfiles or Docker images easily.

This gem is designed to work out of the box on [Travis CI](https://travis-ci.org/), [CircleCI](https://circleci.com/) and other similar CI environments.

## Requirements

* Ruby `2` or higher.
* Recommended Docker `1.7` or higher.

## Installation

You can install the Ruby Gem with:

```
$ gem install dockerspec
```

Or you can add this line to the *Gemfile* of your application:

```ruby
gem 'dockerspec', '~> 0.2.0'
```

And then execute:

```
$ bundle
```

**Warning:** As the gem is in its early development stages, [the API is very likely to break between minor versions](http://semver.org/).

## Documentation

- [`docker_build`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/RSpecResources#docker_build-instance_method)
  - [*Docker Build* helpers](http://www.rubydoc.info/gems/dockerspec/Dockerspec/Builder/ConfigHelpers)
- [`docker_run`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/Serverspec/RSpecResources#docker_run-instance_method)
  - [*Docker Run* Serverspec resource types](http://serverspec.org/resource_types.html)

## Usage Examples

### Run Tests Against a Dockerfile in the Current Directory

```ruby
require 'dockerspec'
require 'dockerspec/serverspec'

describe 'My Dockerfile' do
  describe docker_build('.', tag: 'myapp') do

    it { should have_maintainer /John Doe/ }
    it { should have_cmd ['/bin/dash'] }
    it { should have_expose '80' }
    it { should have_user 'nobody' }

    describe docker_run('myapp') do
      describe file('/etc/httpd.conf') do
        it { should be_file }
        it { should contain 'ServerName www.example.jp' }
      end

      describe service('httpd') do
        it { should be_enabled }
        it { should be_running }
      end
    end
  end
end
```

See the documentation above for more examples.

### Real-world Examples

* [`alpine-tor`](https://github.com/zuazo/alpine-tor-docker) image ([*spec/*](https://github.com/zuazo/alpine-tor-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/alpine-tor-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/alpine-tor-docker/tree/master/.travis.yml)).

### Prepare Your Ruby Environment

If you are new to Ruby, you can follow these steps:

#### 1. Create a **Gemfile**:

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'dockerspec', '~> 0.2.0'
```

#### 2. Create the *spec/* directory:

```
$ mkdir spec
```

#### 3. Add your tests to a file with the *spec/myapp_spec.rb* format:

```ruby
# spec/myapp_spec.rb

require 'dockerspec'
require 'dockerspec/serverspec'

describe 'My Dockerfile' do
  describe docker_build('.', tag: 'myapp') do
    # [...]
    describe docker_run('myapp') do
      # [...]
    end
  end
end
```

#### 4. Install the gems:

```
$ bundle
```

#### 5. Run the tests:

```
$ bundle exec rspec
```

### Travis CI Configuration Example

**.travis.yml** file example:

```yaml
language: ruby

rvm:
- 2.0.0
- 2.1
- 2.2

sudo: required

services: docker

script: travis_retry bundle exec rspec
```

### CircleCI Configuration Example

**circle.yml** file example:

```yaml
machine:
  services:
  - docker
  ruby:
    version: 2.2.3

test:
  override:
  - bundle exec rspec
```

## Testing

See [TESTING.md](https://github.com/zuazo/dockerspec/blob/master/TESTING.md).

## Contributing

Please do not hesitate to [open an issue](https://github.com/zuazo/dockerspec/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/zuazo/dockerspec/blob/master/CONTRIBUTING.md).

## TODO

See [TODO.md](https://github.com/zuazo/dockerspec/blob/master/TODO.md).

## License and Author

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Copyright:**       | Copyright (c) 2015 Xabier de Zuazo
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
