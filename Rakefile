# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Available Rake tasks:
#
# $ rake -T
# rake clean                    # Clean some generated files
# rake integration              # Run the integration tests
# rake integration:all          # Run the integration tests
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

desc 'Run the unit tests'
RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = 'spec/unit/**{,/*/**}/*_spec.rb'
  t.verbose = true
end

namespace :integration do
  desc 'Serverspec engine integration tests'
  RSpec::Core::RakeTask.new(:serverspec) do |t|
    ENV['SERVERSPEC'] = 'true'
    t.pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
    t.verbose = true
  end

  desc 'Infrataster engine integration tests'
  RSpec::Core::RakeTask.new(:infrataster) do |t|
    ENV['INFRATASTER'] = 'true'
    t.pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
    t.verbose = true
  end

  desc 'Run all the integration tests'
  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
    t.verbose = true
  end
end

desc 'Run all the integration tests'
task integration: %w(integration:all)

desc 'Run all the tests'
task test: %w(unit integration)

task default: %w(style test)
