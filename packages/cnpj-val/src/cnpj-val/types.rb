# frozen_string_literal: true

module CnpjVal
  # Shared keyword option names for validator entry points.
  #
  # @see CnpjValidator#initialize
  # @see CnpjValidator#is_valid
  # @see CnpjVal.cnpj_val
  VALIDATOR_OPTION_KEYS = %i[case_sensitive type].freeze

  # Allowed values for the +type+ option.
  CNPJ_TYPE_OPTIONS = %w[alphanumeric numeric].freeze

  # Represents valid input types for CNPJ validation.
  #
  # A CNPJ may be given as:
  #
  # - A string of alphanumeric characters (with or without formatting).
  # - An array of strings, each representing one or more alphanumeric characters.
  #
  # @see CnpjValidator#is_valid
  # @see CnpjVal.cnpj_val
  CnpjInput = Object

  # Character set for CNPJ values (generation or validation).
  #
  # - +alphanumeric+ (default): digits and letters (+0-9A-Z+)
  # - +numeric+: digits only (+0-9+)
  CnpjType = Object

  # Options input accepted by validator constructors and {#is_valid} calls.
  #
  # May be a {CnpjValidatorOptions} instance, a partial options {Hash}, or +nil+.
  #
  # @see CnpjValidatorOptions
  CnpjValidatorOptionsInput = Object
end
