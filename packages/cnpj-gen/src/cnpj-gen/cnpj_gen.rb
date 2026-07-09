# frozen_string_literal: true

require_relative 'cnpj_generator'

module CnpjGen
  module_function

  # Helper function to simplify the usage of the {CnpjGenerator} class.
  #
  # If no options are provided, it generates a 14-character unformatted
  # alphanumeric CNPJ (e.g. +"AB123CDE000155"+) using default settings. If
  # options are provided, they control +prefix+, +type+, and whether the result is
  # formatted.
  #
  # Generates a valid 14-character CNPJ (+prefix+, random body for the chosen
  # character +type+, and computed check digits). With default options the result
  # is unformatted alphanumeric; pass +format: true+ for +00.000.000/0000-00+
  # style output.
  #
  # @param options [CnpjGeneratorOptions, Hash, nil] generator options
  # @param format [Boolean, nil] whether to format the generated CNPJ
  # @param prefix [String, nil] partial start string for the generated CNPJ
  # @param type [String, nil] character set for random segments
  # @return [String] generated CNPJ
  # @raise [CnpjGeneratorOptionsTypeError] if any option has an invalid type
  # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
  # @raise [CnpjGeneratorOptionTypeInvalidException] if +type+ is not allowed
  # @see CnpjGenerator for detailed option descriptions
  #
  # @example
  #   CnpjGen.cnpj_gen # => "AB123CDE000155"
  def cnpj_gen(options = nil, format: nil, prefix: nil, type: nil)
    CnpjGenerator.new(options, format: format, prefix: prefix, type: type).generate
  end
end
