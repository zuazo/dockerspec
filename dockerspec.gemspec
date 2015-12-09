# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# More info at http://guides.rubygems.org/specification-reference/

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'dockerspec/version'

Gem::Specification.new do |s|
  s.name = 'dockerspec'
  s.version = ::Dockerspec::VERSION
  s.date = '2015-12-09'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Dockerspec'
  s.description =
    'A small gem to run RSpec and Serverspec tests against Dockerfiles or '\
    'Docker images easily.'
  s.license = 'Apache-2.0'
  s.authors = %(Xabier de Zuazo)
  s.email = 'xabier@zuazo.org'
  s.homepage = 'https://github.com/zuazo/dockerspec'
  s.require_path = 'lib'
  s.files = %w(
    LICENSE
    Rakefile
    .yardopts
  ) + Dir.glob('*.md') + Dir.glob('lib/**/*')
  s.test_files = Dir.glob('{test,spec,features}/*')
  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')

  s.add_dependency 'docker-api', '~> 1.22'
  s.add_dependency 'rspec', '~> 3.0'
  s.add_dependency 'rspec-its', '~> 1.0'
  s.add_dependency 'serverspec', '~> 2.24'
  s.add_dependency 'specinfra-backend-docker_lxc', '~> 0.1.0'
  s.add_dependency 'erubis', '~> 2.0'

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec-core', '~> 3.1'
  s.add_development_dependency 'rspec-expectations', '~> 3.1'
  s.add_development_dependency 'rspec-mocks', '~> 3.1'
  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'should_not', '~> 1.1'
  s.add_development_dependency 'rubocop', '~> 0.35.0'
  s.add_development_dependency 'yard', '~> 0.8'
end
