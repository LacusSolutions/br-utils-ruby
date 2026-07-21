# frozen_string_literal: true

require_relative 'src/cpf-gen/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpf-gen'
  spec.version       = CpfGen::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = "Generate CPF (Brazilian Individual's Taxpayer ID)"
  spec.description   = "Utility to generate CPF (Brazilian Individual's Taxpayer ID)"
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
  spec.add_dependency 'cpf-dv', '>= 1.0.0', '< 1.1.0'
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
