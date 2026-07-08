# frozen_string_literal: true

require_relative 'src/cpf-val/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpf-val'
  spec.version       = CpfVal::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Validate CPF (Brazilian personal ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cpf-dv', '>= 0'
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
