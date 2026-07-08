# frozen_string_literal: true

require_relative 'src/cnpj-fmt/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-fmt'
  spec.version       = CnpjFmt::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = 'Format CNPJ (Brazilian Business Tax ID)'
  spec.description   = 'Utility to format CNPJ (Brazilian Business Tax ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md', 'README.pt-BR.md', 'CHANGELOG.md']
  spec.require_paths = ['src']
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
