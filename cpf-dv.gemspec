# frozen_string_literal: true

require_relative 'src/cpf-dv/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpf-dv'
  spec.version       = CpfDV::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = 'Check-digit calculation for CPF (Brazilian personal ID)'
  spec.description   = 'Utility to calculate and verify CPF check digits.'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
