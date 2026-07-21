# frozen_string_literal: true

require_relative 'cpf-fmt/version'
require_relative 'cpf-fmt/errors'
require_relative 'cpf-fmt/types'
require_relative 'cpf-fmt/cpf_formatter_options'
require_relative 'cpf-fmt/utils'
require_relative 'cpf-fmt/cpf_formatter'
require_relative 'cpf-fmt/cpf_fmt'

# Formats a CPF (Cadastro de Pessoas Físicas) identifier into a human-readable
# string. Supports the 11-digit CPF format (digits only after sanitization).
#
# Errors fall into two categories:
#
# - *API misuse* — the caller supplied a wrong type or an incompatible argument
#   combination. Raised as {CpfFmt::TypeMismatchError} or
#   {CpfFmt::InvalidArgumentCombinationError}.
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule. Length failures construct {CpfFmt::InvalidLengthError} and pass it to
#   +on_fail+ as a {CpfFmt::DomainError}. Hidden-range failures raise
#   {CpfFmt::OutOfRangeError}; forbidden key characters raise
#   {CpfFmt::ValidationError}.
#
# Every custom error includes the {CpfFmt::Error} marker module so consumers can
# +rescue CpfFmt::Error+ for a library-wide catch.
#
# Public API:
#
# - {CpfFmt.cpf_fmt}
# - {CpfFormatter}, {CpfFormatterOptions}
# - {CPF_LENGTH}, {VERSION}
# - Error marker {CpfFmt::Error}; domain ancestor {CpfFmt::DomainError};
#   misuse errors {CpfFmt::TypeMismatchError} and
#   {CpfFmt::InvalidArgumentCombinationError}; domain leaves
#   {CpfFmt::InvalidLengthError}, {CpfFmt::OutOfRangeError}, and
#   {CpfFmt::ValidationError}
#
# @example
#   require 'cpf-fmt'
#
#   CpfFmt.cpf_fmt('12345678910') # => "123.456.789-10"
module CpfFmt
  # The standard length of a CPF (Cadastro de Pessoas Físicas) identifier
  # (11 digits).
  CPF_LENGTH = CpfFormatterOptions::CPF_LENGTH
end
