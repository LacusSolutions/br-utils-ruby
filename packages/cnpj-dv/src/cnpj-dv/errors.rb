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

  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CnpjDV::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract.
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

      super("CNPJ input must be of type #{expected_type}. Got #{actual_type}.")
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
  class InvalidLengthError < DomainError
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

  # Domain error raised when a value has a valid type and length but violates a
  # validation rule that is not numeric-range or length-based (e.g. ineligible
  # base/branch ID or repeated numeric digits).
  class ValidationError < DomainError
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
