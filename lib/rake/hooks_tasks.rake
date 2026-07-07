# frozen_string_literal: true

namespace :hooks do
  desc 'Install git hooks for this repo (sets core.hooksPath to .githooks)'
  task :install do
    sh 'git config core.hooksPath .githooks'
    puts 'Installed git hooks: core.hooksPath -> .githooks'
  end

  desc 'Uninstall git hooks (unset core.hooksPath)'
  task :uninstall do
    sh 'git config --unset core.hooksPath || true'
    puts 'Removed core.hooksPath override.'
  end
end
