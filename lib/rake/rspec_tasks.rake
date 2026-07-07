# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'tests/**/*.spec.rb'
  t.rspec_opts = ['--color', '--format', 'documentation', '--default-path', 'tests']
end
