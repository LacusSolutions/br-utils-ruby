# frozen_string_literal: true

module CnpjFmt
  # Helper function to simplify the usage of the {CnpjFormatter} class.
  #
  # Formats a CNPJ string according to the given options. With no options,
  # returns the traditional CNPJ format (e.g. +12.345.678/0009-10+). Invalid
  # input length is handled by the configured +on_fail+ callback instead of
  # throwing.
  #
  # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
  #   strings
  # @param options [CnpjFormatterOptions, Hash, nil] default formatter options
  # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
  #   see {CnpjFormatterOptions})
  # @return [String] formatted CNPJ string, or the +on_fail+ callback result
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
  # @raise [TypeMismatchError] if +cnpj_input+ is not a +String+ or +Array<String>+
  # @raise [TypeMismatchError] if any option has an invalid type
  # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
  # @raise [ValidationError] if any key option contains a disallowed character
  # @see CnpjFormatter#format for detailed option descriptions
  # @see CnpjFormatter
  #
  # @example
  #   CnpjFmt.cnpj_fmt('12345678000910') # => "12.345.678/0009-10"
  def self.cnpj_fmt(cnpj_input, options = nil, **keywords)
    CnpjFormatter.new(options, **keywords).format(cnpj_input)
  end
end
