# frozen_string_literal: true

class CnpjUtils
  # Nested package module — same object as +::CnpjGen+ (Options, helpers, errors, types).
  CnpjGen = ::CnpjGen

  CnpjGenerator = CnpjGen::CnpjGenerator
  CnpjGeneratorOptions = CnpjGen::CnpjGeneratorOptions
  CnpjGeneratorError = CnpjGen::Error
end
