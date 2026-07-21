# frozen_string_literal: true

require_relative 'cpf-dv/version'
require_relative 'cpf-dv/errors'
require_relative 'cpf-dv/cpf_check_digits'

# Check-digit calculation for Brazilian CPF (numeric format).
#
# Errors fall into two categories:
#
# - *API misuse* — the caller invoked the library incorrectly (wrong type).
#   Raised as {CpfDV::TypeMismatchError} (+TypeError+).
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule (invalid length, repeated digits). Length failures raise
#   {CpfDV::InvalidLengthError}; other domain failures raise
#   {CpfDV::ValidationError} (both under {CpfDV::DomainError} / +RangeError+).
#
# Every custom error includes the {CpfDV::Error} marker module so consumers can
# +rescue CpfDV::Error+ for a library-wide catch.
#
# Public API:
#
# - {CpfDV::CpfCheckDigits}
# - {CpfDV::CPF_MIN_LENGTH}, {CpfDV::CPF_MAX_LENGTH}
# - Error marker {CpfDV::Error}; domain ancestor {CpfDV::DomainError};
#   raised leaves {CpfDV::TypeMismatchError}, {CpfDV::InvalidLengthError},
#   {CpfDV::ValidationError}
#
# @example
#   require 'cpf-dv'
#
#   check_digits = CpfDV::CpfCheckDigits.new('054496519')
#   check_digits.cpf # => '05449651910'
module CpfDV
end
