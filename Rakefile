# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

namespace :release do
  task :guard_gem_push do
    Rake::Task["release:rubygem_push"].clear
    task "release:rubygem_push" do
      puts "Skipping gem push"
    end
  end

  task prepare: :guard_gem_push
end

# Ensure guard runs before the main release task
Rake::Task["release"].enhance(["release:prepare"])
