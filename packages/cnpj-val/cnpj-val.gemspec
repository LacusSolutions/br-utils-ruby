# frozen_string_literal: true

require_relative 'src/cnpj-val/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-val'
  spec.version       = CnpjVal::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Validate CNPJ (Brazilian company ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md', 'README.pt.md', 'CHANGELOG.md']
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-dv', '>= 1.0.0', '< 1.1.0'
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
