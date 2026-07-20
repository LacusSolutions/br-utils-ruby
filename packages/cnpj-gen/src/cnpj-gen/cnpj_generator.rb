# frozen_string_literal: true

require 'cnpj-dv'
require 'lacus-utils'

require_relative 'cnpj_generator_options'

module CnpjGen
  # Generator for CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers. Builds
  # valid 14-character CNPJ values by combining an optional +prefix+ with a
  # randomly generated sequence and computed check digits. Options control
  # +prefix+, character +type+ (+numeric+, +alphabetic+, or +alphanumeric+), and
  # whether the result is formatted (+00.000.000/0000-00+).
  class CnpjGenerator
    # Returns the default options used by this generator when per-call options
    # are not provided.
    #
    # The returned object is the same instance used internally; mutating it (e.g.
    # via setters on {CnpjGeneratorOptions}) affects future {#generate} calls that
    # do not pass +options+.
    #
    # @return [CnpjGeneratorOptions] the instance default options
    attr_reader :options

    # Creates a new {CnpjGenerator} with optional default options.
    #
    # Default options apply to every call to {#generate} unless overridden by the
    # per-call +options+ argument or keyword overrides. Options control +prefix+,
    # character +type+, and whether the generated CNPJ is formatted.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CnpjGeneratorOptions} instance or a {Hash}), it alone
    # determines the default options; otherwise, the default options are built
    # exclusively from the keyword arguments, with {CnpjGeneratorOptions} filling
    # in its own defaults for every keyword left as +nil+. Passing +options+
    # together with any non-+nil+ keyword argument raises
    # {InvalidArgumentCombinationError} instead of silently ignoring the keywords.
    #
    # When +options+ is a {CnpjGeneratorOptions} instance, that instance is used
    # directly (no copy is created). Mutating it later (e.g. via the {#options}
    # reader or the original reference) affects future {#generate} calls that do
    # not pass per-call options. When a plain {Hash} is passed instead, a new
    # {CnpjGeneratorOptions} instance is created from it.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] default options
    # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
    #   see {CnpjGeneratorOptions})
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
    def initialize(options = nil, **keywords)
      @options = resolve_default_options(options, keywords)
    end

    # Generates a valid CNPJ value.
    #
    # Builds a 14-character CNPJ from the configured +prefix+ (if any), a random
    # sequence of the configured character +type+, and two computed check digits.
    # If formatting is enabled, the result is returned as +00.000.000/0000-00+.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CnpjGeneratorOptions} instance or a {Hash}), it alone
    # overrides the instance default options for this call; otherwise, any
    # non-+nil+ keyword argument overrides the instance default options for this
    # call. When neither +options+ nor any keyword argument is given, the
    # instance default options are used as-is. In every case, the instance
    # default options themselves are left unchanged. Passing +options+ together
    # with any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}
    # instead of silently ignoring the keywords.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] per-call option overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+; see {CnpjGeneratorOptions})
    # @return [String] generated CNPJ
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
    def generate(options = nil, **keywords)
      actual_options = resolve_call_options(options, keywords)
      generated_cnpj = build_base_cnpj(actual_options)

      with_check_digits(generated_cnpj, options, keywords) do |cnpj_with_digits|
        actual_options.format ? Utils.format_cnpj(cnpj_with_digits) : cnpj_with_digits
      end
    end

    private

    def resolve_default_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return options if options.is_a?(CnpjGeneratorOptions)
      return CnpjGeneratorOptions.new(options) if options

      CnpjGeneratorOptions.new(**keywords)
    end

    def resolve_call_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return @options.copy.set(options) if options
      return @options if keyword_overrides.empty?

      @options.copy.set(keyword_overrides)
    end

    def compact_keyword_overrides(keywords)
      CnpjGeneratorOptions::OPTION_KEYS.each_with_object({}) do |key, overrides|
        value = keywords[key]
        overrides[key] = value unless value.nil?
      end
    end

    def raise_ambiguous_options!
      option_keywords = CnpjGeneratorOptions::OPTION_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            "Pass either an options instance/Hash to `options`, or keyword arguments (#{option_keywords}), " \
            'not both.'
    end

    def build_base_cnpj(actual_options)
      characters_to_generate = CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH - actual_options.prefix.length

      actual_options.prefix + LacusUtils.generate_random_sequence(
        characters_to_generate,
        actual_options.type.to_sym
      )
    end

    def with_check_digits(generated_cnpj, options, keywords)
      cnpj_with_digits = CnpjDV::CnpjCheckDigits.new(generated_cnpj).cnpj

      yield cnpj_with_digits
    rescue CnpjDV::CnpjCheckDigitsException
      generate(options, **keywords)
    end
  end
end
