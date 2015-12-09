# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# More info at https://github.com/ruby/rake/blob/master/doc/rakefile.rdoc

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

{
  test: '{unit,integration}',
  unit: 'unit',
  integration: 'integration'
}.each do |test, dir|
  RSpec::Core::RakeTask.new(test) do |t|
    t.pattern = "spec/#{dir}/**{,/*/**}/*_spec.rb"
    t.verbose = true
  end
end

task default: %w(style test)
