# frozen_string_literal: true

require_relative 'src/cpf-gen/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpf-gen'
  spec.version       = CpfGen::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Generate random valid CPF numbers (Brazilian personal ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cpf-dv', '>= 0'
end
