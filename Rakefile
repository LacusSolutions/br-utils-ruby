# frozen_string_literal: true

require 'yaml'
require 'pathname'

load File.join(__dir__, 'lib/rake/lint_tasks.rake')
load File.join(__dir__, 'lib/rake/hooks_tasks.rake')

begin
  load File.join(__dir__, 'lib/rake/rspec_tasks.rake')
rescue LoadError
  # rspec not installed in this context (e.g. release); skip the root test task.
end

ROOT = Pathname(__dir__)
PACKAGES = ROOT.join('packages')
CONFIG = YAML.load_file(ROOT.join('config/gems.yml'))
GEMS = CONFIG['gems'] || {}

def gem_dirs
  GEMS.values.map { |v| v.is_a?(Hash) ? v['dir'] : v }
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def topological_order
  order = []
  visited = {}
  temp = {}

  visit = lambda do |name|
    return if visited[name]

    raise "Cycle involving #{name}" if temp[name]

    temp[name] = true
    deps = (GEMS[name] && GEMS[name]['dependencies']) || []
    deps.each { |d| visit[d] }
    temp[name] = false
    visited[name] = true
    order << name
  end

  GEMS.each_key { |name| visit[name] }
  order.reverse
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

def gem_name_to_dir(name)
  GEMS.dig(name, 'dir') || name.to_s
end

namespace :monorepo do
  desc 'Verify no circular dependencies'
  task :check_cycles do
    topological_order
    puts "OK: No cycles (DAG with #{GEMS.size} gems)"
  end

  desc 'List gems in build order (leaves first)'
  task :order do
    topological_order.each { |n| puts "#{n} -> #{gem_name_to_dir(n)}" }
  end

  desc 'Run task in each gem (build order). Usage: rake monorepo:each[test]'
  task :each, [:task] => :check_cycles do |_t, args|
    task_name = args[:task] or abort 'Usage: rake monorepo:each[task]'
    Dir.chdir(ROOT) do
      topological_order.each do |name|
        dir = PACKAGES.join(gem_name_to_dir(name))
        next unless dir.directory?

        puts "\n>> #{dir.basename}: rake #{task_name}"
        system("cd #{dir} && bundle exec rake #{task_name}") or abort "Failed in #{dir.basename}"
      end
    end
  end
end

desc 'Default: check cycles and list order'
task default: 'monorepo:check_cycles'

# Used by release-gem action: RELEASE_PACKAGE=dir (e.g. cnpj-dv) runs that package's release task
desc 'Build and push one package to RubyGems (set RELEASE_PACKAGE=packages/dir)'
task :release do
  dir = ENV.fetch('RELEASE_PACKAGE', nil) or abort 'Set RELEASE_PACKAGE to the package dir (e.g. cnpj-dv)'
  pkg_path = ROOT.join('packages', dir)
  abort "Package not found: #{pkg_path}" unless pkg_path.directory?
  Dir.chdir(pkg_path) { system('bundle exec rake release') or abort('Release failed') }
end

# Load package-specific rake tasks from each gem (they extend this Rakefile when run from package dir)
task :load_package_tasks do
  gem_dirs.each do |dir|
    pkg_rake = PACKAGES.join(dir, 'Rakefile')
    load pkg_rake.to_s if pkg_rake.exist?
  end
rescue LoadError => e
  # Ignore if a package Rakefile expects to be run from its own dir
  puts "Note: #{e.message}" if ENV['VERBOSE']
end
