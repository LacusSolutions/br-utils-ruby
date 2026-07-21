# frozen_string_literal: true

require_relative 'errors'

module CpfDV
  # Minimum number of digits required for the CPF check digits calculation.
  CPF_MIN_LENGTH = 9

  # Maximum number of digits accepted as input for the CPF check digits
  # calculation.
  CPF_MAX_LENGTH = 11

  DELTA_FACTOR = '0'.ord
  DIGIT_CHARS = '0123456789'

  private_constant :DELTA_FACTOR, :DIGIT_CHARS

  # Calculates and exposes CPF check digits from a valid base input.
  #
  # Validates length and rejects repeated-digit sequences.
  #
  # @example
  #   check_digits = CpfDV::CpfCheckDigits.new('054496519')
  #   check_digits.first   # => '1'
  #   check_digits.second  # => '0'
  #   check_digits.both    # => '10'
  #   check_digits.cpf     # => '05449651910'
  class CpfCheckDigits
    # Creates a calculator for the given CPF base (9 to 11 digits).
    #
    # @param cpf_input [String, Array<String>] digits with or without formatting,
    #   or an array of strings
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    # @raise [InvalidLengthError] when digit count is not between 9 and 11
    # @raise [ValidationError] when all first 9 digits are the same (repeated
    #   digits, e.g. +777.777.777-...+)
    def initialize(cpf_input)
      parsed_input = parse_input(cpf_input)

      validate_length(parsed_input, cpf_input)
      validate_non_repeated_digits(parsed_input, cpf_input)

      @cpf_digits = parsed_input[0, CPF_MIN_LENGTH]
      @cached_first_digit = nil
      @cached_second_digit = nil
    end

    # First check digit (10th digit of the full CPF).
    #
    # @return [String] a single numeric character (+"0"+–+"9"+)
    def first
      @cached_first_digit = _calculate(@cpf_digits) if @cached_first_digit.nil?

      DIGIT_CHARS[@cached_first_digit]
    end

    # Second check digit (11th digit of the full CPF).
    #
    # @return [String] a single numeric character (+"0"+–+"9"+)
    def second
      @cached_second_digit = _calculate([*@cpf_digits, first]) if @cached_second_digit.nil?

      DIGIT_CHARS[@cached_second_digit]
    end

    # Both check digits concatenated (10th and 11th digits).
    #
    # @return [String] two-character numeric string
    def both
      first + second
    end

    # Full 11-digit CPF (base 9 digits concatenated with the 2 check digits).
    #
    # @return [String] 11-digit CPF
    def cpf
      @cpf_digits.join + both
    end

    # Protected (not private) so test spy subclasses can override and call +super+.
    # Leading underscore matches the cross-language helper name (`_calculate`).
    protected

    # Computes a single check digit using the standard CPF modulo-11 algorithm.
    #
    # @param cpf_sequence [Array<String>] digit characters used in the weighted sum
    # @return [Integer] check digit in the range 0–9
    def _calculate(cpf_sequence)
      factor = cpf_sequence.length + 1
      sum_result = 0

      cpf_sequence.each do |digit_char|
        sum_result += (digit_char.ord - DELTA_FACTOR) * factor
        factor -= 1
      end

      remainder = 11 - (sum_result % 11)

      remainder > 9 ? 0 : remainder
    end

    private

    # Parses a string or an array of strings into digit characters.
    #
    # @param cpf_input [Object] candidate CPF input
    # @return [Array<String>] digit characters
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    def parse_input(cpf_input)
      return parse_string_input(cpf_input) if cpf_input.is_a?(String)
      return parse_array_input(cpf_input) if cpf_input.is_a?(Array)

      raise TypeMismatchError.new(cpf_input, 'string or string[]')
    end

    # Strips non-digit characters and keeps the remainder as characters.
    #
    # @param cpf_string [String] raw or formatted CPF string
    # @return [Array<String>] digit characters
    def parse_string_input(cpf_string)
      result = []

      cpf_string.each_char do |char|
        code = char.ord
        result << char if code.between?(48, 57)
      end

      result
    end

    # Concatenates an array of strings and parses the result.
    #
    # @param cpf_array [Array] candidate array of string chunks
    # @return [Array<String>] digit characters
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    def parse_array_input(cpf_array)
      return [] if cpf_array.empty?

      raise TypeMismatchError.new(cpf_array, 'string or string[]') unless cpf_array.all?(String)

      parse_string_input(cpf_array.join)
    end

    # Ensures digit count is between {CPF_MIN_LENGTH} and {CPF_MAX_LENGTH}.
    #
    # @param cpf_digits [Array<String>] normalized digit characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [InvalidLengthError] when digit count is not between 9 and 11
    def validate_length(cpf_digits, original_input)
      digits_count = cpf_digits.length

      return if digits_count.between?(CPF_MIN_LENGTH, CPF_MAX_LENGTH)

      raise InvalidLengthError.new(
        original_input,
        cpf_digits.join,
        CPF_MIN_LENGTH,
        CPF_MAX_LENGTH
      )
    end

    # Rejects inputs where all first 9 digits are the same.
    #
    # @param cpf_digits [Array<String>] normalized digit characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [ValidationError] when all first 9 digits are the same (repeated
    #   digits, e.g. +777.777.777-...+)
    def validate_non_repeated_digits(cpf_digits, original_input)
      first_char = cpf_digits[0]
      return unless cpf_digits[1, CPF_MIN_LENGTH - 1].all? { |char| char == first_char }

      raise ValidationError.new(
        original_input,
        'Repeated digits are not considered valid.'
      )
    end
  end
end
