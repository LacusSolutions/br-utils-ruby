# frozen_string_literal: true

require "pathname"
root = Pathname(__dir__).join("../..")
load root.join("lib/rake/gem_tasks.rake")

task :test do
  require "minitest/autorun"
  Dir[File.join(__dir__, "test/**/*_test.rb")].sort.each { |f| load f }
end
