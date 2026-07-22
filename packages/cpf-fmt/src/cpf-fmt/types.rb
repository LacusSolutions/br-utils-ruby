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

  # Case-equality predicate for CPF input: +String+ or +Array<String>+.
  #
  # Matches the runtime contract of {CpfFormatter#format} and {CpfFmt.cpf_fmt}.
  # Use {CpfInput.accept?} or +CpfInput === value+ (in +case+/+when+) to test
  # candidacy without raising.
  #
  # @example
  #   CpfFmt::CpfInput.accept?('82911017366') # => true
  #   CpfFmt::CpfInput.accept?(%w[8 2 9 1 1]) # => true
  #   CpfFmt::CpfInput.accept?(123)           # => false
  #   CpfFmt::CpfInput.accept?([1, 2, 3])     # => false
  #
  # @see CpfFormatter#format
  # @see CpfFmt.cpf_fmt
  module CpfInput
    class << self
      # @param value [Object] candidate input
      # @return [Boolean] whether +value+ is a +String+ or an +Array+ of +String+
      def accept?(value)
        return true if value.is_a?(String)
        return false unless value.is_a?(Array)

        value.all?(String)
      end

      # Case-equality entry point for +case+/+when+ and +===+ checks.
      #
      # @param value [Object] candidate input
      # @return [Boolean]
      def ===(value)
        accept?(value)
      end
    end
  end

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
