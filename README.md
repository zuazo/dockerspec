# Dockerspec
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg?style=flat)](http://www.rubydoc.info/gems/dockerspec)
[![GitHub](http://img.shields.io/badge/github-zuazo/dockerspec-blue.svg?style=flat)](https://github.com/zuazo/dockerspec)
[![License](https://img.shields.io/github/license/zuazo/dockerspec.svg?style=flat)](#license-and-author)

[![Gem Version](https://badge.fury.io/rb/dockerspec.svg)](https://rubygems.org/gems/dockerspec)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/dockerspec.svg?style=flat)](https://gemnasium.com/zuazo/dockerspec)
[![Code Climate](http://img.shields.io/codeclimate/github/zuazo/dockerspec.svg?style=flat)](https://codeclimate.com/github/zuazo/dockerspec)
[![Travis CI Build Status](http://img.shields.io/travis/zuazo/dockerspec/0.4.1.svg?style=flat)](https://travis-ci.org/zuazo/dockerspec)
[![Circle CI Build Status](https://circleci.com/gh/zuazo/dockerspec/tree/master.svg?style=shield)](https://circleci.com/gh/zuazo/dockerspec/tree/master)
[![Coverage Status](http://img.shields.io/coveralls/zuazo/dockerspec/0.4.1.svg?style=flat)](https://coveralls.io/github/zuazo/dockerspec?branch=0.4.1)
[![Inline docs](http://inch-ci.org/github/zuazo/dockerspec.svg?branch=master&style=flat)](http://inch-ci.org/github/zuazo/dockerspec)

A small Ruby Gem to run RSpec, [Serverspec](http://serverspec.org/), [Infrataster](https://github.com/ryotarai/infrataster) and [Capybara](http://jnicklas.github.io/capybara/) tests against Dockerfiles or Docker images easily.

This gem is designed to work out of the box on [Travis CI](https://travis-ci.org/), [CircleCI](https://circleci.com/) and other similar CI environments.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
  - [Presentations](#presentations)
- [Usage Examples](#usage-examples)
  - [Run Tests Against a Dockerfile in the Current Directory](#run-tests-against-a-dockerfile-in-the-current-directory)
  - [Run Tests Against Docker Compose](#run-tests-against-docker-compose)
  - [Checking Container Logs](#checking-container-logs)
  - [Retrying Tests That Fail Temporarily](#retrying-tests-that-fail-temporarily)
  - [Run HTTP Tests Using Infrataster](#run-http-tests-using-infrataster)
  - [Run HTTP Tests Using Capybara](#run-http-tests-using-capybara)
  - [Run Database Tests Using `infrataster-plugin-mysql` Gem with Docker Compose](#run-database-tests-using-infrataster-plugin-mysql-gem-with-docker-compose)
  - [Run Different Tests on Each Platform](#run-different-tests-on-each-platform)
  - [Real-world Examples](#real-world-examples)
  - [Prepare Your Ruby Environment](#prepare-your-ruby-environment)
  - [Travis CI Configuration Example](#travis-ci-configuration-example)
  - [CircleCI Configuration Example](#circleci-configuration-example)
- [Testing](#testing)
- [Contributing](#contributing)
- [TODO](#todo)
- [License and Author](#license-and-author)

## Requirements

* Ruby `2.2` or higher.
* Recommended Docker `1.7` or higher.

## Installation

You can install the Ruby Gem with:

```
$ gem install dockerspec
```

Or you can add this line to the *Gemfile* of your application:

```ruby
gem 'dockerspec', '~> 0.4.1'
```

And then execute:

```
$ bundle
```

**Warning:** As the gem is in its early development stages, [the API is very likely to break between minor versions](http://semver.org/).

## Documentation

- Latest release documentation: http://www.rubydoc.info/gems/dockerspec
- Master unreleased documentation: http://www.rubydoc.info/github/zuazo/dockerspec

Specific documentation sections for resources or functions that can be used to generate test cases:

- [`docker_build`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/RSpec/Resources#docker_build-instance_method)
  - [*Docker Build* helpers](http://www.rubydoc.info/gems/dockerspec/Dockerspec/Builder/ConfigHelpers)
- [`docker_run`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/RSpec/Resources#docker_run-instance_method)
  - [*Docker Run* helpers](http://www.rubydoc.info/gems/dockerspec/Dockerspec/Runner/ConfigHelpers)
  - [*Docker Run* Serverspec resource types](http://serverspec.org/resource_types.html)
  - [Infrataster Resources](http://www.rubydoc.info/gems/infrataster#Resources)
  - [Capybara DSL](http://www.rubydoc.info/gems/capybara#The_DSL)
- [`docker_compose`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/RSpec/Resources#docker_compose-instance_method)
  - [`its_container`](http://www.rubydoc.info/gems/dockerspec/Dockerspec/RSpec/Resources#its_container-instance_method)

### Presentations

Apart from the official documentation, [Nan Liu](https://github.com/nanliu) presented a talk for [Portland Docker user group](https://www.meetup.com/Docker-Portland-OR/events/236739986/) regarding how to use Dockerspec in a container:

- [Trust, but verify | Testing with Docker Containers](http://www.slideshare.net/NanLiu1/trust-but-verify-testing-with-docker-containers)

<a href="https://www.slideshare.net/NanLiu1/trust-but-verify-testing-with-docker-containers">
  <img src="https://i.gyazo.com/fe45a36c2e329af317482c280a09dfab.png" alt="Trust, but verify | Testing with Docker Containers" width="300px">
</a>

## Usage Examples

### Run Tests Against a Dockerfile in the Current Directory

```ruby
require 'dockerspec/serverspec'

describe 'My Dockerfile' do
  describe docker_build('.') do

    it { should have_maintainer /John Doe/ }
    it { should have_cmd ['/bin/dash'] }
    it { should have_expose '80' }
    it { should have_user 'nobody' }

    describe docker_run(described_image) do
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

See [the documentation above](#documentation) for more examples.

### Run Tests Against Docker Compose

```ruby
require 'dockerspec/serverspec'

describe docker_compose('.', wait: 30) do

  its_container(:myapp) do
    describe process('apache2') do
      it { should be_running }
      its(:args) { should match(/-DFOREGROUND/) }
    end
    # [...]
  end

  its_container(:db) do
    its(:stdout) { should include 'MySQL init process done.' }

    describe process('mysqld') do
      it { should be_running }
    end
    # [...]
  end

end
```

**Important Warning:** The `docker_compose` resource uses the [`docker-compose-api`](https://rubygems.org/gems/docker-compose-api) Ruby gem to emulate Docker Compose. So, some *docker-compose.yml* configuration options may not be supported yet or may not work exactly the same. Let us know if you find any bug or you need a missing feature. And thanks to [Mauricio Klein](https://github.com/mauricioklein) for all his work by the way!

### Checking Container Logs

To check the running container logs content, you can use [the `stdout` and `stderr` helpers](http://www.rubydoc.info/gems/dockerspec/Dockerspec/Runner/ConfigHelpers) inside `docker_run` or `its_container` blocks.

For example:

```ruby
require 'dockerspec/serverspec'

describe 'My Dockerfile' do
  describe docker_build('.') do
    describe docker_run(described_image) do
      its(:stdout) { should include 'Successfully Started.' }
      its(:stderr) { should eq '' }
    end
  end
end
```

### Retrying Tests That Fail Temporarily

This gem includes the [`rspec-retry`](https://github.com/NoRedInk/rspec-retry) gem. So, you can add `:retry` to the RSpec metadata in order to retry some tests multiple times.

For example:

```ruby
describe docker_run('mariadb') do
  its(:stdout, retry: 30) { should include 'MySQL init process done.' }
end
```

By default, it will do a sleep of 1 second between each retry. You can adjust it with `:retry_wait`. See [`rspec-retry` documentation](http://www.rubydoc.info/gems/rspec-retry/0.4.5) for more details.

You can also make all tests within a block retry:

```ruby
describe docker_run('mariadb'), retry: 30 do
  its(:stdout) { should include 'MySQL init process done.' }
  its(:stderr) { should include 'MySQL init process done.' }

  describe command('mysqld -V'), retry: 1 do # disable retries here
    its(:stdout) { should match(/^mysqld .*MariaDB/i) }
  end
end
```

The same applies for `its_container` blocks.

### Run HTTP Tests Using Infrataster

```ruby
# require 'dockerspec/serverspec' # Only if you want to run both types of tests
require 'dockerspec/infrataster'

describe docker_run('nginx') do
  describe server(described_container) do # Infrataster

    describe http('/') do
      it 'responds content including "Welcome to nginx!"' do
        expect(response.body).to include 'Welcome to nginx!'
      end

      it 'responds as "nginx" server' do
        expect(response.headers['server']).to match(/nginx/i)
      end
    end

  end
end
```
See the [Infrataster Resources documentation](http://www.rubydoc.info/gems/infrataster#Resources) for more information.

### Run HTTP Tests Using Capybara

In the following example we set the *admin* password and log in in a hypothetical web application:

```ruby
require 'dockerspec/infrataster'

describe docker_build('.', tag: 'mywebapp') do
  describe docker_run('mywebapp') do

    describe server(described_container) do
      describe capybara('/') do
        let(:password) { '4dm1nP4ssw0rd' }

        describe 'on /setup' do
          before { visit '/setup' }

          it 'contains "Configure the password"' do
            expect(page).to have_content 'Configure the password'
          end

          it 'sets the admin password' do
            fill_in 'Password', with: password
            fill_in 'Confirm Password', with: password
            click_button 'Set password'
          end
        end

        describe 'on /login' do
          before { visit '/login' }

          it 'logs in as admin' do
            expect(page).to have_content 'sign in'
            fill_in 'User name', with: 'admin'
            fill_in 'Password', with: password
            click_button 'Sig in'
          end
        end

        describe 'on /' do
          before { visit '/' }

          it 'is logged id' do
            expect(page).to have_content 'Welcome admin!'
          end
        end

      end
    end

  end
end
```

See the [Capybara DSL documentation](http://www.rubydoc.info/gems/capybara#The_DSL) for more information.

### Run Database Tests Using `infrataster-plugin-mysql` Gem with Docker Compose

You need to include the `infrataster-plugin-mysql` gem in your *Gemfile*:

```ruby
# Gemfile

# gem [...]
gem 'infrataster-plugin-mysql', '~> 0.2.0'
```

A *docker-compose.yml* file example with a database:

```yaml
myapp:
  image: myapp
  links:
  - db:mysql
  ports:
  - 8080:80

db:
  image: mariadb
  environment:
  - MYSQL_ROOT_PASSWORD=example
```

The file with the tests:

```ruby
require 'dockerspec/infrataster'
require 'infrataster-plugin-mysql'

describe docker_compose('docker-compose.yml', wait: 60) do

  its_container(:db, mysql: { user: 'root', password: 'example' }) do
    describe server(described_container) do # Infrataster

      describe mysql_query('SHOW STATUS') do
        it 'returns positive uptime' do
          row = results.find { |r| r['Variable_name'] == 'Uptime' }
          expect(row['Value'].to_i).to be > 0
        end
      end

      describe mysql_query('SHOW DATABASES') do
        it 'includes `myapp` database' do
          databases = results.map { |r| r['Database'] }
          expect(databases).to include('myapp')
        end
      end

    end
  end
end
```

### Run Different Tests on Each Platform

Sometimes, you may want to be able to run different tests depending on the platform. You can use Serverspec's `os` helper method for that:

```ruby
require 'dockerspec/serverspec'

describe docker_build('.', tag: 'mywebapp') do
  describe docker_run('mywebapp') do
    case os[:family]
    when 'debian'

      describe file('/etc/debian_version') do
        it { should exist }
      end

      # [...]

    when 'alpine'

      describe file('/etc/alpine-release') do
        it { should exist }
      end

      # [...]

    end
  end
end
```

For more details, see [Serverspec documenation on how to get OS information](http://serverspec.org/advanced_tips.html#how-to-get-os-information).

### Real-world Examples

* [`alpine-tor`](https://github.com/zuazo/alpine-tor-docker) image ([*spec/*](https://github.com/zuazo/alpine-tor-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/alpine-tor-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/alpine-tor-docker/tree/master/.travis.yml)).
* [`chef-local`](https://github.com/zuazo/chef-local-docker) image ([*spec/*](https://github.com/zuazo/chef-local-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/chef-local-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/chef-local-docker/tree/master/.travis.yml)): Runs the same tests against multiple tags.
* [`keywhiz`](https://github.com/zuazo/keywhiz-docker) image ([*spec/*](https://github.com/zuazo/keywhiz-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/keywhiz-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/keywhiz-docker/tree/master/.travis.yml)).
* [`irssi-tor`](https://github.com/zuazo/irssi-tor-docker) image ([*spec/*](https://github.com/zuazo/irssi-tor-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/irssi-tor-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/irssi-tor-docker/tree/master/.travis.yml)).
* [`dradis`](https://github.com/zuazo/dradis-docker) image ([*spec/*](https://github.com/zuazo/dradis-docker/tree/master/spec), [*Gemfile*](https://github.com/zuazo/dradis-docker/tree/master/Gemfile), [*.travis.yml*](https://github.com/zuazo/dradis-docker/tree/master/.travis.yml)): Runs some Capybara HTTP tests.

### Prepare Your Ruby Environment

If you are new to Ruby, you can follow these steps:

#### 1. Create a **Gemfile**:

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'dockerspec', '~> 0.4.1'
```

#### 2. Create the *spec/* directory:

```
$ mkdir spec
```

#### 3. Add your tests to a file with the *spec/myapp_spec.rb* format:

With this gem, you can use both [Serverspec](http://serverspec.org/) and [Infrataster](https://github.com/ryotarai/infrataster) tests.

If you just want to use [Serverspec](http://serverspec.org/) tests:

```ruby
require 'dockerspec/serverspec'
```

If you just want to use [Infrataster](https://github.com/ryotarai/infrataster) tests:

```ruby
require 'dockerspec/infrataster'
```

But, of course, you can use both types of tests if you want:

```ruby
require 'dockerspec/serverspec'
require 'dockerspec/infrataster'
```

For example, you can create a file in *spec/myapp_spec.rb* with the following content:

```ruby
# spec/myapp_spec.rb

require 'dockerspec/serverspec'

describe 'My Dockerfile' do
  describe docker_build('.') do
    # [...]
    describe docker_run(described_image) do
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
| **Copyright:**       | Copyright (c) 2015-2016 Xabier de Zuazo
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
