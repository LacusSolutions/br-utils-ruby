# frozen_string_literal: true

namespace :lint do
  desc 'Run RuboCop'
  task :rubocop do
    sh 'bundle exec rubocop'
  end

  desc 'Auto-correct safe RuboCop offenses'
  task :autocorrect do
    sh 'bundle exec rubocop -a'
  end

  desc 'Auto-correct all RuboCop offenses (including unsafe)'
  task :autocorrect_all do
    sh 'bundle exec rubocop -A'
  end

  desc 'Lint commit messages against Conventional Commits (COMMIT_RANGE, default origin/main..HEAD)'
  task :commits do
    root = File.expand_path('../..', __dir__)
    range = ENV['COMMIT_RANGE'] || 'origin/main..HEAD'
    sh "ruby #{File.join(root, 'bin', 'commit-lint')} --range #{range}"
  end
end

desc 'Run RuboCop'
task lint: 'lint:rubocop'

desc 'Auto-correct safe RuboCop offenses'
task format: 'lint:autocorrect'
