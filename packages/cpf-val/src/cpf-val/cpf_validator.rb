# frozen_string_literal: true

require 'cpf-dv'

require_relative 'errors'
require_relative 'types'

module CpfVal
  # The standard length of a CPF (Cadastro de Pessoa Física) identifier (11
  # digits).
  CPF_LENGTH = 11

  # Validator for CPF (Cadastro de Pessoa Física) identifiers.
  #
  # Validates CPF strings according to the Brazilian CPF validation algorithm.
  # Invalid CPF data returns +false+; only API misuse raises documented errors.
  class CpfValidator
    NON_DIGIT_PATTERN = /\D/

    private_constant :NON_DIGIT_PATTERN

    # Validates a CPF input.
    #
    # A CPF is considered valid when, after stripping every non-digit character,
    # it has exactly {CPF_LENGTH} digits, its base is not an all-identical-digit
    # sequence, and both check digits match the ones computed via the standard
    # modulo-11 algorithm. Invalid values return +false+ instead of raising.
    #
    # @param cpf_input [String, Array<String>] CPF value as a string or array of
    #   strings
    # @return [Boolean] +true+ when valid, +false+ otherwise
    # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+
    #
    # @example
    #   CpfValidator.new.is_valid('82911017366') # => true
    # rubocop:disable Naming/PredicatePrefix -- public API matches JS/Python `is_valid`
    def is_valid(cpf_input)
      actual_input = to_string_input(cpf_input)
      sanitized_cpf = actual_input.gsub(NON_DIGIT_PATTERN, '')

      return false unless sanitized_cpf.length == CPF_LENGTH

      validate_with_check_digits(sanitized_cpf)
    end
    # rubocop:enable Naming/PredicatePrefix

    private

    def to_string_input(cpf_input)
      raise TypeMismatchError.new(cpf_input, 'string or string[]') unless CpfInput.accept?(cpf_input)

      return cpf_input if cpf_input.is_a?(String)

      cpf_input.join
    end

    def validate_with_check_digits(sanitized_cpf)
      cpf_check_digits = CpfDV::CpfCheckDigits.new(sanitized_cpf)

      sanitized_cpf == cpf_check_digits.cpf
    rescue CpfDV::Error
      false
    end
  end
end
