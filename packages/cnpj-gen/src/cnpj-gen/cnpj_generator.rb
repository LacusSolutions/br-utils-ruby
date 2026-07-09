# frozen_string_literal: true

require 'cnpj-dv'
require 'lacus-utils'

require_relative 'cnpj_generator_options'

module CnpjGen
  # Formats a raw 14-character CNPJ into the standard masked representation.
  module FormatCnpj
    module_function

    def call(raw)
      "#{raw[0, 2]}.#{raw[2, 3]}.#{raw[5, 3]}/#{raw[8, 4]}-#{raw[12, 2]}"
    end
  end
  private_constant :FormatCnpj

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
    # When +options+ is a {CnpjGeneratorOptions} instance, that instance is used
    # directly (no copy is created). Mutating it later (e.g. via the {#options}
    # reader or the original reference) affects future {#generate} calls that do
    # not pass per-call options. When a plain {Hash} or nothing is passed, a new
    # {CnpjGeneratorOptions} instance is created from it.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] default options
    # @param format [Boolean, nil] default formatting option
    # @param prefix [String, nil] default prefix option
    # @param type [String, nil] default type option
    # @raise [CnpjGeneratorOptionsTypeError] if any option has an invalid type
    # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
    # @raise [CnpjGeneratorOptionTypeInvalidException] if +type+ is not allowed
    def initialize(options = nil, format: nil, prefix: nil, type: nil)
      @options =
        if options.is_a?(CnpjGeneratorOptions)
          options
        else
          CnpjGeneratorOptions.new(options, format: format, prefix: prefix, type: type)
        end
    end

    # Generates a valid CNPJ value.
    #
    # Builds a 14-character CNPJ from the configured +prefix+ (if any), a random
    # sequence of the configured character +type+, and two computed check digits.
    # If formatting is enabled, the result is returned as +00.000.000/0000-00+.
    #
    # Per-call +options+ and keyword overrides are merged over the instance default
    # options for this call only; the instance defaults are unchanged.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] per-call option overrides
    # @param format [Boolean, nil] per-call formatting option
    # @param prefix [String, nil] per-call prefix option
    # @param type [String, nil] per-call type option
    # @return [String] generated CNPJ
    # @raise [CnpjGeneratorOptionsTypeError] if any option has an invalid type
    # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
    # @raise [CnpjGeneratorOptionTypeInvalidException] if +type+ is not allowed
    def generate(options = nil, format: nil, prefix: nil, type: nil)
      actual_options = resolve_generate_options(options, format: format, prefix: prefix, type: type)
      generated_cnpj = build_base_cnpj(actual_options)
      retry_args = { options: options, format: format, prefix: prefix, type: type }

      with_check_digits(generated_cnpj, **retry_args) do |cnpj_with_digits|
        actual_options.format ? FormatCnpj.call(cnpj_with_digits) : cnpj_with_digits
      end
    end

    private

    def resolve_generate_options(options, format:, prefix:, type:)
      return @options unless per_call_overrides?(options, format: format, prefix: prefix, type: type)

      merge_options(options, format: format, prefix: prefix, type: type)
    end

    def per_call_overrides?(options, format:, prefix:, type:)
      !options.nil? || !format.nil? || !prefix.nil? || !type.nil?
    end

    def merge_options(options, format:, prefix:, type:)
      layers = [@options]
      layers << options unless options.nil?

      keyword_overrides = compact_keyword_overrides(format: format, prefix: prefix, type: type)
      layers << keyword_overrides unless keyword_overrides.empty?

      CnpjGeneratorOptions.new(*layers)
    end

    def compact_keyword_overrides(format:, prefix:, type:)
      {}.tap do |overrides|
        overrides[:format] = format unless format.nil?
        overrides[:prefix] = prefix unless prefix.nil?
        overrides[:type] = type unless type.nil?
      end
    end

    def build_base_cnpj(actual_options)
      characters_to_generate = CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH - actual_options.prefix.length

      actual_options.prefix + LacusUtils.generate_random_sequence(
        characters_to_generate,
        actual_options.type.to_sym
      )
    end

    def with_check_digits(generated_cnpj, options:, format:, prefix:, type:)
      cnpj_with_digits = CnpjDV::CnpjCheckDigits.new(generated_cnpj).cnpj

      yield cnpj_with_digits
    rescue CnpjDV::CnpjCheckDigitsException
      generate(options, format: format, prefix: prefix, type: type)
    end
  end
end
