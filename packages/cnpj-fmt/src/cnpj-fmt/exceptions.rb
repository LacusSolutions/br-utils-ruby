# frozen_string_literal: true

require 'lacus-utils'

module CnpjFmt
  # Base error for all `cnpj-fmt` type-related errors.
  #
  # This base class extends the native {TypeError} and serves as the base for all
  # type validation errors in the CNPJ formatter. It stores the actual input,
  # actual type, and expected type.
  class CnpjFormatterTypeError < TypeError
    # @return [Object] the offending input value
    attr_reader :actual_input

    # @return [String] human-readable type of {#actual_input}
    attr_reader :actual_type

    # @return [String] description of the expected type
    attr_reader :expected_type

    # @param actual_input [Object] the offending input value
    # @param actual_type [String] human-readable type of +actual_input+
    # @param expected_type [String] description of the expected type
    # @param message [String] error message
    def initialize(actual_input, actual_type, expected_type, message)
      super(message)
      @actual_input = actual_input
      @actual_type = actual_type
      @expected_type = expected_type
    end
  end

  # Error raised when the input provided to the CNPJ formatter is not of the
  # expected type ({CnpjInput}).
  #
  # The error message includes both the actual input type and the expected type.
  #
  # @see CnpjInput
  class CnpjFormatterInputTypeError < CnpjFormatterTypeError
    # @param actual_input [Object] the offending input value
    # @param expected_type [String] description of the expected type (e.g.
    #   +"string or string[]"+)
    def initialize(actual_input, expected_type)
      actual_type = LacusUtils.describe_type(actual_input)

      super(
        actual_input,
        actual_type,
        expected_type,
        "CNPJ input must be of type #{expected_type}. Got #{actual_type}."
      )
    end
  end

  # Error raised when a specific option in the formatter configuration has an
  # invalid type.
  #
  # The error message includes the option name, the actual input type and the
  # expected type.
  class CnpjFormatterOptionsTypeError < CnpjFormatterTypeError
    # @return [String] the offending option name
    attr_reader :option_name

    # @param option_name [String] the offending option key
    # @param actual_input [Object] the offending option value
    # @param expected_type [String] description of the expected type
    def initialize(option_name, actual_input, expected_type)
      actual_type = LacusUtils.describe_type(actual_input)

      super(
        actual_input,
        actual_type,
        expected_type,
        %(CNPJ formatting option "#{option_name}" must be of type #{expected_type}. Got #{actual_type}.)
      )
      @option_name = option_name
    end
  end

  # Base exception for all `cnpj-fmt` rules-related errors.
  #
  # This base class extends the native {StandardError} and serves as the base for
  # all non-type-related errors in the {CnpjFormatter} and its dependencies. It is
  # suitable for validation errors, range errors, and other business logic
  # exceptions that are not strictly type-related.
  class CnpjFormatterException < StandardError
  end

  # Formats the original input for inclusion in a length exception message.
  module FormatLengthExceptionInput
    module_function

    def call(actual_input)
      return %("#{actual_input}") if actual_input.is_a?(String)

      return "sequence[#{actual_input.length}]" if actual_input.is_a?(Array)

      actual_input.inspect
    end
  end
  private_constant :FormatLengthExceptionInput

  # Exception raised when the CNPJ string input (after optional processing) does
  # not have the required length.
  #
  # A valid CNPJ must contain exactly 14 alphanumeric characters. The error
  # message distinguishes between the original input and the evaluated one (which
  # strips punctuation characters).
  class CnpjFormatterInputLengthException < CnpjFormatterException
    # @return [String, Array<String>] the original input
    attr_reader :actual_input

    # @return [String] the sanitized alphanumeric string
    attr_reader :evaluated_input

    # @return [Integer] expected length ({CNPJ_LENGTH})
    attr_reader :expected_length

    # @param actual_input [String, Array<String>] the original input
    # @param evaluated_input [String] the sanitized alphanumeric string
    # @param expected_length [Integer] expected length (14)
    def initialize(actual_input, evaluated_input, expected_length)
      super(build_message(actual_input, evaluated_input, expected_length))
      @actual_input = actual_input
      @evaluated_input = evaluated_input
      @expected_length = expected_length
    end

    private

    def build_message(actual_input, evaluated_input, expected_length)
      fmt_actual_input = FormatLengthExceptionInput.call(actual_input)
      fmt_evaluated_input =
        if actual_input == evaluated_input
          evaluated_input.length.to_s
        else
          %(#{evaluated_input.length} in "#{evaluated_input}")
        end

      "CNPJ input #{fmt_actual_input} does not contain #{expected_length} characters. " \
        "Got #{fmt_evaluated_input}."
    end
  end

  # Exception raised when +hidden_start+ or +hidden_end+ option values are outside
  # the valid range for CNPJ formatting.
  #
  # The valid range bounds are between 0 and 13 (inclusive), representing the
  # indices of the 14-character CNPJ string. The error message includes the
  # option name, the actual input value, and the expected range bounds.
  class CnpjFormatterOptionsHiddenRangeInvalidException < CnpjFormatterException
    # @return [String] the offending option name
    attr_reader :option_name

    # @return [Integer] the offending value
    attr_reader :actual_input

    # @return [Integer] minimum valid index (0)
    attr_reader :min_expected_value

    # @return [Integer] maximum valid index (13)
    attr_reader :max_expected_value

    # @param option_name [String] the offending option key
    # @param actual_input [Integer] the offending value
    # @param min_expected_value [Integer] minimum valid index
    # @param max_expected_value [Integer] maximum valid index
    def initialize(option_name, actual_input, min_expected_value, max_expected_value)
      super(
        %(CNPJ formatting option "#{option_name}" must be an integer between ) \
        "#{min_expected_value} and #{max_expected_value}. Got #{actual_input}."
      )
      @option_name = option_name
      @actual_input = actual_input
      @min_expected_value = min_expected_value
      @max_expected_value = max_expected_value
    end
  end

  # Exception raised when a character is not allowed to be used as a key character
  # on options.
  class CnpjFormatterOptionsForbiddenKeyCharacterException < CnpjFormatterException
    # @return [String] the offending option name
    attr_reader :option_name

    # @return [String] the offending option value
    attr_reader :actual_input

    # @return [Array<String>] disallowed characters found in the value
    attr_reader :forbidden_characters

    # @param option_name [String] the offending option key
    # @param actual_input [String] the offending option value
    # @param forbidden_characters [Array<String>] disallowed characters
    def initialize(option_name, actual_input, forbidden_characters)
      quoted = forbidden_characters.map { |character| %("#{character}") }.join(', ')
      super(
        %(Value "#{actual_input}" for CNPJ formatting option "#{option_name}" contains ) \
        "disallowed characters (#{quoted})."
      )
      @option_name = option_name
      @actual_input = actual_input
      @forbidden_characters = forbidden_characters.dup
    end
  end
end
