# frozen_string_literal: true

require_relative 'src/cnpj-utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-utils'
  spec.version       = CnpjUtils::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'CNPJ utilities (Brazilian company ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-fmt', '>= 1.0', '< 2'
  spec.add_dependency 'cnpj-gen', '>= 1.0', '< 2'
  spec.add_dependency 'cnpj-val', '>= 1.0', '< 2'
end
