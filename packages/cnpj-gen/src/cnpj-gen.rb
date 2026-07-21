# frozen_string_literal: true

require_relative 'cnpj-gen/version'
require_relative 'cnpj-gen/errors'
require_relative 'cnpj-gen/types'
require_relative 'cnpj-gen/cnpj_generator_options'
require_relative 'cnpj-gen/utils'
require_relative 'cnpj-gen/cnpj_generator'
require_relative 'cnpj-gen/cnpj_gen'

# Generates valid CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
#
# Errors fall into two categories:
#
# - *API misuse* — the caller supplied a wrong type or an incompatible argument
#   combination. Raised as {CnpjGen::TypeMismatchError} or
#   {CnpjGen::InvalidArgumentCombinationError}.
# - *Domain errors* — the call shape was valid, but a value violates a business
#   rule. Invalid +prefix+ or +type+ values raise {CnpjGen::ValidationError}
#   under {CnpjGen::DomainError}.
#
# Every custom error includes the {CnpjGen::Error} marker module so consumers can
# +rescue CnpjGen::Error+ for a library-wide catch.
#
# Public API:
#
# - {CnpjGen.cnpj_gen}
# - {CnpjGen::CnpjGenerator}, {CnpjGen::CnpjGeneratorOptions}
# - {CnpjGen::CNPJ_LENGTH}, {CnpjGen::CNPJ_PREFIX_MAX_LENGTH}
# - Error marker {CnpjGen::Error}; domain ancestor {CnpjGen::DomainError};
#   misuse errors {CnpjGen::TypeMismatchError} and
#   {CnpjGen::InvalidArgumentCombinationError}; domain leaf
#   {CnpjGen::ValidationError}
#
# @example
#   require 'cnpj-gen'
#
#   CnpjGen.cnpj_gen # => e.g. "AB123CDE000155"
module CnpjGen
  # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
  # identifier (14 alphanumeric characters).
  CNPJ_LENGTH = CnpjGeneratorOptions::CNPJ_LENGTH

  # Maximum length of the +prefix+ (base ID and branch ID) of a CNPJ.
  CNPJ_PREFIX_MAX_LENGTH = CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH
end
