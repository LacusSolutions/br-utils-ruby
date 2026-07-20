# frozen_string_literal: true

require_relative 'cnpj-fmt/version'
require_relative 'cnpj-fmt/errors'
require_relative 'cnpj-fmt/types'
require_relative 'cnpj-fmt/cnpj_formatter_options'
require_relative 'cnpj-fmt/formatter_support'
require_relative 'cnpj-fmt/cnpj_formatter'
require_relative 'cnpj-fmt/cnpj_fmt'

# Formats a CNPJ (Cadastro Nacional da Pessoa Jurídica) identifier into a
# human-readable string. Supports the 14-character alphanumeric CNPJ format
# (digits and uppercase letters).
#
# Errors fall into two categories:
#
# - *API misuse* — the caller supplied a wrong type, omitted a required
#   argument, or provided an incompatible argument combination. Raised as
#   {CnpjFmt::TypeMismatchError}, {CnpjFmt::MissingArgumentError}, or
#   {CnpjFmt::InvalidArgumentCombinationError}.
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule. Length failures construct {CnpjFmt::InvalidLengthError} and pass it to
#   +on_fail+ (not raised from {CnpjFormatter#format}). Hidden-range failures
#   raise {CnpjFmt::OutOfRangeError}; forbidden key characters raise
#   {CnpjFmt::ValidationError}.
#
# Every custom error includes the {CnpjFmt::Error} marker module so consumers can
# +rescue CnpjFmt::Error+ for a library-wide catch.
#
# Public API:
#
# - {CnpjFmt.cnpj_fmt}
# - {CnpjFormatter}, {CnpjFormatterOptions}
# - {CNPJ_LENGTH}, {VERSION}
# - Error marker {CnpjFmt::Error}; domain ancestor {CnpjFmt::DomainError};
#   misuse errors {CnpjFmt::TypeMismatchError},
#   {CnpjFmt::MissingArgumentError}, and
#   {CnpjFmt::InvalidArgumentCombinationError}; domain leaves
#   {CnpjFmt::InvalidLengthError}, {CnpjFmt::OutOfRangeError}, and
#   {CnpjFmt::ValidationError}
#
# @example
#   require 'cnpj-fmt'
#
#   CnpjFmt.cnpj_fmt('12345678000910') # => "12.345.678/0009-10"
module CnpjFmt
  # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
  # identifier (14 alphanumeric characters).
  CNPJ_LENGTH = CnpjFormatterOptions::CNPJ_LENGTH
end
