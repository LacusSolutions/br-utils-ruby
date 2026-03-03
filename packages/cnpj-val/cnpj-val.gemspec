# frozen_string_literal: true

require_relative "src/cnpj-val/version"

Gem::Specification.new do |spec|
  spec.name          = "cnpj-val"
  spec.version       = CnpjVal::VERSION
  spec.authors       = ["Julio L. Muller"]
  spec.summary       = "Validate CNPJ (Brazilian company ID)"
  spec.homepage      = "https://github.com/LacusSolutions/br-utils-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"
  spec.files         = Dir["src/**/*"] + (["LICENSE", "README.md"].select { |f| File.file?(f) })
  spec.require_paths = ["src"]
  spec.add_runtime_dependency "cnpj-dv", ">= 1.0", "< 2"
end
