# frozen_string_literal: true

require_relative 'cpf_validator'

module CpfVal
  # Helper function to simplify the usage of the {CpfValidator} class.
  #
  # Validates a CPF string or array of strings and returns whether it is a valid
  # Brazilian CPF. Invalid CPF data returns +false+; only API misuse raises
  # documented errors.
  #
  # @param cpf_input [String, Array<String>] CPF value as a string or array of
  #   strings
  # @return [Boolean] +true+ when valid, +false+ otherwise
  # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+
  # @see CpfValidator#is_valid
  # @see CpfValidator
  #
  # @example
  #   CpfVal.cpf_val('82911017366') # => true
  #   CpfVal.cpf_val('33528612691') # => false
  def self.cpf_val(cpf_input)
    CpfValidator.new.is_valid(cpf_input)
  end
end
