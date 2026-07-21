# frozen_string_literal: true

require_relative 'cnpj-val/version'
require_relative 'cnpj-val/errors'
require_relative 'cnpj-val/types'
require_relative 'cnpj-val/cnpj_validator_options'
require_relative 'cnpj-val/cnpj_validator'
require_relative 'cnpj-val/cnpj_val'

# Validates CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
#
# Supports formatted or raw input for numeric-only and alphanumeric CNPJ values.
# Invalid CNPJ data returns +false+; only documented errors are raised for API
# misuse or domain option violations.
#
# Errors fall into two categories:
#
# - *API misuse* — the caller supplied a wrong type or an incompatible argument
#   combination. Raised as {CnpjVal::TypeMismatchError} or
#   {CnpjVal::InvalidArgumentCombinationError}.
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule. An invalid +type+ value raises {CnpjVal::ValidationError} under
#   {CnpjVal::DomainError}.
#
# Every custom error includes the {CnpjVal::Error} marker module so consumers can
# +rescue CnpjVal::Error+ for a library-wide catch.
#
# Public API:
#
# - {CnpjVal.cnpj_val}
# - {CnpjVal::CnpjValidator}, {CnpjVal::CnpjValidatorOptions}
# - {CnpjVal::CNPJ_LENGTH}, {CnpjVal::VERSION}
# - Type markers: {CnpjVal::CnpjInput}, {CnpjVal::CnpjType},
#   {CnpjVal::CnpjValidatorOptionsInput}
# - Error marker {CnpjVal::Error}; domain ancestor {CnpjVal::DomainError};
#   misuse errors {CnpjVal::TypeMismatchError} and
#   {CnpjVal::InvalidArgumentCombinationError}; domain leaf
#   {CnpjVal::ValidationError}
#
# @example
#   require 'cnpj-val'
#
#   CnpjVal.cnpj_val('91415732000793') # => true
module CnpjVal
  # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
  # identifier (14 alphanumeric characters).
  CNPJ_LENGTH = CnpjValidatorOptions::CNPJ_LENGTH
end
