# frozen_string_literal: true

require_relative 'src/cnpj-fmt/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-fmt'
  spec.version       = CnpjFmt::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.summary       = 'Format CNPJ (Brazilian company ID)'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md'].select { |f| File.file?(f) }
  spec.require_paths = ['src']
end
