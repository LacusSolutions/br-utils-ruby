# frozen_string_literal: true

class CnpjUtils
  # Nested package module — same object as +::CnpjVal+ (Options, helpers, errors, types).
  CnpjVal = ::CnpjVal

  CnpjValidator = CnpjVal::CnpjValidator
  CnpjValidatorOptions = CnpjVal::CnpjValidatorOptions
  CnpjValidatorError = CnpjVal::Error
end
