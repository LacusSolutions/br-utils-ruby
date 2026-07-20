# frozen_string_literal: true

require_relative 'errors'

module CnpjDV
  # Minimum number of characters required for the CNPJ check digits calculation.
  CNPJ_MIN_LENGTH = 12

  # Maximum number of characters accepted as input for the CNPJ check digits
  # calculation.
  CNPJ_MAX_LENGTH = 14

  CNPJ_BASE_ID_LENGTH = 8
  CNPJ_INVALID_BASE_ID = '0' * CNPJ_BASE_ID_LENGTH
  CNPJ_BRANCH_ID_LENGTH = 4
  CNPJ_INVALID_BRANCH_ID = '0' * CNPJ_BRANCH_ID_LENGTH

  DELTA_FACTOR = '0'.ord
  WEIGHTS = [2, 3, 4, 5, 6, 7, 8, 9].freeze
  DIGIT_CHARS = '0123456789'

  private_constant :CNPJ_BASE_ID_LENGTH, :CNPJ_INVALID_BASE_ID,
                   :CNPJ_BRANCH_ID_LENGTH, :CNPJ_INVALID_BRANCH_ID,
                   :DELTA_FACTOR, :WEIGHTS, :DIGIT_CHARS

  # Calculates and exposes CNPJ check digits from a valid base input.
  #
  # Validates length, base ID, branch ID and rejects repeated numeric digits.
  #
  # @example Numeric base
  #   check_digits = CnpjDV::CnpjCheckDigits.new('914157320007')
  #   check_digits.first   # => '9'
  #   check_digits.second  # => '3'
  #   check_digits.both    # => '93'
  #   check_digits.cnpj    # => '91415732000793'
  #
  # @example Alphanumeric base
  #   check_digits = CnpjDV::CnpjCheckDigits.new('MGKGMJ9X0001')
  #   check_digits.first   # => '6'
  #   check_digits.second  # => '8'
  #   check_digits.both    # => '68'
  #   check_digits.cnpj    # => 'MGKGMJ9X000168'
  class CnpjCheckDigits
    # Creates a calculator for the given CNPJ base (12 to 14 characters).
    #
    # @param cnpj_input [String, Array<String>] alphanumeric CNPJ with or without
    #   formatting, or an array of strings
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    # @raise [InvalidLengthError] when character count is not between 12 and 14
    # @raise [ValidationError] when base ID is all zero (+00.000.000+), branch ID
    #   is all zero (+0000+) or all digits are numeric the same (repeated digits,
    #   e.g. +77.777.777/7777-...+)
    def initialize(cnpj_input)
      parsed_input = parse_input(cnpj_input)

      validate_length(parsed_input, cnpj_input)
      validate_base_id(parsed_input, cnpj_input)
      validate_branch_id(parsed_input, cnpj_input)
      validate_non_repeated_digits(parsed_input, cnpj_input)

      @cnpj_chars = parsed_input[0, CNPJ_MIN_LENGTH]
      @cached_first_digit = nil
      @cached_second_digit = nil
    end

    # First check digit (13th character of the full CNPJ).
    #
    # @return [String] a single numeric character (+"0"+–+"9"+)
    def first
      @cached_first_digit = _calculate(@cnpj_chars) if @cached_first_digit.nil?

      DIGIT_CHARS[@cached_first_digit]
    end

    # Second check digit (14th character of the full CNPJ).
    #
    # @return [String] a single numeric character (+"0"+–+"9"+)
    def second
      @cached_second_digit = _calculate([*@cnpj_chars, first]) if @cached_second_digit.nil?

      DIGIT_CHARS[@cached_second_digit]
    end

    # Both check digits concatenated (13th and 14th characters).
    #
    # @return [String] two-character numeric string
    def both
      first + second
    end

    # Full 14-character CNPJ (base 12 characters concatenated with the 2 check
    # digits).
    #
    # @return [String] 14-character CNPJ (base may contain letters + numeric DVs)
    def cnpj
      @cnpj_chars.join + both
    end

    # Protected (not private) so test spy subclasses can override and call +super+.
    # Leading underscore matches the cross-language helper name (`_calculate`).
    protected

    # Computes a single check digit using the standard CNPJ modulo-11 algorithm.
    #
    # @param cnpj_sequence [Array<String>] characters used in the weighted sum
    # @return [Integer] check digit in the range 0–9
    def _calculate(cnpj_sequence)
      length = cnpj_sequence.length
      sum_result = 0

      (length - 1).downto(0) do |index|
        char_value = cnpj_sequence[index].ord - DELTA_FACTOR
        sum_result += char_value * WEIGHTS[(length - 1 - index) % 8]
      end

      remainder = sum_result % 11

      remainder < 2 ? 0 : 11 - remainder
    end

    private

    # Parses a string or an array of strings into alphanumeric characters.
    #
    # @param cnpj_input [Object] candidate CNPJ input
    # @return [Array<String>] uppercase alphanumeric characters
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    def parse_input(cnpj_input)
      return parse_string_input(cnpj_input) if cnpj_input.is_a?(String)
      return parse_array_input(cnpj_input) if cnpj_input.is_a?(Array)

      raise TypeMismatchError.new(cnpj_input, 'string or string[]')
    end

    # Strips non-alphanumeric characters and uppercases the remainder.
    #
    # @param cnpj_string [String] raw or formatted CNPJ string
    # @return [Array<String>] uppercase alphanumeric characters
    def parse_string_input(cnpj_string)
      result = []

      cnpj_string.each_char do |char|
        code = char.ord
        if code.between?(48, 57) || code.between?(65, 90)
          result << char
        elsif code.between?(97, 122)
          result << (code - 32).chr
        end
      end

      result
    end

    # Concatenates an array of strings and normalizes the result.
    #
    # @param cnpj_array [Array] candidate array of string chunks
    # @return [Array<String>] uppercase alphanumeric characters
    # @raise [TypeMismatchError] when input is not a +String+ or +Array<String>+
    def parse_array_input(cnpj_array)
      return [] if cnpj_array.empty?

      raise TypeMismatchError.new(cnpj_array, 'string or string[]') unless cnpj_array.all?(String)

      parse_string_input(cnpj_array.join)
    end

    # Ensures character count is between {CNPJ_MIN_LENGTH} and
    # {CNPJ_MAX_LENGTH}.
    #
    # @param cnpj_chars [Array<String>] normalized characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [InvalidLengthError] when character count is not between 12 and 14
    def validate_length(cnpj_chars, original_input)
      chars_count = cnpj_chars.length

      return if chars_count.between?(CNPJ_MIN_LENGTH, CNPJ_MAX_LENGTH)

      raise InvalidLengthError.new(
        original_input,
        cnpj_chars.join,
        CNPJ_MIN_LENGTH,
        CNPJ_MAX_LENGTH
      )
    end

    # Rejects base ID (first 8 digits) when it is all zeros.
    #
    # @param cnpj_chars [Array<String>] normalized characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [ValidationError] when base ID is all zeros (+00.000.000+)
    def validate_base_id(cnpj_chars, original_input)
      return unless cnpj_chars[0, CNPJ_BASE_ID_LENGTH].all? { |char| char == '0' }

      raise ValidationError.new(
        original_input,
        "Base ID \"#{CNPJ_INVALID_BASE_ID}\" is not eligible."
      )
    end

    # Rejects branch ID (digits 9–12) when it is all zeros.
    #
    # @param cnpj_chars [Array<String>] normalized characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [ValidationError] when branch ID is all zeros (+0000+)
    def validate_branch_id(cnpj_chars, original_input)
      branch_start = CNPJ_BASE_ID_LENGTH
      branch_end = branch_start + CNPJ_BRANCH_ID_LENGTH
      branch_id = cnpj_chars[branch_start...branch_end]

      return unless branch_id.all? { |char| char == '0' }

      raise ValidationError.new(
        original_input,
        "Branch ID \"#{CNPJ_INVALID_BRANCH_ID}\" is not eligible."
      )
    end

    # Rejects inputs where all first 12 characters are the same numeric digit.
    #
    # @param cnpj_chars [Array<String>] normalized characters
    # @param original_input [String, Array<String>] original caller input
    # @raise [ValidationError] when all digits are numeric the same (repeated
    #   digits, e.g. +77.777.777/7777-...+)
    def validate_non_repeated_digits(cnpj_chars, original_input)
      first_char = cnpj_chars[0]
      return unless first_char.match?(/\A\d\z/)
      return unless cnpj_chars[1, CNPJ_MIN_LENGTH - 1].all? { |char| char == first_char }

      raise ValidationError.new(
        original_input,
        'Repeated digits are not considered valid.'
      )
    end
  end
end
