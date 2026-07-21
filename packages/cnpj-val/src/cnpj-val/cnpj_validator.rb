# frozen_string_literal: true

require 'cnpj-dv'

require_relative 'cnpj_validator_options'
require_relative 'errors'

module CnpjVal
  # Validator for CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
  #
  # Validates CNPJ strings according to the Brazilian CNPJ validation algorithm.
  # Invalid CNPJ data returns +false+; only API misuse raises documented errors.
  class CnpjValidator
    NUMERIC_PATTERN = /\D/
    ALPHANUMERIC_PATTERN = /[^0-9A-Za-z]/

    private_constant :NUMERIC_PATTERN, :ALPHANUMERIC_PATTERN

    # Returns the default options used by this validator when per-call options
    # are not provided.
    #
    # Note that the returned object is the same instance used internally;
    # mutating it (e.g. via setters on {CnpjValidatorOptions}) affects future
    # {#is_valid} calls that do not pass +options+.
    #
    # @return [CnpjValidatorOptions] the instance default options
    attr_reader :options

    # Creates a new validator with optional default options.
    #
    # Default options apply to every call to {#is_valid} unless overridden by the
    # per-call +options+ argument or keyword overrides. Options control case
    # sensitivity and whether the CNPJ input is alphanumeric or numeric.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given alone, it determines the default options; a
    # {CnpjValidatorOptions} instance is stored by reference, while a {Hash}
    # builds a new instance. When +options+ is omitted (+nil+), the default
    # options are built exclusively from the keyword arguments, with
    # {CnpjValidatorOptions} filling in its own defaults for every keyword left
    # as +nil+. Passing +options+ together with any non-+nil+ keyword argument
    # raises {InvalidArgumentCombinationError} instead of silently ignoring the
    # keywords.
    #
    # @param options [CnpjValidatorOptions, Hash, nil] default validator options
    # @param keywords [Hash] option keyword overrides (mutually exclusive with
    #   +options+; see {CnpjValidatorOptions::OPTION_KEYS})
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
    #   are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +type+ is not one of the allowed values
    def initialize(options = nil, **keywords)
      @options = resolve_default_options(options, keywords)
    end

    # Validates a CNPJ input.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given alone, it fully overrides the instance defaults for this
    # call; otherwise, any given non-+nil+ keyword argument overrides the
    # instance default options for this call. When neither +options+ nor any
    # keyword argument is given, the instance defaults are used as-is. The
    # instance defaults are never mutated by a per-call override. Passing
    # +options+ together with any non-+nil+ keyword argument raises
    # {InvalidArgumentCombinationError} instead of silently ignoring the keywords.
    #
    # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
    #   strings
    # @param options [CnpjValidatorOptions, Hash, nil] per-call option overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+; see {CnpjValidatorOptions::OPTION_KEYS})
    # @return [Boolean] +true+ when valid, +false+ otherwise
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument
    #   are both given
    # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+,
    #   or if any option has an invalid type
    # @raise [ValidationError] if +type+ is not one of the allowed values
    #
    # @example
    #   CnpjValidator.new(type: 'numeric').is_valid('12651319934215') # => true
    # rubocop:disable Naming/PredicatePrefix -- public API matches JS/Python `is_valid`
    def is_valid(cnpj_input, options = nil, **keywords)
      actual_options = resolve_call_options(options, keywords)
      sanitized_cnpj = sanitize_cnpj_input(cnpj_input, actual_options)

      return false unless valid_sanitized_length?(sanitized_cnpj)
      return false unless numeric_check_digits?(sanitized_cnpj)

      validate_with_check_digits(sanitized_cnpj)
    end
    # rubocop:enable Naming/PredicatePrefix

    private

    def resolve_default_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return options if options.is_a?(CnpjValidatorOptions)
      return CnpjValidatorOptions.new(options) if options

      CnpjValidatorOptions.new(**keywords)
    end

    def resolve_call_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return @options.copy.set(options) if options
      return @options if keyword_overrides.empty?

      @options.copy.set(keyword_overrides)
    end

    def compact_keyword_overrides(keywords)
      CnpjValidatorOptions::OPTION_KEYS.each_with_object({}) do |key, overrides|
        value = keywords[key]
        overrides[key] = value unless value.nil?
      end
    end

    def raise_ambiguous_options!
      option_keywords = CnpjValidatorOptions::OPTION_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            "Pass either an options instance/Hash to `options`, or keyword arguments (#{option_keywords}), " \
            'not both.'
    end

    def sanitize_cnpj_input(cnpj_input, actual_options)
      actual_input = to_string_input(cnpj_input)
      working_input = actual_options.case_sensitive ? actual_input : actual_input.upcase

      sanitize(working_input, actual_options.type)
    end

    def to_string_input(cnpj_input)
      return cnpj_input if cnpj_input.is_a?(String)

      if cnpj_input.is_a?(Array)
        cnpj_input.each do |item|
          raise TypeMismatchError.new(cnpj_input, 'string or string[]') unless item.is_a?(String)
        end

        return cnpj_input.join
      end

      raise TypeMismatchError.new(cnpj_input, 'string or string[]')
    end

    def sanitize(value, cnpj_type)
      if cnpj_type == 'numeric'
        value.gsub(NUMERIC_PATTERN, '')
      else
        value.gsub(ALPHANUMERIC_PATTERN, '')
      end
    end

    def numeric_check_digits?(sanitized_cnpj)
      twelfth = sanitized_cnpj[12]
      thirteenth = sanitized_cnpj[13]

      twelfth.between?('0', '9') && thirteenth.between?('0', '9')
    end

    def valid_sanitized_length?(sanitized_cnpj)
      sanitized_cnpj.length == CnpjValidatorOptions::CNPJ_LENGTH
    end

    def validate_with_check_digits(sanitized_cnpj)
      cnpj_check_digits = CnpjDV::CnpjCheckDigits.new(sanitized_cnpj)

      sanitized_cnpj == cnpj_check_digits.cnpj
    rescue CnpjDV::Error
      false
    end
  end
end
