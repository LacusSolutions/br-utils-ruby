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

  # Case-equality predicate for CNPJ input: +String+ or +Array<String>+.
  #
  # Matches the runtime contract of {CnpjFormatter#format} and {CnpjFmt.cnpj_fmt}.
  # Use {CnpjInput.accept?} or +CnpjInput === value+ (in +case+/+when+) to test
  # candidacy without raising.
  #
  # @example
  #   CnpjFmt::CnpjInput.accept?('91415732000793') # => true
  #   CnpjFmt::CnpjInput.accept?(%w[9 1 4 1])      # => true
  #   CnpjFmt::CnpjInput.accept?(123)              # => false
  #   CnpjFmt::CnpjInput.accept?([1, 2, 3])        # => false
  #
  # @see CnpjFormatter#format
  # @see CnpjFmt.cnpj_fmt
  module CnpjInput
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
  # This function is invoked when the CNPJ formatter encounters an error during
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
  # May be a {CnpjFormatterOptions} instance, a {Hash} of option keys, or +nil+.
  #
  # @see CnpjFormatterOptions
  CnpjFormatterOptionsInput = Object
end
