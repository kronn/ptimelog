# typed: ignore
# frozen_string_literal: true

require 'rake/clean'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'ptimelog'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :sorbet do
  desc 'Record sorbet adoption metrics'
  task metrics: ['metrics.json'] do
    sh %(cat metrics.json | jq -r '.metrics.[] | [.key, " = ", (.value | tostring)] | join("") ' >> sorbet-stats.txt)
  end
  file 'metrics.json' do
    sh 'srb tc --metrics-file=metrics.json'
  end
end

task default: %i[rubocop spec]
