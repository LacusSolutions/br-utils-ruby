# frozen_string_literal: true

module CnpjFmt
  # Low-level helpers used by {CnpjFormatter} and {CnpjFormatterOptions}.
  #
  # @api private
  module Utils
    # A rarely-used 1-length character that is replaced with +hidden_key+ when
    # +hidden+ is +true+.
    HIDDEN_KEY_PLACEHOLDER = CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS[0]
    ALPHANUMERIC_PATTERN = /[^0-9A-Za-z]/

    module_function

    # rubocop:disable Naming/PredicateMethod -- coercion helper, not a predicate query
    def normalize_boolean(value)
      return false if [false, '', 0].include?(value)

      !!value
    end
    # rubocop:enable Naming/PredicateMethod

    def assert_string_option!(option_name, value)
      return if value.is_a?(String)

      raise TypeMismatchError.new(value, 'string', option_name: option_name)
    end

    def assert_no_disallowed_key_characters!(option_name, value, forbidden_characters)
      return unless value.chars.intersect?(forbidden_characters)

      raise ValidationError.new(option_name, value, forbidden_characters)
    end

    def assert_hidden_index_type!(option_name, value)
      return if value.is_a?(Integer)

      raise TypeMismatchError.new(value, 'integer', option_name: option_name)
    end

    def assert_hidden_index!(option_name, value, min_value, max_value)
      return if value.between?(min_value, max_value)

      raise OutOfRangeError.new(option_name, value, min_value, max_value)
    end

    def fetch_option(source, key)
      return source[key] if source.key?(key)
      return source[key.to_s] if source.key?(key.to_s)

      nil
    end

    def normalize_hidden_range(hidden_start, hidden_end, min_value, max_value)
      assert_hidden_index_type!('hidden_start', hidden_start)
      assert_hidden_index_type!('hidden_end', hidden_end)
      assert_hidden_index!('hidden_start', hidden_start, min_value, max_value)
      assert_hidden_index!('hidden_end', hidden_end, min_value, max_value)

      return [hidden_end, hidden_start] if hidden_start > hidden_end

      [hidden_start, hidden_end]
    end

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
    # @param error [DomainError] domain failure passed to the callback
    # @return [String] callback result
    # @raise [TypeMismatchError] if the callback does not return a +String+
    def invoke_on_fail(on_fail, cnpj_input, error)
      result = on_fail.call(cnpj_input, error)
      raise TypeMismatchError.new(result, 'string', option_name: 'on_fail') unless result.is_a?(String)

      result
    end
  end
end
