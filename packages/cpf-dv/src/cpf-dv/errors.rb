# frozen_string_literal: true

require 'json'
require 'lacus-utils'

module CpfDV
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

  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CpfDV::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract.
  #
  # Raised when the input provided to {CpfCheckDigits} is not a +String+ or
  # +Array<String>+. The error message includes both the actual type of the
  # input and the expected type.
  class TypeMismatchError < TypeError
    include Error

    # @return [Object] the offending input value
    attr_reader :actual_input

    # @return [String] human-readable type of {#actual_input}
    attr_reader :actual_type

    # @return [String] description of the expected type
    attr_reader :expected_type

    # @param actual_input [Object] the offending input value (the whole array
    #   when a non-string element is found)
    # @param expected_type [String] description of the expected type (e.g.
    #   +"string or string[]"+)
    def initialize(actual_input, expected_type)
      actual_type = LacusUtils.describe_type(actual_input)

      super("CPF input must be of type #{expected_type}. Got #{actual_type}.")
      @actual_input = actual_input
      @actual_type = actual_type
      @expected_type = expected_type
    end
  end

  # Domain error ancestor for business-rule failures (length, validation, and
  # other domain leaves). Prefer raising a leaf subclass.
  class DomainError < RangeError
    include Error
  end

  # Domain error raised when a string, array, or other collection has a length
  # outside the bounds required by the domain rule.
  #
  # A valid CPF input must contain between 9 and 11 digits. The error message
  # distinguishes between the original input and the evaluated one (which strips
  # punctuation characters).
  class InvalidLengthError < DomainError
    # @return [String, Array<String>] the original input
    attr_reader :actual_input

    # @return [String] the digits-only string used for counting
    attr_reader :evaluated_input

    # @return [Integer] minimum expected length (9)
    attr_reader :min_expected_length

    # @return [Integer] maximum expected length (11)
    attr_reader :max_expected_length

    # @param actual_input [String, Array<String>] the original input
    # @param evaluated_input [String] the digits-only string
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

      "CPF input #{fmt_actual} does not contain #{min_len} to #{max_len} digits. " \
        "Got #{fmt_evaluated}."
    end
  end

  # Domain error raised when a value has a valid type and length but violates a
  # validation rule that is not length-based (e.g. repeated digits).
  #
  # This is a business-logic exception; callers should catch it and handle it
  # appropriately.
  class ValidationError < DomainError
    # @return [String, Array<String>] the original input
    attr_reader :actual_input

    # @return [String] human-readable reason why the input is invalid
    attr_reader :reason

    # @param actual_input [String, Array<String>] the original input
    # @param reason [String] human-readable reason why the input is invalid
    def initialize(actual_input, reason)
      super("CPF input #{FormatActualInput.call(actual_input)} is invalid. #{reason}")
      @actual_input = actual_input
      @reason = reason
    end
  end
end
