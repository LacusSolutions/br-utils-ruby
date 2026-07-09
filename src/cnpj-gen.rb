# frozen_string_literal: true

require_relative 'cnpj-gen/version'
require_relative 'cnpj-gen/exceptions'
require_relative 'cnpj-gen/types'
require_relative 'cnpj-gen/generator_options_validation'
require_relative 'cnpj-gen/cnpj_generator_option_properties'
require_relative 'cnpj-gen/cnpj_generator_options'
require_relative 'cnpj-gen/cnpj_generator'
require_relative 'cnpj-gen/cnpj_gen'

# Generates valid CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
#
# The package distinguishes between **errors** and **exceptions**:
#
# - {CnpjGen::CnpjGeneratorTypeError} (extends the native {TypeError}) signals
#   incorrect API usage (the option is of the wrong *type*).
# - {CnpjGen::CnpjGeneratorException} (extends the native {StandardError})
#   signals invalid or ineligible data (right type, bad value).
#
# Public API:
#
# - {CnpjGen.cnpj_gen}
# - {CnpjGen::CnpjGenerator}, {CnpjGen::CnpjGeneratorOptions}
# - {CnpjGen::CNPJ_LENGTH}, {CnpjGen::CNPJ_PREFIX_MAX_LENGTH}
# - Exception hierarchy under {CnpjGen}
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
