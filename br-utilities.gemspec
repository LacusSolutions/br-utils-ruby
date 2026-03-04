# frozen_string_literal: true

require_relative 'src/br-utilities/version'

Gem::Specification.new do |spec|
  spec.name          = 'br-utilities'
  spec.version       = BrUtils::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Brazilian data utilities: CPF, CNPJ, and more'
  spec.description   = 'Unified API for CPF/CNPJ format, generate, validate (Brazilian IDs).'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-utils', '>= 0'
  spec.add_dependency 'cpf-utils', '>= 0'
end
