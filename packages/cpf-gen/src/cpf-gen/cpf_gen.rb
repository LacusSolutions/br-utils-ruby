# frozen_string_literal: true

require_relative 'cpf_generator'

module CpfGen
  module_function

  # Helper function to simplify the usage of the {CpfGenerator} class.
  #
  # If no options are provided, it generates an 11-digit unformatted numeric CPF
  # (e.g. +"47844241055"+) using default settings. If options are provided, they
  # control +prefix+ and whether the result is formatted.
  #
  # Generates a valid 11-digit CPF (+prefix+, random numeric body, and computed
  # check digits). With default options the result is unformatted numeric; pass
  # +format: true+ for +000.000.000-00+ style output.
  #
  # @param options [CpfGeneratorOptions, Hash, nil] generator options
  # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
  #   see {CpfGeneratorOptions})
  # @return [String] generated CPF
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
  # @raise [TypeMismatchError] if any option has an invalid type
  # @raise [ValidationError] if +prefix+ is invalid
  # @see CpfGenerator for detailed option descriptions
  #
  # @example
  #   CpfGen.cpf_gen # => "47844241055"
  def cpf_gen(options = nil, **keywords)
    CpfGenerator.new(options, **keywords).generate
  end
end
