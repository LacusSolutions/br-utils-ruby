# frozen_string_literal: true

require 'json'
require 'lacus-utils'

module CnpjDV
  # Formats the original input for inclusion in an exception message.
  module FormatActualInput
    module_function

    # @param actual_input [Object] the original input value
    # @return [String] a quoted string, or compact JSON for arrays
    def call(actual_input)
      return "\"#{actual_input}\"" if actual_input.is_a?(String)

      JSON.generate(actual_input)
    end
  end
  private_constant :FormatActualInput

  # Base error for all `cnpj-dv` type-related errors.
  #
  # This class extends the native {TypeError} and serves as the base for all
  # type validation errors in {CnpjCheckDigits}.
  class CnpjCheckDigitsTypeError < TypeError
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

  # Error raised when the input provided to {CnpjCheckDigits} is not of the
  # expected type (+String+ or +Array<String>+). The error message includes both
  # the actual type of the input and the expected type.
  class CnpjCheckDigitsInputTypeError < CnpjCheckDigitsTypeError
    # @param actual_input [Object] the offending input value (the whole array when
    #   a non-string element is found)
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

  # Base exception for all `cnpj-dv` rules-related errors.
  #
  # This class extends the native {StandardError} and serves as the base for all
  # non-type-related errors in {CnpjCheckDigits}. It is suitable for validation
  # errors, range errors, and other business logic exceptions that are not
  # strictly type-related.
  class CnpjCheckDigitsException < StandardError
  end

  # Error raised when the input (after optional processing) does not have the
  # required length to calculate the check digits. A valid CNPJ input must
  # contain between 12 and 14 alphanumeric characters. The error message
  # distinguishes between the original input and the evaluated one (which strips
  # punctuation characters).
  class CnpjCheckDigitsInputLengthException < CnpjCheckDigitsException
    # @return [String, Array<String>] the original input
    attr_reader :actual_input

    # @return [String] the normalized alphanumeric string
    attr_reader :evaluated_input

    # @return [Integer] minimum expected length (12)
    attr_reader :min_expected_length

    # @return [Integer] maximum expected length (14)
    attr_reader :max_expected_length

    # @param actual_input [String, Array<String>] the original input
    # @param evaluated_input [String] the normalized alphanumeric string
    # @param min_expected_length [Integer] minimum expected length
    # @param max_expected_length [Integer] maximum expected length
    def initialize(actual_input, evaluated_input, min_expected_length, max_expected_length)
      super(build_message(actual_input, evaluated_input, min_expected_length, max_expected_length))
      @actual_input = actual_input
      @evaluated_input = evaluated_input
      @min_expected_length = min_expected_length
      @max_expected_length = max_expected_length
    end

    private

    def build_message(actual_input, evaluated_input, min_len, max_len)
      fmt_actual = FormatActualInput.call(actual_input)
      fmt_evaluated =
        if actual_input == evaluated_input
          evaluated_input.length.to_s
        else
          "#{evaluated_input.length} in \"#{evaluated_input}\""
        end

      "CNPJ input #{fmt_actual} does not contain #{min_len} to #{max_len} characters. " \
        "Got #{fmt_evaluated}."
    end
  end

  # Exception raised when the CNPJ input contains invalid character sequences,
  # like all digits are repeated. This is a business logic exception and it is
  # highly recommended that users of the library catch it and handle it
  # appropriately.
  class CnpjCheckDigitsInputInvalidException < CnpjCheckDigitsException
    # @return [String, Array<String>] the original input
    attr_reader :actual_input

    # @return [String] human-readable reason why the input is invalid
    attr_reader :reason

    # @param actual_input [String, Array<String>] the original input
    # @param reason [String] human-readable reason why the input is invalid
    def initialize(actual_input, reason)
      super("CNPJ input #{FormatActualInput.call(actual_input)} is invalid. #{reason}")
      @actual_input = actual_input
      @reason = reason
    end
  end
end
