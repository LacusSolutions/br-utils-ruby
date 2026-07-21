# frozen_string_literal: true

require 'lacus-utils'

module CnpjVal
  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CnpjVal::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract (CNPJ input or a validator option).
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
        %(CNPJ validator option "#{option_name}" must be of type #{expected_type}. Got #{actual_type}.)
      else
        "CNPJ input must be of type #{expected_type}. Got #{actual_type}."
      end
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

  # Domain error raised when a validator option has a valid type but violates a
  # non-numeric, non-length domain rule (+type+ not in the allowed set).
  class ValidationError < DomainError
    # @return [String] the offending option name
    attr_reader :option_name

    # @return [Object] the offending option value
    attr_reader :actual_input

    # @return [Array<String>] allowed values for the option
    attr_reader :expected_values

    # @param option_name [String] the offending option key
    # @param actual_input [Object] the offending option value
    # @param expected_values [Array<String>] allowed values for the option
    def initialize(option_name, actual_input, expected_values:)
      quoted = expected_values.map { |value| %("#{value}") }.join(', ')
      super(
        "CNPJ validator option \"#{option_name}\" accepts only the following values: #{quoted}. " \
        "Got \"#{actual_input}\"."
      )
      @option_name = option_name
      @actual_input = actual_input
      @expected_values = expected_values.dup.freeze
    end
  end
end
