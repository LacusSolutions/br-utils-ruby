# frozen_string_literal: true

require_relative 'cpf-gen/version'
require_relative 'cpf-gen/errors'
require_relative 'cpf-gen/types'
require_relative 'cpf-gen/cpf_generator_options'
require_relative 'cpf-gen/utils'
require_relative 'cpf-gen/cpf_generator'
require_relative 'cpf-gen/cpf_gen'

# Generates valid CPF (Cadastro de Pessoa Física) identifiers.
#
# Errors fall into two categories:
#
# - *API misuse* — the caller supplied a wrong type or an incompatible argument
#   combination. Raised as {CpfGen::TypeMismatchError} or
#   {CpfGen::InvalidArgumentCombinationError}.
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule. Invalid +prefix+ values raise {CpfGen::ValidationError} under
#   {CpfGen::DomainError}.
#
# Every custom error includes the {CpfGen::Error} marker module so consumers can
# +rescue CpfGen::Error+ for a library-wide catch.
#
# Public API:
#
# - {CpfGen.cpf_gen}
# - {CpfGen::CpfGenerator}, {CpfGen::CpfGeneratorOptions}
# - {CpfGen::CPF_LENGTH}, {CpfGen::CPF_PREFIX_MAX_LENGTH}
# - Error marker {CpfGen::Error}; domain ancestor {CpfGen::DomainError};
#   misuse errors {CpfGen::TypeMismatchError} and
#   {CpfGen::InvalidArgumentCombinationError}; domain leaf
#   {CpfGen::ValidationError}
#
# @example
#   require 'cpf-gen'
#
#   CpfGen.cpf_gen # => e.g. "47844241055"
module CpfGen
  # The standard length of a CPF (Cadastro de Pessoa Física) identifier (11
  # digits).
  CPF_LENGTH = CpfGeneratorOptions::CPF_LENGTH

  # Maximum length of the +prefix+ of a CPF.
  CPF_PREFIX_MAX_LENGTH = CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH
end
