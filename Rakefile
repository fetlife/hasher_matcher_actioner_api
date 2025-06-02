# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

Rake::Task["release:rubygem_push"].clear
task "release:rubygem_push" do
  puts "Skipping gem push, push to main to trigger GitHub release"
end
