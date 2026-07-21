# frozen_string_literal: true

module CpfFmt
  # Helper function to simplify the usage of the {CpfFormatter} class.
  #
  # Formats a CPF string according to the given options. With no options,
  # returns the traditional CPF format (e.g. +123.456.789-10+). Invalid input
  # length is handled by the configured +on_fail+ callback instead of throwing.
  #
  # @param cpf_input [String, Array<String>] CPF value as a string or array of
  #   strings
  # @param options [CpfFormatterOptions, Hash, nil] default formatter options
  # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
  #   see {CpfFormatterOptions})
  # @return [String] formatted CPF string, or the +on_fail+ callback result
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
  # @raise [TypeMismatchError] if +cpf_input+ is not a +String+ or +Array<String>+
  # @raise [TypeMismatchError] if any option has an invalid type
  # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
  # @raise [ValidationError] if any key option contains a disallowed character
  # @see CpfFormatter#format for detailed option descriptions
  # @see CpfFormatter
  #
  # @example
  #   CpfFmt.cpf_fmt('12345678910') # => "123.456.789-10"
  def self.cpf_fmt(cpf_input, options = nil, **keywords)
    CpfFormatter.new(options, **keywords).format(cpf_input)
  end
end
