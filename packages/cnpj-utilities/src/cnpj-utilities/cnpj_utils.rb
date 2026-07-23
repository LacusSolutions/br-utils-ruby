# frozen_string_literal: true

require 'cnpj-fmt'
require 'cnpj-gen'
require 'cnpj-val'

require_relative 'errors'

# Unified API for CNPJ (Cadastro Nacional da Pessoa Jurídica) formatting,
# generation, and validation. Wraps a configurable formatter, generator, and
# validator so you can format, generate, and validate CNPJ values from a single
# instance.
#
# Public API:
#
# - {CnpjUtils.format}, {CnpjUtils.generate}, {CnpjUtils.is_valid} — class helpers
#   that alias {CnpjUtils::DEFAULT} (preferred quick path)
# - {CnpjUtils::DEFAULT} — mutable shared singleton (JS/Python parity)
# - {CnpjUtils#format}, {CnpjUtils#generate}, {CnpjUtils#is_valid} — instance API
# - {CnpjUtils::VERSION}
# - {CnpjUtils::InvalidArgumentCombinationError} (API misuse)
#
# Two-tier access: main-class shortcuts ({CnpjUtils::CnpjFormatter}, etc.) and
# nested package modules ({CnpjUtils::CnpjFmt}, etc.). Root siblings {CnpjFmt},
# {CnpjGen}, and {CnpjVal} remain loadable after +require 'cnpj-utilities'+.
#
# Mutating {CnpjUtils::DEFAULT} (e.g. via setters) affects subsequent class-helper
# calls. Custom {CnpjUtils.new} instances are independent of +DEFAULT+.
#
# @example
#   require 'cnpj-utilities'
#
#   CnpjUtils.format('03603568000195') # => "03.603.568/0001-95"
#   CnpjUtils.generate(type: 'numeric') # => e.g. "65453043000178"
#   CnpjUtils.is_valid('91415732000793') # => true
class CnpjUtils
  SETTINGS_KEYS = %i[formatter generator validator].freeze

  FORMATTER_OPTION_KEYS = CnpjFmt::CnpjFormatterOptions::OPTION_KEYS
  GENERATOR_OPTION_KEYS = CnpjGen::CnpjGeneratorOptions::OPTION_KEYS
  VALIDATOR_OPTION_KEYS = CnpjVal::CnpjValidatorOptions::OPTION_KEYS

  private_constant :SETTINGS_KEYS, :FORMATTER_OPTION_KEYS, :GENERATOR_OPTION_KEYS, :VALIDATOR_OPTION_KEYS

  # Internal helpers for constructing owned component instances and merging
  # settings / per-call option arguments.
  module Helpers
    module_function

    def resolve_settings(settings, keywords)
      keyword_settings = compact_settings(keywords)
      raise_ambiguous_settings! if settings && !keyword_settings.empty?
      return normalize_settings(settings) if settings

      keyword_settings
    end

    def normalize_settings(settings)
      raise TypeMismatchError, "CnpjUtils settings must be a Hash. Got #{settings.class}." unless settings.is_a?(Hash)

      SETTINGS_KEYS.each_with_object({}) do |key, resolved|
        if settings.key?(key)
          resolved[key] = settings[key]
        elsif settings.key?(key.to_s)
          resolved[key] = settings[key.to_s]
        end
      end
    end

    def compact_settings(keywords)
      SETTINGS_KEYS.each_with_object({}) do |key, resolved|
        value = keywords[key]
        resolved[key] = value unless value.nil?
      end
    end

    def resolve_formatter(value)
      return CnpjFmt::CnpjFormatter.new if value.nil?
      return value if value.is_a?(CnpjFmt::CnpjFormatter)
      return CnpjFmt::CnpjFormatter.new(value) if value.is_a?(CnpjFmt::CnpjFormatterOptions) || value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def resolve_generator(value)
      return CnpjGen::CnpjGenerator.new if value.nil?
      return value if value.is_a?(CnpjGen::CnpjGenerator)
      return CnpjGen::CnpjGenerator.new(value) if value.is_a?(CnpjGen::CnpjGeneratorOptions) || value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def resolve_validator(value)
      return CnpjVal::CnpjValidator.new if value.nil?
      return value if value.is_a?(CnpjVal::CnpjValidator)
      return CnpjVal::CnpjValidator.new(value) if value.is_a?(CnpjVal::CnpjValidatorOptions) || value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def ensure_exclusive_options!(options, keywords, option_keys)
      return unless options
      return if keywords.none? { |_key, value| !value.nil? }

      raise_ambiguous_options!(option_keys)
    end

    def compact_keyword_overrides(keywords, option_keys)
      option_keys.each_with_object({}) do |key, overrides|
        value = keywords[key]
        overrides[key] = value unless value.nil?
      end
    end

    def raise_ambiguous_settings!
      option_keywords = SETTINGS_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            'Pass either a settings Hash to `settings`, or keyword arguments ' \
            "(#{option_keywords}), not both."
    end

    def raise_ambiguous_options!(option_keys)
      option_keywords = option_keys.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            "Pass either an options instance/Hash to `options`, or keyword arguments (#{option_keywords}), " \
            'not both.'
    end
  end
  private_constant :Helpers

  # Creates a new {CnpjUtils} with customized options. Each of +:formatter+,
  # +:generator+, and +:validator+ can be omitted (defaults are used), or
  # provided as an instance, an options object, or a plain {Hash} of options.
  #
  # When a component instance is passed, it is used directly (same reference).
  # When +nil+ is passed for a component, a new instance with default options is
  # created.
  #
  # +settings+ and the keyword arguments are never merged with each other: when
  # +settings+ is given (a {Hash} with +:formatter+, +:generator+, and/or
  # +:validator+ keys), it alone determines the components; otherwise, the
  # components are built exclusively from the keyword arguments. Passing
  # +settings+ together with any non-+nil+ keyword argument raises
  # {InvalidArgumentCombinationError} instead of silently ignoring the keywords.
  #
  # @param settings [Hash, nil] settings Hash with +:formatter+, +:generator+,
  #   and/or +:validator+ keys (each a component instance, options instance,
  #   options Hash, or +nil+)
  # @param keywords [Hash] +:formatter+, +:generator+, +:validator+ (mutually
  #   exclusive with +settings+)
  # @raise [InvalidArgumentCombinationError] if +settings+ and a keyword argument
  #   are both given
  # @raise [TypeMismatchError] if +settings+ is given and is not a +Hash+
  # @raise [CnpjFmt::TypeMismatchError] if formatter options have an invalid type
  # @raise [CnpjFmt::OutOfRangeError] if formatter +hidden_start+ or +hidden_end+
  #   are out of valid range
  # @raise [CnpjFmt::ValidationError] if any formatter key option contains a
  #   disallowed character
  # @raise [CnpjGen::TypeMismatchError] if generator options have an invalid type
  # @raise [CnpjGen::ValidationError] if generator +prefix+ is invalid or +type+
  #   is not allowed
  # @raise [CnpjVal::TypeMismatchError] if validator options have an invalid type
  # @raise [CnpjVal::ValidationError] if validator +type+ is not allowed
  def initialize(settings = nil, **keywords)
    resolved = Helpers.resolve_settings(settings, keywords)

    @formatter = Helpers.resolve_formatter(resolved[:formatter])
    @generator = Helpers.resolve_generator(resolved[:generator])
    @validator = Helpers.resolve_validator(resolved[:validator])
  end

  # Returns the formatter used by this utils instance.
  #
  # @return [CnpjFmt::CnpjFormatter]
  attr_reader :formatter

  # Returns the generator used by this utils instance.
  #
  # @return [CnpjGen::CnpjGenerator]
  attr_reader :generator

  # Returns the validator used by this utils instance.
  #
  # @return [CnpjVal::CnpjValidator]
  attr_reader :validator

  # Sets the active formatter used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CnpjFmt::CnpjFormatter}
  # 2. An instance of {CnpjFmt::CnpjFormatterOptions}
  # 3. A partial {Hash} with options for the formatter
  # 4. +nil+ creates a brand new {CnpjFmt::CnpjFormatter} with default options
  #
  # Note that this resets the formatter instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly (e.g.
  # +utils.formatter.options.hidden = true+).
  #
  # @param value [CnpjFmt::CnpjFormatter, CnpjFmt::CnpjFormatterOptions, Hash, nil]
  # @raise [CnpjFmt::TypeMismatchError] if options have an invalid type
  # @raise [CnpjFmt::OutOfRangeError] if +hidden_start+ or +hidden_end+ are out
  #   of valid range
  # @raise [CnpjFmt::ValidationError] if any key option contains a disallowed
  #   character
  def formatter=(value)
    @formatter = Helpers.resolve_formatter(value)
  end

  # Sets the active generator used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CnpjGen::CnpjGenerator}
  # 2. An instance of {CnpjGen::CnpjGeneratorOptions}
  # 3. A partial {Hash} with options for the generator
  # 4. +nil+ creates a brand new {CnpjGen::CnpjGenerator} with default options
  #
  # Note that this resets the generator instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly (e.g.
  # +utils.generator.options.type = 'numeric'+).
  #
  # @param value [CnpjGen::CnpjGenerator, CnpjGen::CnpjGeneratorOptions, Hash, nil]
  # @raise [CnpjGen::TypeMismatchError] if options have an invalid type
  # @raise [CnpjGen::ValidationError] if +prefix+ is invalid or +type+ is not
  #   allowed
  def generator=(value)
    @generator = Helpers.resolve_generator(value)
  end

  # Sets the active validator used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CnpjVal::CnpjValidator}
  # 2. An instance of {CnpjVal::CnpjValidatorOptions}
  # 3. A partial {Hash} with options for the validator
  # 4. +nil+ creates a brand new {CnpjVal::CnpjValidator} with default options
  #
  # Note that this resets the validator instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly (e.g.
  # +utils.validator.options.type = 'numeric'+).
  #
  # @param value [CnpjVal::CnpjValidator, CnpjVal::CnpjValidatorOptions, Hash, nil]
  # @raise [CnpjVal::TypeMismatchError] if options have an invalid type
  # @raise [CnpjVal::ValidationError] if +type+ is not allowed
  def validator=(value)
    @validator = Helpers.resolve_validator(value)
  end

  # Formats a CNPJ value into a human-readable string.
  #
  # Normalizes and optionally masks, HTML-escapes, or URL-encodes the input.
  # Delegates to the instance formatter; per-call options override the
  # formatter's defaults for this call only.
  #
  # Input is normalized by stripping non-alphanumeric characters and converting
  # to uppercase. If the result length is not exactly 14, the configured
  # +on_fail+ callback is invoked with the original value and an error; its
  # return value is used as the result.
  #
  # When valid, the result may be further transformed according to options:
  #
  # - If +hidden+ is +true+, characters between +hidden_start+ and +hidden_end+
  #   (inclusive) are replaced with +hidden_key+.
  # - If +escape+ is +true+, HTML special characters are escaped.
  # - If +encode+ is +true+, the string is URL-encoded.
  #
  # +options+ and the keyword arguments are never merged with each other: when
  # +options+ is given alone it is forwarded as the per-call override; otherwise
  # any non-+nil+ keyword argument is forwarded. Passing +options+ together with
  # any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}.
  #
  # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
  #   strings
  # @param options [CnpjFmt::CnpjFormatterOptions, Hash, nil] per-call overrides
  # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
  #   with +options+; see {CnpjFmt::CnpjFormatterOptions})
  # @return [String] formatted CNPJ string, or the +on_fail+ callback result
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [CnpjFmt::TypeMismatchError] if the input is not a +String+ or
  #   +Array<String>+, or if any option has an invalid type
  # @raise [CnpjFmt::OutOfRangeError] if +hidden_start+ or +hidden_end+ are out
  #   of valid range
  # @raise [CnpjFmt::ValidationError] if any key option contains a disallowed
  #   character
  def format(cnpj_input, options = nil, **keywords)
    Helpers.ensure_exclusive_options!(options, keywords, FORMATTER_OPTION_KEYS)
    return @formatter.format(cnpj_input, options) if options

    keyword_overrides = Helpers.compact_keyword_overrides(keywords, FORMATTER_OPTION_KEYS)
    return @formatter.format(cnpj_input, **keyword_overrides) unless keyword_overrides.empty?

    @formatter.format(cnpj_input)
  end

  # Generates a valid 14-character CNPJ, optionally with a prefix and
  # formatting.
  #
  # Builds a 14-character CNPJ from the configured +prefix+ (if any), a random
  # sequence of the configured character +type+, and two computed check digits.
  # If +format+ is enabled, the result is returned as +00.000.000/0000-00+.
  #
  # Delegates to the instance generator; per-call options override the
  # generator's defaults for this call only.
  #
  # +options+ and the keyword arguments are never merged with each other: when
  # +options+ is given alone it is forwarded as the per-call override; otherwise
  # any non-+nil+ keyword argument is forwarded. Passing +options+ together with
  # any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}.
  #
  # @param options [CnpjGen::CnpjGeneratorOptions, Hash, nil] per-call overrides
  # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
  #   with +options+; see {CnpjGen::CnpjGeneratorOptions})
  # @return [String] generated CNPJ
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [CnpjGen::TypeMismatchError] if any option has an invalid type
  # @raise [CnpjGen::ValidationError] if +prefix+ is invalid or +type+ is not
  #   allowed
  def generate(options = nil, **keywords)
    Helpers.ensure_exclusive_options!(options, keywords, GENERATOR_OPTION_KEYS)
    return @generator.generate(options) if options

    keyword_overrides = Helpers.compact_keyword_overrides(keywords, GENERATOR_OPTION_KEYS)
    return @generator.generate(**keyword_overrides) unless keyword_overrides.empty?

    @generator.generate
  end

  # Returns whether the given value is a valid CNPJ.
  #
  # Delegates to the instance validator; per-call options override the
  # validator's defaults for this call only.
  #
  # +options+ and the keyword arguments are never merged with each other: when
  # +options+ is given alone it is forwarded as the per-call override; otherwise
  # any non-+nil+ keyword argument is forwarded. Passing +options+ together with
  # any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}.
  #
  # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
  #   strings
  # @param options [CnpjVal::CnpjValidatorOptions, Hash, nil] per-call overrides
  # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
  #   with +options+; see {CnpjVal::CnpjValidatorOptions})
  # @return [Boolean] +true+ when valid, +false+ otherwise
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [CnpjVal::TypeMismatchError] if the input is not a +String+ or
  #   +Array<String>+, or if any option has an invalid type
  # @raise [CnpjVal::ValidationError] if the +type+ option is not allowed
  # rubocop:disable Naming/PredicatePrefix -- public API matches JS/Python `is_valid`
  def is_valid(cnpj_input, options = nil, **keywords)
    Helpers.ensure_exclusive_options!(options, keywords, VALIDATOR_OPTION_KEYS)
    return @validator.is_valid(cnpj_input, options) if options

    keyword_overrides = Helpers.compact_keyword_overrides(keywords, VALIDATOR_OPTION_KEYS)
    return @validator.is_valid(cnpj_input, **keyword_overrides) unless keyword_overrides.empty?

    @validator.is_valid(cnpj_input)
  end
  # rubocop:enable Naming/PredicatePrefix

  # Default {CnpjUtils} instance with default formatter, generator, and
  # validator options (parity with the JS default export / Python +cnpj_utils+
  # singleton). Mutating this instance (e.g. via setters) affects subsequent
  # {CnpjUtils.format}, {CnpjUtils.generate}, and {CnpjUtils.is_valid} calls.
  DEFAULT = new

  class << self
    # Formats a CNPJ using {DEFAULT} (alias of {CnpjUtils#format} on that instance).
    #
    # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
    #   strings
    # @param options [CnpjFmt::CnpjFormatterOptions, Hash, nil] per-call overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+)
    # @return [String] formatted CNPJ string, or the +on_fail+ callback result
    # @see CnpjUtils#format
    def format(cnpj_input, options = nil, **keywords)
      DEFAULT.format(cnpj_input, options, **keywords)
    end

    # Generates a valid CNPJ using {DEFAULT} (alias of {CnpjUtils#generate} on that
    # instance).
    #
    # @param options [CnpjGen::CnpjGeneratorOptions, Hash, nil] per-call overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+)
    # @return [String] generated CNPJ
    # @see CnpjUtils#generate
    def generate(options = nil, **keywords)
      DEFAULT.generate(options, **keywords)
    end

    # Validates a CNPJ using {DEFAULT} (alias of {CnpjUtils#is_valid} on that
    # instance).
    #
    # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
    #   strings
    # @param options [CnpjVal::CnpjValidatorOptions, Hash, nil] per-call overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+)
    # @return [Boolean] +true+ when valid, +false+ otherwise
    # @see CnpjUtils#is_valid
    # rubocop:disable Naming/PredicatePrefix -- public API matches instance `#is_valid`
    def is_valid(cnpj_input, options = nil, **keywords)
      DEFAULT.is_valid(cnpj_input, options, **keywords)
    end
    # rubocop:enable Naming/PredicatePrefix
  end
end
