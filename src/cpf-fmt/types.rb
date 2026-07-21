# frozen_string_literal: true

module CpfFmt
  # Shared keyword option names for formatter entry points.
  #
  # @see CpfFormatter#initialize
  # @see CpfFormatter#format
  # @see CpfFmt.cpf_fmt
  FORMATTER_OPTION_KEYS = %i[
    hidden hidden_key hidden_start hidden_end dot_key dash_key escape encode on_fail
  ].freeze

  # Represents valid input types for CPF formatting.
  #
  # A CPF can be provided as:
  #
  # - A string containing digits (with or without formatting)
  # - An array of strings, where each string represents a digit or group of digits
  #
  # @see CpfFormatter#format
  # @see CpfFmt.cpf_fmt
  CpfInput = Object

  # Callback function type for handling formatting failures.
  #
  # This function is invoked when the CPF formatter encounters an error during
  # formatting, such as invalid input length or other formatting issues. The
  # callback receives the original input value and a {DomainError}, and should
  # return a string to use as the fallback output.
  #
  # @yieldparam original_input [String, Array<String>] the raw input value
  # @yieldparam error [DomainError] the domain failure (currently {InvalidLengthError})
  # @yieldreturn [String] fallback output
  OnFailCallback = Object

  # Options input accepted by formatter constructors and {#format} calls.
  #
  # May be a {CpfFormatterOptions} instance, a {Hash} of option keys, or +nil+.
  #
  # @see CpfFormatterOptions
  CpfFormatterOptionsInput = Object
end
