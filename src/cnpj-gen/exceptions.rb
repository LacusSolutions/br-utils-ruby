# frozen_string_literal: true

require 'lacus-utils'

module CnpjGen
  # Maps runtime type labels for error messages.
  module DescribeActualType
    module_function

    def call(value)
      actual_type = LacusUtils.describe_type(value)

      actual_type == 'hash' ? 'object' : actual_type
    end
  end
  private_constant :DescribeActualType

  # Base error for all `cnpj-gen` type-related errors.
  #
  # This base class extends the native {TypeError} and serves as the base for all
  # type validation errors in the CNPJ generator. It stores the actual input,
  # actual type, and expected type.
  class CnpjGeneratorTypeError < TypeError
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

  # Error raised when a specific option in the generator configuration has an
  # invalid type.
  #
  # The error message includes the option name, the actual input type and the
  # expected type.
  class CnpjGeneratorOptionsTypeError < CnpjGeneratorTypeError
    # @return [String] the offending option name
    attr_reader :option_name

    # @param option_name [String] the offending option key
    # @param actual_input [Object] the offending option value
    # @param expected_type [String] description of the expected type
    def initialize(option_name, actual_input, expected_type)
      actual_type = DescribeActualType.call(actual_input)

      super(
        actual_input,
        actual_type,
        expected_type,
        %(CNPJ generator option "#{option_name}" must be of type #{expected_type}. Got #{actual_type}.)
      )
      @option_name = option_name
    end
  end

  # Base exception for all `cnpj-gen` rules-related errors.
  #
  # This base class extends the native {StandardError} and serves as the base for
  # all non-type-related errors in {CnpjGenerator} and its dependencies. It is
  # suitable for validation errors, range errors, and other business logic
  # exceptions that are not strictly type-related.
  class CnpjGeneratorException < StandardError
  end

  # Exception raised when the +prefix+ option is invalid.
  #
  # This is a business logic exception and it is highly recommended that users
  # of the library catch it and handle it appropriately.
  class CnpjGeneratorOptionPrefixInvalidException < CnpjGeneratorException
    # @return [String] the sanitized prefix value
    attr_reader :actual_input

    # @return [String] human-readable reason why the prefix is invalid
    attr_reader :reason

    # @param actual_input [String] the sanitized prefix value
    # @param reason [String] human-readable reason why the prefix is invalid
    def initialize(actual_input, reason)
      super(%(CNPJ generator option "prefix" with value "#{actual_input}" is invalid. #{reason}))
      @actual_input = actual_input
      @reason = reason
    end
  end

  # Exception raised when the +type+ option is given a value that is not one of
  # the allowed values.
  #
  # The option must be one of the values in {CNPJ_TYPE_VALUES}. This is a business
  # logic exception and it is highly recommended that users of the library catch
  # it and handle it appropriately.
  class CnpjGeneratorOptionTypeInvalidException < CnpjGeneratorException
    # @return [String] the rejected type value
    attr_reader :actual_input

    # @return [Array<String>] allowed type values
    attr_reader :expected_values

    # @param actual_input [String] the rejected type value
    # @param expected_values [Array<String>] allowed type values
    def initialize(actual_input, expected_values)
      quoted = expected_values.map { |value| %("#{value}") }.join(', ')

      super(
        %(CNPJ generator option "type" accepts only the following values: #{quoted}. Got "#{actual_input}".)
      )
      @actual_input = actual_input
      @expected_values = expected_values.dup
    end
  end
end
