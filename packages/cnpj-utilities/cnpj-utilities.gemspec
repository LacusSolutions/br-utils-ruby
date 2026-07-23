# frozen_string_literal: true

require_relative 'src/cnpj-utilities/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-utilities'
  spec.version       = CnpjUtils::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = 'Utilities to deal with CNPJ (Brazilian Business Tax ID)'
  spec.description   = 'Utilities to deal with CNPJ (Brazilian Business Tax ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md', 'README.pt.md', 'CHANGELOG.md']
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-fmt', '>= 1.0.0', '< 1.1.0'
  spec.add_dependency 'cnpj-gen', '>= 1.0.0', '< 1.1.0'
  spec.add_dependency 'cnpj-val', '>= 1.0.0', '< 1.1.0'
end
