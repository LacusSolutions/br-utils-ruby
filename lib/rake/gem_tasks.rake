# frozen_string_literal: true

# Shared Rake tasks for packages. Require from each package Rakefile.
# Assumes: Dir.pwd is the package root; .gemspec exists; Gemfile exists.

require "pathname"

def package_root
  Pathname(Dir.pwd)
end

def gemspec_path
  Dir.glob(package_root.join("*.gemspec")).first or raise "No .gemspec in #{package_root}"
end

def gemspec
  @gemspec ||= Gem::Specification.load(gemspec_path)
end

def gem_name
  gemspec.name
end

namespace :gem do
  desc "Build the gem (package only)"
  task build: [:clean] do
    sh "gem build #{File.basename(gemspec_path)}"
  end

  desc "Remove built gem and pkg/"
  task :clean do
    pkg = package_root.join("pkg")
    FileUtils.rm_rf(pkg)
    Dir[package_root.join("*.gem")].each { |f| FileUtils.rm_f(f) }
  end
end

desc "Build gem into pkg/"
task build: "gem:build"

desc "Run tests (override in package Rakefile to call minitest/rspec)"
task :test do
  # Default: no-op; each package defines test
  puts "No test task defined for #{gem_name}"
end
