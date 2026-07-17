# frozen_string_literal: true

module CnpjFmt
  # Shared keyword option names for formatter entry points.
  #
  # @see CnpjFormatter#initialize
  # @see CnpjFormatter#format
  # @see CnpjFmt.cnpj_fmt
  FORMATTER_OPTION_KEYS = %i[
    hidden hidden_key hidden_start hidden_end dot_key slash_key dash_key escape encode on_fail
  ].freeze

  # Represents valid input types for CNPJ formatting.
  #
  # A CNPJ can be provided as:
  #
  # - A string containing alphanumeric characters (with or without formatting)
  # - An array of strings, where each string represents an alphanumeric
  #   character or group of alphanumeric characters
  #
  # @see CnpjFormatter#format
  # @see CnpjFmt.cnpj_fmt
  CnpjInput = Object

  # Callback function type for handling formatting failures.
  #
  # This function is invoked when the CNPJ formatter encounters an error during
  # formatting, such as invalid input length or other formatting issues. The
  # callback receives the original input value and the exception object, and
  # should return a string to use as the fallback output.
  #
  # @yieldparam original_input [String, Array<String>] the raw input value
  # @yieldparam exception [InvalidLengthError] the length error
  # @yieldreturn [String] fallback output
  OnFailCallback = Object

  # Options input accepted by formatter constructors and {#format} calls.
  #
  # May be a {CnpjFormatterOptions} instance, a {Hash} of option keys, or +nil+.
  #
  # @see CnpjFormatterOptions
  CnpjFormatterOptionsInput = Object
end
