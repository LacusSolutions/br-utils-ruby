# frozen_string_literal: true

require_relative 'src/cnpj-gen/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-gen'
  spec.version       = CnpjGen::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Generate random valid CNPJ (Brazilian company ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-dv', '>= 1.0', '< 2'
end
