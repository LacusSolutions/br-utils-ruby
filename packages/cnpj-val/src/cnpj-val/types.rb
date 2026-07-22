# frozen_string_literal: true

module CnpjVal
  # Shared keyword option names for validator entry points.
  #
  # @see CnpjValidator#initialize
  # @see CnpjValidator#is_valid
  # @see CnpjVal.cnpj_val
  VALIDATOR_OPTION_KEYS = %i[case_sensitive type].freeze

  # Allowed values for the +type+ option.
  CNPJ_TYPE_OPTIONS = %w[alphanumeric numeric].freeze

  # Case-equality predicate for CNPJ input: +String+ or +Array<String>+.
  #
  # Matches the runtime contract of {CnpjValidator#is_valid} and {CnpjVal.cnpj_val}.
  # Use {CnpjInput.accept?} or +CnpjInput === value+ (in +case+/+when+) to test
  # candidacy without raising.
  #
  # @example
  #   CnpjVal::CnpjInput.accept?('91415732000793') # => true
  #   CnpjVal::CnpjInput.accept?(%w[9 1 4 1])      # => true
  #   CnpjVal::CnpjInput.accept?(123)              # => false
  #   CnpjVal::CnpjInput.accept?([1, 2, 3])        # => false
  #
  # @see CnpjValidator#is_valid
  # @see CnpjVal.cnpj_val
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

  # Character set for CNPJ values (generation or validation).
  #
  # - +alphanumeric+ (default): digits and letters (+0-9A-Z+)
  # - +numeric+: digits only (+0-9+)
  CnpjType = Object

  # Options input accepted by validator constructors and {#is_valid} calls.
  #
  # May be a {CnpjValidatorOptions} instance, a partial options {Hash}, or +nil+.
  #
  # @see CnpjValidatorOptions
  CnpjValidatorOptionsInput = Object
end
