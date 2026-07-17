# frozen_string_literal: true

require_relative 'cnpj-fmt/version'
require_relative 'cnpj-fmt/exceptions'
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
# - *API misuse* — the caller invoked the library incorrectly (wrong type for
#   input or options). Raised as {CnpjFmt::TypeMismatchError} (+TypeError+).
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
#   leaves {CnpjFmt::TypeMismatchError}, {CnpjFmt::InvalidLengthError},
#   {CnpjFmt::OutOfRangeError}, {CnpjFmt::ValidationError}
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
