# frozen_string_literal: true

require 'lacus-utils'

module CnpjFmt
  # Formats the original input for inclusion in a length error message.
  module FormatLengthExceptionInput
    module_function

    def call(actual_input)
      return %("#{actual_input}") if actual_input.is_a?(String)

      return "sequence[#{actual_input.length}]" if actual_input.is_a?(Array)

      actual_input.inspect
    end
  end
  private_constant :FormatLengthExceptionInput

  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CnpjFmt::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # Raised when an argument's runtime type does not match the type required by
  # the API contract (CNPJ input or a formatting option).
  class TypeMismatchError < TypeError
    include Error

    # @return [Object] the offending input value
    attr_reader :actual_input

    # @return [String] human-readable type of {#actual_input}
    attr_reader :actual_type

    # @return [String] description of the expected type
    attr_reader :expected_type

    # @return [String, nil] the offending option key, or +nil+ for CNPJ input
    attr_reader :option_name

    # @param actual_input [Object] the offending input or option value
    # @param expected_type [String] description of the expected type
    # @param option_name [String, nil] option key when the failure is option-related
    def initialize(actual_input, expected_type, option_name: nil)
      actual_type = LacusUtils.describe_type(actual_input)
      super(build_message(actual_type, expected_type, option_name))
      @actual_input = actual_input
      @actual_type = actual_type
      @expected_type = expected_type
      @option_name = option_name
    end

    private

    def build_message(actual_type, expected_type, option_name)
      if option_name
        %(CNPJ formatting option "#{option_name}" must be of type #{expected_type}. Got #{actual_type}.)
      else
        "CNPJ input must be of type #{expected_type}. Got #{actual_type}."
      end
    end
  end

  # Raised when the combination of provided arguments does not match any valid
  # overload-style signature.
  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end

  # Raised when arguments have invalid value or key constraints and rules are
  # violated.
  class DomainError < RangeError
    include Error
  end

  # Raised when +hidden_start+ or +hidden_end+ falls outside the valid index
  # range for CNPJ formatting.
  class OutOfRangeError < DomainError
    # @return [String] the offending option name
    attr_reader :option_name

    # @return [Integer] the offending value
    attr_reader :actual_input

    # @return [Integer] minimum valid index
    attr_reader :min_expected_value

    # @return [Integer] maximum valid index
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

  # Constructed when the sanitized CNPJ input does not have the required length.
  #
  # Passed to the +on_fail+ callback as a {DomainError}; not raised from
  # {CnpjFormatter#format}.
  class InvalidLengthError < DomainError
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

  # Raised when a key option contains a disallowed character.
  class ValidationError < DomainError
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
