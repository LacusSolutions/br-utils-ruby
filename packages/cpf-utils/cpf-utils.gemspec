# frozen_string_literal: true

require_relative 'src/cpf-utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpf-utils'
  spec.version       = CpfUtils::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'CPF utilities: format, generate, validate (Brazilian personal ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cpf-fmt', '>= 0'
  spec.add_dependency 'cpf-gen', '>= 0'
  spec.add_dependency 'cpf-val', '>= 0'
end
