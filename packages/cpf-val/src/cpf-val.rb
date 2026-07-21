# frozen_string_literal: true

require_relative 'cpf-val/version'
require_relative 'cpf-val/errors'
require_relative 'cpf-val/types'
require_relative 'cpf-val/cpf_validator'
require_relative 'cpf-val/cpf_val'

# Validates CPF (Cadastro de Pessoa Física) identifiers.
#
# Supports formatted or raw digit input. Invalid CPF data returns +false+; only
# documented errors are raised for API misuse (wrong input type).
#
# Errors fall into one category:
#
# - *API misuse* — the caller supplied a wrong type. Raised as
#   {CpfVal::TypeMismatchError}.
#
# Every custom error includes the {CpfVal::Error} marker module so consumers can
# +rescue CpfVal::Error+ for a library-wide catch.
#
# Public API:
#
# - {CpfVal.cpf_val}
# - {CpfVal::CpfValidator}
# - {CpfVal::CPF_LENGTH}, {CpfVal::VERSION}
# - Type marker: {CpfVal::CpfInput}
# - Error marker {CpfVal::Error}; misuse error {CpfVal::TypeMismatchError}
#
# @example
#   require 'cpf-val'
#
#   CpfVal.cpf_val('82911017366') # => true
module CpfVal
end
