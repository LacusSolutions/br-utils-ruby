# frozen_string_literal: true

module CnpjFmt
  # Low-level formatting helpers used by {CnpjFormatter}.
  #
  # @api private
  module FormatterSupport
    # A rarely-used 1-length character that is replaced with +hidden_key+ when
    # +hidden+ is +true+.
    HIDDEN_KEY_PLACEHOLDER = CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS[0]
    ALPHANUMERIC_PATTERN = /[^0-9A-Za-z]/

    module_function

    def sanitize_cnpj_input(value)
      if value.length == CnpjFormatterOptions::CNPJ_LENGTH &&
         value.ascii_only? &&
         value.match?(/\A[0-9A-Za-z]+\z/)
        return value if value == value.upcase

        return value.upcase
      end

      value.gsub(ALPHANUMERIC_PATTERN, '').upcase
    end

    def apply_hidden_mask(formatted_cnpj, options)
      starting_part = formatted_cnpj[0...options.hidden_start]
      ending_part = formatted_cnpj[(options.hidden_end + 1)..]
      hidden_part_length = options.hidden_end - options.hidden_start + 1
      hidden_part = HIDDEN_KEY_PLACEHOLDER * hidden_part_length

      starting_part + hidden_part + ending_part
    end

    def insert_delimiters(formatted_cnpj, options)
      formatted_cnpj[0, 2] +
        options.dot_key +
        formatted_cnpj[2, 3] +
        options.dot_key +
        formatted_cnpj[5, 3] +
        options.slash_key +
        formatted_cnpj[8, 4] +
        options.dash_key +
        formatted_cnpj[12, 2]
    end

    def replace_hidden_placeholders(formatted_cnpj, hidden_key)
      formatted_cnpj.gsub(HIDDEN_KEY_PLACEHOLDER, hidden_key)
    end

    def apply_post_processing(formatted_cnpj, options)
      formatted_cnpj = CGI.escapeHTML(formatted_cnpj) if options.escape
      formatted_cnpj = ERB::Util.url_encode(formatted_cnpj) if options.encode
      formatted_cnpj
    end

    # Normalizes the input to a string.
    #
    # @param cnpj_input [Object] candidate CNPJ input
    # @return [String] joined string input
    # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+
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

    # Invokes the +on_fail+ callback and validates its return type.
    #
    # @param on_fail [Proc] failure callback
    # @param cnpj_input [String, Array<String>] original input
    # @param exception [InvalidLengthError] length error
    # @return [String] callback result
    # @raise [TypeMismatchError] if the callback does not return a +String+
    def invoke_on_fail(on_fail, cnpj_input, exception)
      result = on_fail.call(cnpj_input, exception)
      raise TypeMismatchError.new(result, 'string', option_name: 'on_fail') unless result.is_a?(String)

      result
    end
  end
end
