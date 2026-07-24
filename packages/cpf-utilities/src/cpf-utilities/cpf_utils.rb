# frozen_string_literal: true

require 'cpf-fmt'
require 'cpf-gen'
require 'cpf-val'

require_relative 'errors'

# Unified API for CPF (Cadastro da Pessoa Física) formatting, generation, and
# validation. Wraps a configurable formatter, generator, and validator so you
# can format, generate, and validate CPF values from a single instance.
#
# Public API:
#
# - {CpfUtils.format}, {CpfUtils.generate}, {CpfUtils.is_valid} — class helpers
#   that alias {CpfUtils::DEFAULT} (preferred quick path)
# - {CpfUtils::DEFAULT} — mutable shared singleton (JS/Python parity)
# - {CpfUtils#format}, {CpfUtils#generate}, {CpfUtils#is_valid} — instance API
# - {CpfUtils::VERSION}
# - {CpfUtils::InvalidArgumentCombinationError} (API misuse)
#
# Two-tier access: main-class shortcuts ({CpfUtils::CpfFormatter}, etc.) and
# nested package modules ({CpfUtils::CpfFmt}, etc.). Root siblings {CpfFmt},
# {CpfGen}, and {CpfVal} remain loadable after +require 'cpf-utilities'+.
#
# Mutating {CpfUtils::DEFAULT} (e.g. via setters) affects subsequent class-helper
# calls. Custom {CpfUtils.new} instances are independent of +DEFAULT+.
#
# @example
#   require 'cpf-utilities'
#
#   CpfUtils.format('12345678909') # => "123.456.789-09"
#   CpfUtils.generate(format: true) # => e.g. "529.982.247-25"
#   CpfUtils.is_valid('52998224725') # => true
class CpfUtils
  SETTINGS_KEYS = %i[formatter generator validator].freeze

  FORMATTER_OPTION_KEYS = CpfFmt::CpfFormatterOptions::OPTION_KEYS
  GENERATOR_OPTION_KEYS = CpfGen::CpfGeneratorOptions::OPTION_KEYS

  private_constant :SETTINGS_KEYS, :FORMATTER_OPTION_KEYS, :GENERATOR_OPTION_KEYS

  # Internal helpers for constructing owned component instances and merging
  # settings / per-call option arguments.
  module Helpers
    module_function

    def resolve_settings(settings, keywords)
      keyword_settings = compact_settings(keywords)
      raise_ambiguous_settings! if !settings.nil? && !keyword_settings.empty?
      return normalize_settings(settings) unless settings.nil?

      keyword_settings
    end

    def normalize_settings(settings)
      raise TypeMismatchError, "CpfUtils settings must be a Hash. Got #{settings.class}." unless settings.is_a?(Hash)

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
      return CpfFmt::CpfFormatter.new if value.nil?
      return value if value.is_a?(CpfFmt::CpfFormatter)
      return CpfFmt::CpfFormatter.new(value) if value.is_a?(CpfFmt::CpfFormatterOptions) || value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def resolve_generator(value)
      return CpfGen::CpfGenerator.new if value.nil?
      return value if value.is_a?(CpfGen::CpfGenerator)
      return CpfGen::CpfGenerator.new(value) if value.is_a?(CpfGen::CpfGeneratorOptions) || value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def resolve_validator(value)
      return CpfVal::CpfValidator.new if value.nil?
      return value if value.is_a?(CpfVal::CpfValidator)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      # Unlike CNPJ, CPF has no validator Options class — Hash is not accepted as options.
      value
    end

    def ensure_exclusive_options!(options, keywords, option_keys)
      return if options.nil?
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

  # Creates a new {CpfUtils} with customized options. Each of +:formatter+ and
  # +:generator+ can be omitted (defaults are used), or provided as an instance,
  # an options object, or a plain {Hash} of options. +:validator+ accepts an
  # instance, +nil+, or a duck-typed object — not an options Hash.
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
  #   and/or +:validator+ keys (+:formatter+/+:generator+: instance, options
  #   instance, options Hash, or +nil+; +:validator+: instance, +nil+, or
  #   duck-typed object — not an options Hash)
  # @param keywords [Hash] +:formatter+, +:generator+, +:validator+ (mutually
  #   exclusive with +settings+)
  # @raise [InvalidArgumentCombinationError] if +settings+ and a keyword argument
  #   are both given
  # @raise [TypeMismatchError] if +settings+ is given and is not a +Hash+
  # @raise [CpfFmt::TypeMismatchError] if formatter options have an invalid type
  # @raise [CpfFmt::OutOfRangeError] if formatter +hidden_start+ or +hidden_end+
  #   are out of valid range
  # @raise [CpfFmt::ValidationError] if any formatter key option contains a
  #   disallowed character
  # @raise [CpfGen::TypeMismatchError] if generator options have an invalid type
  # @raise [CpfGen::ValidationError] if generator +prefix+ is invalid
  def initialize(settings = nil, **keywords)
    resolved = Helpers.resolve_settings(settings, keywords)

    @formatter = Helpers.resolve_formatter(resolved[:formatter])
    @generator = Helpers.resolve_generator(resolved[:generator])
    @validator = Helpers.resolve_validator(resolved[:validator])
  end

  # Returns the formatter used by this utils instance.
  #
  # @return [CpfFmt::CpfFormatter]
  attr_reader :formatter

  # Returns the generator used by this utils instance.
  #
  # @return [CpfGen::CpfGenerator]
  attr_reader :generator

  # Returns the validator used by this utils instance.
  #
  # @return [CpfVal::CpfValidator]
  attr_reader :validator

  # Sets the active formatter used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CpfFmt::CpfFormatter}
  # 2. An instance of {CpfFmt::CpfFormatterOptions}
  # 3. A partial {Hash} with options for the formatter
  # 4. +nil+ creates a brand new {CpfFmt::CpfFormatter} with default options
  #
  # Note that this resets the formatter instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly (e.g.
  # +utils.formatter.options.hidden = true+).
  #
  # @param value [CpfFmt::CpfFormatter, CpfFmt::CpfFormatterOptions, Hash, nil]
  # @raise [CpfFmt::TypeMismatchError] if options have an invalid type
  # @raise [CpfFmt::OutOfRangeError] if +hidden_start+ or +hidden_end+ are out
  #   of valid range
  # @raise [CpfFmt::ValidationError] if any key option contains a disallowed
  #   character
  def formatter=(value)
    @formatter = Helpers.resolve_formatter(value)
  end

  # Sets the active generator used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CpfGen::CpfGenerator}
  # 2. An instance of {CpfGen::CpfGeneratorOptions}
  # 3. A partial {Hash} with options for the generator
  # 4. +nil+ creates a brand new {CpfGen::CpfGenerator} with default options
  #
  # Note that this resets the generator instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly (e.g.
  # +utils.generator.options.format = true+).
  #
  # @param value [CpfGen::CpfGenerator, CpfGen::CpfGeneratorOptions, Hash, nil]
  # @raise [CpfGen::TypeMismatchError] if options have an invalid type
  # @raise [CpfGen::ValidationError] if +prefix+ is invalid
  def generator=(value)
    @generator = Helpers.resolve_generator(value)
  end

  # Sets the active validator used by this utils instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CpfVal::CpfValidator}
  # 2. +nil+ creates a brand new {CpfVal::CpfValidator}
  # 3. A duck-typed object used by reference (test doubles)
  #
  # Note that this resets the validator instance completely. CPF has no
  # validator options class — a +Hash+ is treated as a duck-typed object, not
  # as options.
  #
  # @param value [CpfVal::CpfValidator, Object, nil]
  def validator=(value)
    @validator = Helpers.resolve_validator(value)
  end

  # Formats a CPF value into a human-readable string.
  #
  # Normalizes and optionally masks, HTML-escapes, or URL-encodes the input.
  # Delegates to the instance formatter; per-call options override the
  # formatter's defaults for this call only.
  #
  # Input is normalized by stripping non-digit characters. If the result length
  # is not exactly 11, the configured +on_fail+ callback is invoked with the
  # original value and an error; its return value is used as the result.
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
  # @param cpf_input [String, Array<String>] CPF value as a string or array of
  #   strings
  # @param options [CpfFmt::CpfFormatterOptions, Hash, nil] per-call overrides
  # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
  #   with +options+; see {CpfFmt::CpfFormatterOptions})
  # @return [String] formatted CPF string, or the +on_fail+ callback result
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [CpfFmt::TypeMismatchError] if the input is not a +String+ or
  #   +Array<String>+, or if any option has an invalid type
  # @raise [CpfFmt::OutOfRangeError] if +hidden_start+ or +hidden_end+ are out
  #   of valid range
  # @raise [CpfFmt::ValidationError] if any key option contains a disallowed
  #   character
  def format(cpf_input, options = nil, **keywords)
    Helpers.ensure_exclusive_options!(options, keywords, FORMATTER_OPTION_KEYS)
    return @formatter.format(cpf_input, options) unless options.nil?

    keyword_overrides = Helpers.compact_keyword_overrides(keywords, FORMATTER_OPTION_KEYS)
    return @formatter.format(cpf_input, **keyword_overrides) unless keyword_overrides.empty?

    @formatter.format(cpf_input)
  end

  # Generates a valid 11-digit CPF, optionally with a prefix and formatting.
  #
  # Builds an 11-digit CPF from the configured +prefix+ (if any), a random
  # sequence of digits, and two computed check digits. If +format+ is enabled,
  # the result is returned as +XXX.XXX.XXX-XX+.
  #
  # Delegates to the instance generator; per-call options override the
  # generator's defaults for this call only.
  #
  # +options+ and the keyword arguments are never merged with each other: when
  # +options+ is given alone it is forwarded as the per-call override; otherwise
  # any non-+nil+ keyword argument is forwarded. Passing +options+ together with
  # any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}.
  #
  # @param options [CpfGen::CpfGeneratorOptions, Hash, nil] per-call overrides
  # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
  #   with +options+; see {CpfGen::CpfGeneratorOptions})
  # @return [String] generated CPF
  # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
  #   are both given
  # @raise [CpfGen::TypeMismatchError] if any option has an invalid type
  # @raise [CpfGen::ValidationError] if +prefix+ is invalid
  def generate(options = nil, **keywords)
    Helpers.ensure_exclusive_options!(options, keywords, GENERATOR_OPTION_KEYS)
    return @generator.generate(options) unless options.nil?

    keyword_overrides = Helpers.compact_keyword_overrides(keywords, GENERATOR_OPTION_KEYS)
    return @generator.generate(**keyword_overrides) unless keyword_overrides.empty?

    @generator.generate
  end

  # Returns whether the given value is a valid CPF.
  #
  # Delegates to the instance validator. CPF has no per-call validator options.
  #
  # @param cpf_input [String, Array<String>] CPF value as a string or array of
  #   strings
  # @return [Boolean] +true+ when valid, +false+ otherwise
  # @raise [CpfVal::TypeMismatchError] if the input is not a +String+ or
  #   +Array<String>+
  # rubocop:disable Naming/PredicatePrefix -- public API matches JS/Python `is_valid`
  def is_valid(cpf_input)
    @validator.is_valid(cpf_input)
  end
  # rubocop:enable Naming/PredicatePrefix

  # Default {CpfUtils} instance with default formatter, generator, and
  # validator options (parity with the JS default export / Python +cpf_utils+
  # singleton). Mutating this instance (e.g. via setters) affects subsequent
  # {CpfUtils.format}, {CpfUtils.generate}, and {CpfUtils.is_valid} calls.
  DEFAULT = new

  class << self
    # Formats a CPF using {DEFAULT} (alias of {CpfUtils#format} on that instance).
    #
    # @param cpf_input [String, Array<String>] CPF value as a string or array of
    #   strings
    # @param options [CpfFmt::CpfFormatterOptions, Hash, nil] per-call overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+)
    # @return [String] formatted CPF string, or the +on_fail+ callback result
    # @see CpfUtils#format
    def format(cpf_input, options = nil, **keywords)
      DEFAULT.format(cpf_input, options, **keywords)
    end

    # Generates a valid CPF using {DEFAULT} (alias of {CpfUtils#generate} on that
    # instance).
    #
    # @param options [CpfGen::CpfGeneratorOptions, Hash, nil] per-call overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+)
    # @return [String] generated CPF
    # @see CpfUtils#generate
    def generate(options = nil, **keywords)
      DEFAULT.generate(options, **keywords)
    end

    # Validates a CPF using {DEFAULT} (alias of {CpfUtils#is_valid} on that
    # instance).
    #
    # @param cpf_input [String, Array<String>] CPF value as a string or array of
    #   strings
    # @return [Boolean] +true+ when valid, +false+ otherwise
    # @see CpfUtils#is_valid
    # rubocop:disable Naming/PredicatePrefix -- public API matches instance `#is_valid`
    def is_valid(cpf_input)
      DEFAULT.is_valid(cpf_input)
    end
    # rubocop:enable Naming/PredicatePrefix
  end
end
