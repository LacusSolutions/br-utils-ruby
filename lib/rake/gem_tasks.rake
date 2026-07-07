# frozen_string_literal: true

# Shared Rake tasks for packages. Require from each package Rakefile.
# Assumes: Dir.pwd is the package root; .gemspec exists; Gemfile exists.

require 'pathname'

def package_root
  Pathname(Dir.pwd)
end

def gemspec_path
  Dir.glob(package_root.join('*.gemspec')).first or raise "No .gemspec in #{package_root}"
end

def gemspec
  @gemspec ||= Gem::Specification.load(gemspec_path)
end

def gem_name
  gemspec.name
end

namespace :gem do
  desc 'Build the gem (package only)'
  task build: [:clean] do
    sh "gem build #{File.basename(gemspec_path)}"
  end

  desc 'Remove built gem and pkg/'
  task :clean do
    pkg = package_root.join('pkg')
    FileUtils.rm_rf(pkg)
    Dir[package_root.join('*.gem')].each { |f| FileUtils.rm_f(f) }
  end
end

desc 'Build gem into pkg/'
task build: 'gem:build'

desc 'Build and push gem to RubyGems.org (used by release-gem action with trusted publishing)'
task release: :build do
  gem_file = "#{gem_name}-#{gemspec.version}.gem"
  sh "gem push #{gem_file}"
end
