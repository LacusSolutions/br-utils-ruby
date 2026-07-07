# frozen_string_literal: true

require_relative 'src/lacus-utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'lacus-utils'
  spec.version       = LacusUtils::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = 'Reusable utilities for Lacus Solutions Ruby packages'
  spec.description   = 'Shared helpers for Lacus Solutions Ruby gems (type description, random sequences, etc.).'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
end
