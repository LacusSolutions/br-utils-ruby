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
  # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
  #   see {CnpjGeneratorOptions})
  # @return [String] generated CNPJ
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
  # @raise [TypeMismatchError] if any option has an invalid type
  # @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
  # @see CnpjGenerator for detailed option descriptions
  #
  # @example
  #   CnpjGen.cnpj_gen # => "AB123CDE000155"
  def cnpj_gen(options = nil, **keywords)
    CnpjGenerator.new(options, **keywords).generate
  end
end
