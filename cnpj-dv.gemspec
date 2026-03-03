# frozen_string_literal: true

require_relative "src/cnpj-dv/version"

Gem::Specification.new do |spec|
  spec.name          = "cnpj-dv"
  spec.version       = CnpjDv::VERSION
  spec.authors       = ["Julio L. Muller"]
  spec.summary       = "Check-digit calculation for CNPJ (Brazilian company ID)"
  spec.homepage      = "https://github.com/LacusSolutions/br-utils-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"
  spec.files         = Dir["src/**/*"] + (["LICENSE", "README.md"].select { |f| File.file?(f) })
  spec.require_paths = ["src"]
end
