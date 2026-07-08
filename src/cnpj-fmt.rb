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
# The package distinguishes between **errors** and **exceptions**:
#
# - {CnpjFormatterTypeError} (extends the native {TypeError}) signals incorrect
#   API usage (the input or option is of the wrong *type*).
# - {CnpjFormatterException} (extends the native {StandardError}) signals invalid
#   or ineligible data (right type, bad value).
#
# Public API:
#
# - {CnpjFmt.cnpj_fmt}
# - {CnpjFormatter}, {CnpjFormatterOptions}
# - {CNPJ_LENGTH}, {VERSION}
# - Exception hierarchy under {CnpjFmt}
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
