# frozen_string_literal: true

require 'cpf-dv'
require 'lacus-utils'

require_relative 'cpf_generator_options'

module CpfGen
  # Generator for CPF (Cadastro de Pessoa Física) identifiers. Builds valid
  # 11-digit CPF values by combining an optional +prefix+ with a randomly
  # generated sequence and computed check digits. Options control +prefix+ and
  # whether the result is formatted (+000.000.000-00+).
  class CpfGenerator
    # Returns the default options used by this generator when per-call options
    # are not provided.
    #
    # The returned object is the same instance used internally; mutating it (e.g.
    # via setters on {CpfGeneratorOptions}) affects future {#generate} calls that
    # do not pass +options+.
    #
    # @return [CpfGeneratorOptions] the instance default options
    attr_reader :options

    # Creates a new {CpfGenerator} with optional default options.
    #
    # Default options apply to every call to {#generate} unless overridden by the
    # per-call +options+ argument or keyword overrides. Options control +prefix+
    # and whether the generated CPF is formatted.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CpfGeneratorOptions} instance or a {Hash}), it alone
    # determines the default options; otherwise, the default options are built
    # exclusively from the keyword arguments, with {CpfGeneratorOptions} filling
    # in its own defaults for every keyword left as +nil+. Passing +options+
    # together with any non-+nil+ keyword argument raises
    # {InvalidArgumentCombinationError} instead of silently ignoring the keywords.
    #
    # When +options+ is a {CpfGeneratorOptions} instance, that instance is used
    # directly (no copy is created). Mutating it later (e.g. via the {#options}
    # reader or the original reference) affects future {#generate} calls that do
    # not pass per-call options. When a plain {Hash} is passed instead, a new
    # {CpfGeneratorOptions} instance is created from it.
    #
    # @param options [CpfGeneratorOptions, Hash, nil] default options
    # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
    #   see {CpfGeneratorOptions})
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid
    def initialize(options = nil, **keywords)
      @options = resolve_default_options(options, keywords)
    end

    # Generates a valid CPF value.
    #
    # Builds an 11-digit CPF from the configured +prefix+ (if any), a random
    # numeric sequence, and two computed check digits. If formatting is enabled,
    # the result is returned as +000.000.000-00+.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CpfGeneratorOptions} instance or a {Hash}), it alone
    # overrides the instance default options for this call; otherwise, any
    # non-+nil+ keyword argument overrides the instance default options for this
    # call. When neither +options+ nor any keyword argument is given, the
    # instance default options are used as-is. In every case, the instance
    # default options themselves are left unchanged. Passing +options+ together
    # with any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}
    # instead of silently ignoring the keywords.
    #
    # @param options [CpfGeneratorOptions, Hash, nil] per-call option overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+; see {CpfGeneratorOptions})
    # @return [String] generated CPF
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid
    def generate(options = nil, **keywords)
      actual_options = resolve_call_options(options, keywords)
      generated_cpf = build_base_cpf(actual_options)

      with_check_digits(generated_cpf, options, keywords) do |cpf_with_digits|
        actual_options.format ? Utils.format_cpf(cpf_with_digits) : cpf_with_digits
      end
    end

    private

    def resolve_default_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return options if options.is_a?(CpfGeneratorOptions)
      return CpfGeneratorOptions.new(options) if options

      CpfGeneratorOptions.new(**keywords)
    end

    def resolve_call_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return @options.copy.set(options) if options
      return @options if keyword_overrides.empty?

      @options.copy.set(keyword_overrides)
    end

    def compact_keyword_overrides(keywords)
      CpfGeneratorOptions::OPTION_KEYS.each_with_object({}) do |key, overrides|
        value = keywords[key]
        overrides[key] = value unless value.nil?
      end
    end

    def raise_ambiguous_options!
      option_keywords = CpfGeneratorOptions::OPTION_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            "Pass either an options instance/Hash to `options`, or keyword arguments (#{option_keywords}), " \
            'not both.'
    end

    def build_base_cpf(actual_options)
      digits_to_generate = CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH - actual_options.prefix.length

      actual_options.prefix + LacusUtils.generate_random_sequence(
        digits_to_generate,
        :numeric
      )
    end

    def with_check_digits(generated_cpf, options, keywords)
      cpf_with_digits = CpfDV::CpfCheckDigits.new(generated_cpf).cpf

      yield cpf_with_digits
    rescue CpfDV::DomainError
      generate(options, **keywords)
    end
  end
end
