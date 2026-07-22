# frozen_string_literal: true

require 'lacus-utils'

module CpfVal
  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CpfVal::Error+ to catch every library error regardless of native
  # ancestry.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract (CPF input).
  class TypeMismatchError < TypeError
    include Error

    # @return [Object] the offending input value
    attr_reader :actual_input

    # @return [String] human-readable type of {#actual_input}
    attr_reader :actual_type

    # @return [String] description of the expected type
    attr_reader :expected_type

    # @param actual_input [Object] the offending input value
    # @param expected_type [String] description of the expected type
    def initialize(actual_input, expected_type)
      actual_type = LacusUtils.describe_type(actual_input)
      super("CPF input must be of type #{expected_type}. Got #{actual_type}.")
      @actual_input = actual_input
      @actual_type = actual_type
      @expected_type = expected_type
    end
  end
end
