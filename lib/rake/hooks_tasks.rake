# frozen_string_literal: true

namespace :hooks do
  desc 'Install git hooks for this repo (sets core.hooksPath to .githooks)'
  task :install do
    sh 'git config core.hooksPath .githooks'
    puts 'Installed git hooks: core.hooksPath -> .githooks'
    puts '  - pre-commit: RuboCop auto-correct + re-stage of staged files'
    puts '  - pre-push:   run the test suite, abort push on failure'
    puts '  - commit-msg: Conventional Commits check'
  end

  desc 'Uninstall git hooks (unset core.hooksPath)'
  task :uninstall do
    sh 'git config --unset core.hooksPath || true'
    puts 'Removed core.hooksPath override.'
  end
end
