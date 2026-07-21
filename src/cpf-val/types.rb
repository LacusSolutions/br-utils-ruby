# frozen_string_literal: true

module CpfVal
  # Represents valid input types for CPF validation.
  #
  # A CPF may be given as:
  #
  # - A string of numeric characters (with or without formatting).
  # - An array of strings, each representing one or more numeric characters
  #   and/or punctuation.
  #
  # @see CpfValidator#is_valid
  # @see CpfVal.cpf_val
  CpfInput = Object
end
