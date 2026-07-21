# frozen_string_literal: true

require 'cgi'
require 'erb'

module CpfFmt
  # Formatter for CPF (Cadastro de Pessoas Físicas) identifiers.
  #
  # Normalizes and optionally masks, HTML-escapes, or URL-encodes 11-digit CPF
  # input. Accepts a string or array of strings; non-digit characters are
  # stripped. Invalid input type is handled by throwing; invalid length is
  # handled via the configured +on_fail+ callback instead of throwing.
  class CpfFormatter
    # Returns the default options used by this formatter when per-call options
    # are not provided.
    #
    # The returned object is the same instance used internally; mutating it (e.g.
    # via setters on {CpfFormatterOptions}) affects future {#format} calls that
    # do not pass +options+.
    #
    # @return [CpfFormatterOptions] the instance default options
    attr_reader :options

    # Creates a new formatter with optional default options.
    #
    # Default options apply to every call to {#format} unless overridden by the
    # per-call +options+ argument or keyword overrides. Options control masking,
    # HTML escaping, URL encoding, and the callback used when formatting fails.
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CpfFormatterOptions} instance or a {Hash}), it alone
    # determines the default options; otherwise, the default options are built
    # exclusively from the keyword arguments, with {CpfFormatterOptions} filling
    # in its own defaults for every keyword left as +nil+. Passing +options+
    # together with any non-+nil+ keyword argument raises
    # {InvalidArgumentCombinationError} instead of silently ignoring the keywords.
    #
    # When +options+ is a {CpfFormatterOptions} instance, that instance is used
    # directly (no copy is created). Mutating it later (e.g. via the {#options}
    # reader or the original reference) affects future {#format} calls that do
    # not pass per-call options. When a plain {Hash} is passed instead, a new
    # {CpfFormatterOptions} instance is created from it.
    #
    # @param options [CpfFormatterOptions, Hash, nil] default formatter options
    # @param keywords [Hash] option keyword overrides (mutually exclusive with +options+;
    #   see {CpfFormatterOptions})
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key option contains a disallowed character
    def initialize(options = nil, **keywords)
      @options = resolve_default_options(options, keywords)
    end

    # Formats a CPF value into a human-readable string.
    #
    # Input is normalized by stripping non-digit characters. If the result
    # length is not exactly 11, the configured +on_fail+ callback is invoked
    # with the original value and a {DomainError}; its return value is used as
    # the result.
    #
    # When valid, the result may be further transformed according to options:
    #
    # - If +hidden+ is +true+, digits between +hidden_start+ and +hidden_end+
    #   (inclusive) are replaced with +hidden_key+.
    # - If +escape+ is +true+, HTML special characters are escaped.
    # - If +encode+ is +true+, the string is URL-encoded (similar to JavaScript's
    #   +encodeURIComponent+).
    #
    # +options+ and the keyword arguments are never merged with each other: when
    # +options+ is given (a {CpfFormatterOptions} instance or a {Hash}), it alone
    # overrides the instance default options for this call; otherwise, any
    # non-+nil+ keyword argument overrides the instance default options for this
    # call. When neither +options+ nor any keyword argument is given, the
    # instance default options are used as-is. In every case, the instance
    # default options themselves are left unchanged. Passing +options+ together
    # with any non-+nil+ keyword argument raises {InvalidArgumentCombinationError}
    # instead of silently ignoring the keywords.
    #
    # @param cpf_input [String, Array<String>] CPF value as a string or array of
    #   strings
    # @param options [CpfFormatterOptions, Hash, nil] per-call option overrides
    # @param keywords [Hash] per-call option keyword overrides (mutually exclusive
    #   with +options+; see {CpfFormatterOptions})
    # @return [String] formatted CPF string, or the +on_fail+ callback result
    # @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
    # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key option contains a disallowed character
    #
    # @example
    #   formatter = CpfFmt::CpfFormatter.new
    #   formatter.format('12345678910') # => "123.456.789-10"
    def format(cpf_input, options = nil, **keywords)
      actual_input = Utils.to_string_input(cpf_input)
      actual_options = resolve_call_options(options, keywords)
      formatted_cpf = Utils.sanitize_cpf_input(actual_input)

      return handle_invalid_length(cpf_input, formatted_cpf, actual_options) unless valid_length?(formatted_cpf)

      format_valid_cpf(formatted_cpf, actual_options)
    end

    private

    def valid_length?(formatted_cpf)
      formatted_cpf.length == CpfFormatterOptions::CPF_LENGTH
    end

    def handle_invalid_length(cpf_input, formatted_cpf, actual_options)
      error = InvalidLengthError.new(
        cpf_input,
        formatted_cpf,
        CpfFormatterOptions::CPF_LENGTH
      )

      Utils.invoke_on_fail(actual_options.on_fail, cpf_input, error)
    end

    def format_valid_cpf(formatted_cpf, actual_options)
      formatted_cpf = Utils.apply_hidden_mask(formatted_cpf, actual_options) if actual_options.hidden
      formatted_cpf = Utils.insert_delimiters(formatted_cpf, actual_options)

      if actual_options.hidden
        formatted_cpf = Utils.replace_hidden_placeholders(
          formatted_cpf,
          actual_options.hidden_key
        )
      end

      Utils.apply_post_processing(formatted_cpf, actual_options)
    end

    def resolve_default_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return options if options.is_a?(CpfFormatterOptions)
      return CpfFormatterOptions.new(options) if options

      CpfFormatterOptions.new(**keywords)
    end

    def resolve_call_options(options, keywords)
      keyword_overrides = compact_keyword_overrides(keywords)
      raise_ambiguous_options! if options && !keyword_overrides.empty?
      return @options.copy.set(options) if options
      return @options if keyword_overrides.empty?

      @options.copy.set(keyword_overrides)
    end

    def compact_keyword_overrides(keywords)
      CpfFormatterOptions::OPTION_KEYS.each_with_object({}) do |key, overrides|
        value = keywords[key]
        overrides[key] = value unless value.nil?
      end
    end

    def raise_ambiguous_options!
      option_keywords = CpfFormatterOptions::OPTION_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            "Pass either an options instance/Hash to `options`, or keyword arguments (#{option_keywords}), " \
            'not both.'
    end
  end
end
