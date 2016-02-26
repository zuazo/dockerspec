# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Available Rake tasks:
#
# $ rake -T
# rake clean                    # Clean some generated files
# rake integration              # Run the integration tests
# rake integration:infrataster  # Infrataster engine integration tests
# rake integration:serverspec   # Serverspec engine integration tests
# rake rubocop                  # Run RuboCop style checks
# rake style                    # Run all style checks
# rake test                     # Run all the tests
# rake unit                     # Run the unit tests
# rake yard                     # Generate Ruby documentation
#
# More info at https://github.com/ruby/rake/blob/master/doc/rakefile.rdoc
#

require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Clean some generated files'
task :clean do
  %w(
    .bundle
    .cache
    coverage
    doc
    *.gem
    Gemfile.lock
    .inch
    vendor
    .yardoc
  ).each { |f| FileUtils.rm_rf(Dir.glob(f)) }
end

desc 'Generate Ruby documentation'
task :yard do
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.stats_options = %w(--list-undoc)
  end
end

task doc: %w(yard)

desc 'Run RuboCop style checks'
task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

desc 'Run all style checks'
task style: %w(rubocop)

require 'rspec/core/rake_task'

#
# Gest the tests directory name to use.
#
# @param name [String] The task name.
#
# @return [String] Subdirectory name inside *spec/*.
#
def rake_dir_from_name(name)
  if %w(serverspec infrataster).include?(name.to_s)
    'integration'
  else
    name.to_s == 'test' ? '{unit,integration}' : name
  end
end

#
# Generates RakeTask to run the tests.
#
# @param name [String] The task name.
#
# @param env [Hash] The environment variables to set.
#
# @return [RSpec::Core::RakeTask] The Generated RakeTask.
#
def rake_task(name, env = {})
  dir = rake_dir_from_name(name)
  RSpec::Core::RakeTask.new(name) do |t|
    env.each { |k, v| ENV[k.to_s.upcase] = v.to_s }
    t.pattern = "spec/#{dir}/**{,/*/**}/*_spec.rb"
    t.verbose = true
  end
end

desc 'Run the unit tests'
rake_task(:unit)

namespace :integration do
  desc 'Serverspec engine integration tests'
  rake_task(:serverspec, serverspec: true)

  desc 'Infrataster engine integration tests'
  rake_task(:infrataster, infrataster: true)
end

desc 'Run all the integration tests'
rake_task(:integration)

desc 'Run all the tests'
rake_task(:test)

task default: %w(style test)
