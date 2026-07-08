# frozen_string_literal: true

require_relative 'cnpj-dv/version'
require_relative 'cnpj-dv/exceptions'
require_relative 'cnpj-dv/cnpj_check_digits'

# Check-digit calculation for Brazilian CNPJ (numeric and alphanumeric formats).
#
# The package distinguishes between **errors** and **exceptions**:
#
# - {CnpjDV::CnpjCheckDigitsTypeError} (extends the native {TypeError})
#   signals incorrect API usage (the input is of the wrong *type*).
# - {CnpjDV::CnpjCheckDigitsException} (extends the native {StandardError})
#   signals invalid or ineligible data (right type, bad value).
#
# Public API:
#
# - {CnpjDV::CnpjCheckDigits}
# - {CnpjDV::CNPJ_MIN_LENGTH}, {CnpjDV::CNPJ_MAX_LENGTH}
# - Exception hierarchy under {CnpjDV::CnpjCheckDigitsTypeError} /
#   {CnpjDV::CnpjCheckDigitsException}
#
# @example
#   require 'cnpj-dv'
#
#   check_digits = CnpjDV::CnpjCheckDigits.new('914157320007')
#   check_digits.cnpj # => '91415732000793'
module CnpjDV
end
