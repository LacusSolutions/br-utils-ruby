# frozen_string_literal: true

require_relative 'cnpj_validator'

module CnpjVal
  # Helper function to simplify the usage of the {CnpjValidator} class.
  #
  # If no options are provided, it validates a CNPJ string or array of strings
  # using default settings. If options are provided, they control case
  # sensitivity and the type of characters to be validated. Invalid CNPJ data
  # returns +false+; only API misuse raises documented errors.
  #
  # Pass either keyword arguments **or** a {Hash}/{CnpjValidatorOptions} instance
  # for options — not both.
  #
  # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
  #   strings
  # @param options [CnpjValidatorOptions, Hash, nil] default validator options
  # @param keywords [Hash] option keyword overrides (mutually exclusive with
  #   +options+; see {CnpjValidatorOptions::OPTION_KEYS})
  # @return [Boolean] +true+ when valid, +false+ otherwise
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+,
  #   or if any option has an invalid type
  # @raise [ValidationError] if +type+ is not one of the allowed values
  # @see CnpjValidator#is_valid for detailed option descriptions
  # @see CnpjValidator
  #
  # @example
  #   CnpjVal.cnpj_val('91415732000793') # => true
  #   CnpjVal.cnpj_val('9JN7MGLJZXIO50') # => true
  #   CnpjVal.cnpj_val('9JN7MGLJZXIO51') # => false
  def self.cnpj_val(cnpj_input, options = nil, **keywords)
    CnpjValidator.new(options, **keywords).is_valid(cnpj_input)
  end
end
