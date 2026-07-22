# frozen_string_literal: true

module CpfVal
  # Case-equality predicate for CPF input: +String+ or +Array<String>+.
  #
  # Matches the runtime contract of {CpfValidator#is_valid} and {CpfVal.cpf_val}
  # (same shape as +cpf-fmt+ / +cnpj-val+ input handling). Use
  # {CpfInput.accept?} or +CpfInput === value+ (in +case+/+when+) to test
  # candidacy without raising.
  #
  # @example
  #   CpfVal::CpfInput.accept?('82911017366') # => true
  #   CpfVal::CpfInput.accept?(%w[8 2 9 1 1]) # => true
  #   CpfVal::CpfInput.accept?(123)           # => false
  #   CpfVal::CpfInput.accept?([1, 2, 3])     # => false
  #
  # @see CpfValidator#is_valid
  # @see CpfVal.cpf_val
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
end
