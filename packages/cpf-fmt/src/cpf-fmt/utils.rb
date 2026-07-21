# frozen_string_literal: true

module CpfFmt
  # Low-level helpers used by {CpfFormatter} and {CpfFormatterOptions}.
  #
  # @api private
  module Utils
    # A rarely-used 1-length character that is replaced with +hidden_key+ when
    # +hidden+ is +true+.
    HIDDEN_KEY_PLACEHOLDER = CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS[0]
    NON_DIGIT_PATTERN = /\D/

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

    def sanitize_cpf_input(value)
      if value.length == CpfFormatterOptions::CPF_LENGTH &&
         value.ascii_only? &&
         value.match?(/\A[0-9]+\z/)
        return value
      end

      value.gsub(NON_DIGIT_PATTERN, '')
    end

    def apply_hidden_mask(formatted_cpf, options)
      starting_part = formatted_cpf[0...options.hidden_start]
      ending_part = formatted_cpf[(options.hidden_end + 1)..]
      hidden_part_length = options.hidden_end - options.hidden_start + 1
      hidden_part = HIDDEN_KEY_PLACEHOLDER * hidden_part_length

      starting_part + hidden_part + ending_part
    end

    def insert_delimiters(formatted_cpf, options)
      formatted_cpf[0, 3] +
        options.dot_key +
        formatted_cpf[3, 3] +
        options.dot_key +
        formatted_cpf[6, 3] +
        options.dash_key +
        formatted_cpf[9, 2]
    end

    def replace_hidden_placeholders(formatted_cpf, hidden_key)
      formatted_cpf.gsub(HIDDEN_KEY_PLACEHOLDER, hidden_key)
    end

    def apply_post_processing(formatted_cpf, options)
      formatted_cpf = CGI.escapeHTML(formatted_cpf) if options.escape
      formatted_cpf = ERB::Util.url_encode(formatted_cpf) if options.encode
      formatted_cpf
    end

    # Normalizes the input to a string.
    #
    # @param cpf_input [Object] candidate CPF input
    # @return [String] joined string input
    # @raise [TypeMismatchError] if the input is not a +String+ or +Array<String>+
    def to_string_input(cpf_input)
      return cpf_input if cpf_input.is_a?(String)

      if cpf_input.is_a?(Array)
        cpf_input.each do |item|
          raise TypeMismatchError.new(cpf_input, 'string or string[]') unless item.is_a?(String)
        end

        return cpf_input.join
      end

      raise TypeMismatchError.new(cpf_input, 'string or string[]')
    end

    # Invokes the +on_fail+ callback and validates its return type.
    #
    # @param on_fail [Proc] failure callback
    # @param cpf_input [String, Array<String>] original input
    # @param error [DomainError] domain failure passed to the callback
    # @return [String] callback result
    # @raise [TypeMismatchError] if the callback does not return a +String+
    def invoke_on_fail(on_fail, cpf_input, error)
      result = on_fail.call(cpf_input, error)
      raise TypeMismatchError.new(result, 'string', option_name: 'on_fail') unless result.is_a?(String)

      result
    end
  end
end
