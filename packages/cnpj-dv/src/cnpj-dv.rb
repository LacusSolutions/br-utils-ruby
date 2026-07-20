# frozen_string_literal: true

require_relative 'cnpj-dv/version'
require_relative 'cnpj-dv/errors'
require_relative 'cnpj-dv/cnpj_check_digits'

# Check-digit calculation for Brazilian CNPJ (numeric and alphanumeric formats).
#
# Errors fall into two categories:
#
# - *API misuse* — the caller invoked the library incorrectly (wrong type).
#   Raised as {CnpjDV::TypeMismatchError} (+TypeError+).
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule (invalid length, ineligible base/branch, repeated digits). Length
#   failures raise {CnpjDV::InvalidLengthError}; other domain failures raise
#   {CnpjDV::ValidationError} (both under {CnpjDV::DomainError} / +RangeError+).
#
# Every custom error includes the {CnpjDV::Error} marker module so consumers can
# +rescue CnpjDV::Error+ for a library-wide catch.
#
# Public API:
#
# - {CnpjDV::CnpjCheckDigits}
# - {CnpjDV::CNPJ_MIN_LENGTH}, {CnpjDV::CNPJ_MAX_LENGTH}
# - Error marker {CnpjDV::Error}; domain ancestor {CnpjDV::DomainError};
#   raised leaves {CnpjDV::TypeMismatchError}, {CnpjDV::InvalidLengthError},
#   {CnpjDV::ValidationError}
#
# @example
#   require 'cnpj-dv'
#
#   check_digits = CnpjDV::CnpjCheckDigits.new('914157320007')
#   check_digits.cnpj # => '91415732000793'
module CnpjDV
end
