require 'bundler'
require 'yard'
require 'spec/rake/spectask'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
task default: [:spec, :rubocop]

Bundler::GemHelper.install_tasks

YARD::Rake::YardocTask.new

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop)
