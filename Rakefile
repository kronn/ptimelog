# frozen_string_literal: true

require 'rake/clean'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'ptimelog'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[rubocop spec]
