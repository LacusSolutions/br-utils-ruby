# frozen_string_literal: true

require 'lacus-utils'

module CnpjGen
  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CnpjGen::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract (a generator option).
  class TypeMismatchError < TypeError
    include Error

    # @return [Object] the offending input value
    attr_reader :actual_input

    # @return [String] human-readable type of {#actual_input}
    attr_reader :actual_type

    # @return [String] description of the expected type
    attr_reader :expected_type

    # @return [String] the offending option key
    attr_reader :option_name

    # @param actual_input [Object] the offending option value
    # @param expected_type [String] description of the expected type
    # @param option_name [String] option key when the failure is option-related
    def initialize(actual_input, expected_type, option_name:)
      actual_type = LacusUtils.describe_type(actual_input)
      super(
        %(CNPJ generator option "#{option_name}" must be of type #{expected_type}. Got #{actual_type}.)
      )
      @actual_input = actual_input
      @actual_type = actual_type
      @expected_type = expected_type
      @option_name = option_name
    end
  end

  # API misuse error raised when the combination of provided arguments does not
  # match any valid overload-style signature.
  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end

  # Domain error ancestor for business-rule failures (validation and other domain
  # leaves). Prefer raising a leaf subclass.
  class DomainError < RangeError
    include Error
  end

  # Domain error raised when a generator option has a valid type but violates a
  # non-numeric, non-length domain rule (invalid +prefix+, or +type+ not in the
  # allowed set).
  class ValidationError < DomainError
    # @return [String] the offending option name
    attr_reader :option_name

    # @return [Object] the offending option value
    attr_reader :actual_input

    # @return [String, nil] human-readable reason when the failure is prefix-related
    attr_reader :reason

    # @return [Array<String>, nil] allowed values when the failure is type-related
    attr_reader :expected_values

    # @param option_name [String] the offending option key
    # @param actual_input [Object] the offending option value
    # @param reason [String, nil] human-readable reason for a prefix failure
    # @param expected_values [Array<String>, nil] allowed values for a type failure
    def initialize(option_name, actual_input, reason: nil, expected_values: nil)
      super(build_message(option_name, actual_input, reason, expected_values))
      @option_name = option_name
      @actual_input = actual_input
      @reason = reason
      @expected_values = expected_values&.dup
    end

    private

    def build_message(option_name, actual_input, reason, expected_values)
      if expected_values
        quoted = expected_values.map { |value| %("#{value}") }.join(', ')
        "CNPJ generator option \"#{option_name}\" accepts only the following values: #{quoted}. " \
          "Got \"#{actual_input}\"."
      else
        "CNPJ generator option \"#{option_name}\" with value \"#{actual_input}\" is invalid. #{reason}"
      end
    end
  end
end
