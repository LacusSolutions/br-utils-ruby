# frozen_string_literal: true

require 'cgi'
require 'erb'

module CnpjFmt
  # Formatter for CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
  #
  # Normalizes and optionally masks, HTML-escapes, or URL-encodes 14-character
  # alphanumeric CNPJ input. Accepts a string or array of strings;
  # non-alphanumeric characters are stripped and the result is uppercased.
  # Invalid input type is handled by throwing; invalid length is handled via the
  # configured +on_fail+ callback instead of throwing.
  class CnpjFormatter
    # Returns the default options used by this formatter when per-call options
    # are not provided.
    #
    # The returned object is the same instance used internally; mutating it (e.g.
    # via setters on {CnpjFormatterOptions}) affects future {#format} calls that
    # do not pass +options+.
    #
    # @return [CnpjFormatterOptions] the instance default options
    attr_reader :options

    # Creates a new formatter with optional default options.
    #
    # Default options apply to every call to {#format} unless overridden by the
    # per-call +options+ argument or keyword overrides. Options control masking,
    # HTML escaping, URL encoding, and the callback used when formatting fails.
    #
    # When +options+ is a {CnpjFormatterOptions} instance, that instance is used
    # directly (no copy is created). Mutating it later (e.g. via the {#options}
    # reader or the original reference) affects future {#format} calls that do
    # not pass per-call options. When a plain {Hash} or nothing is passed, a new
    # {CnpjFormatterOptions} instance is created from it.
    #
    # @param options [CnpjFormatterOptions, Hash, nil] default formatter options
    # @param extra_overrides [Array<CnpjFormatterOptions, Hash>] additional option
    #   layers merged in order (later overrides win)
    # @param keywords [Hash] option keyword overrides (see {CnpjFormatterOptions})
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+ or
    #   +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key
    #   option contains a disallowed character
    def initialize(options = nil, *extra_overrides, **keywords)
      @options =
        if options.is_a?(CnpjFormatterOptions)
          options
        else
          CnpjFormatterOptions.new(options, *extra_overrides, **keywords)
        end
    end

    # Formats a CNPJ value into a human-readable string.
    #
    # Input is normalized by stripping non-alphanumeric characters and converting
    # to uppercase. If the result length is not exactly 14, the configured
    # +on_fail+ callback is invoked with the original value and a {DomainError};
    # its return value is used as the result.
    #
    # When valid, the result may be further transformed according to options:
    #
    # - If +hidden+ is +true+, characters between +hidden_start+ and +hidden_end+
    #   (inclusive) are replaced with +hidden_key+.
    # - If +escape+ is +true+, HTML special characters are escaped.
    # - If +encode+ is +true+, the string is URL-encoded (similar to JavaScript's
    #   +encodeURIComponent+).
    #
    # Per-call +options+ and keyword overrides are merged over the instance
    # default options for this call only; the instance defaults are unchanged.
    # When both the +options+ argument and keyword parameters are provided,
    # +options+ takes precedence.
    #
    # @param cnpj_input [String, Array<String>] CNPJ value as a string or array of
    #   strings
    # @param options [CnpjFormatterOptions, Hash, nil] per-call option overrides
    # @param keywords [Hash] per-call option keyword overrides
    # @return [String] formatted CNPJ string, or the +on_fail+ callback result
    # @raise [TypeMismatchError] if the input is not a +String+ or
    #   +Array<String>+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+
    #   or +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key
    #   option contains a disallowed character
    #
    # @example
    #   formatter = CnpjFmt::CnpjFormatter.new
    #   formatter.format('12345678000910') # => "12.345.678/0009-10"
    def format(cnpj_input, options = nil, **keywords)
      actual_input = Utils.to_string_input(cnpj_input)
      actual_options = resolve_format_options(options, keywords)
      formatted_cnpj = Utils.sanitize_cnpj_input(actual_input)

      return handle_invalid_length(cnpj_input, formatted_cnpj, actual_options) unless valid_length?(formatted_cnpj)

      format_valid_cnpj(formatted_cnpj, actual_options)
    end

    private

    def valid_length?(formatted_cnpj)
      formatted_cnpj.length == CnpjFormatterOptions::CNPJ_LENGTH
    end

    def handle_invalid_length(cnpj_input, formatted_cnpj, actual_options)
      error = InvalidLengthError.new(
        cnpj_input,
        formatted_cnpj,
        CnpjFormatterOptions::CNPJ_LENGTH
      )

      Utils.invoke_on_fail(actual_options.on_fail, cnpj_input, error)
    end

    def format_valid_cnpj(formatted_cnpj, actual_options)
      formatted_cnpj = Utils.apply_hidden_mask(formatted_cnpj, actual_options) if actual_options.hidden
      formatted_cnpj = Utils.insert_delimiters(formatted_cnpj, actual_options)

      if actual_options.hidden
        formatted_cnpj = Utils.replace_hidden_placeholders(
          formatted_cnpj,
          actual_options.hidden_key
        )
      end

      Utils.apply_post_processing(formatted_cnpj, actual_options)
    end

    def resolve_format_options(options, keywords)
      return @options unless per_call_overrides?(options, keywords)

      actual_options = @options.copy
      compact_keywords = compact_keyword_overrides(keywords)
      actual_options.set(compact_keywords) unless compact_keywords.empty?
      actual_options.set(options) unless options.nil?
      actual_options
    end

    def per_call_overrides?(options, keywords)
      options || keywords.values.any? { |value| !value.nil? }
    end

    def compact_keyword_overrides(keywords)
      keywords.each_with_object({}) do |(key, value), overrides|
        overrides[key] = value unless value.nil?
      end
    end
  end
end
