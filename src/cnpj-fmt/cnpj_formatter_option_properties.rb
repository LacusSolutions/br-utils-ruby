# frozen_string_literal: true

module CnpjFmt
  # Property accessors for {CnpjFormatterOptions}.
  module CnpjFormatterOptionProperties
    # Returns a shallow copy of all current options.
    #
    # This is useful for creating snapshots of the current configuration.
    #
    # @return [Hash{Symbol => Object}] shallow copy of option values
    def all
      @options.dup
    end

    # Returns whether hidden character replacement is enabled.
    #
    # When +true+, characters within the +hidden_start+ to +hidden_end+ range will
    # be replaced with the +hidden_key+ character.
    #
    # @return [Boolean]
    def hidden
      @options[:hidden]
    end

    # Sets whether hidden character replacement is enabled.
    #
    # When set to +true+, characters within the +hidden_start+ to +hidden_end+
    # range will be replaced with the +hidden_key+ character. The value is
    # converted to a boolean, so truthy/falsy values are handled appropriately.
    #
    # @param value [Boolean, nil] enable masking when truthy; +nil+ uses default
    def hidden=(value)
      @options[:hidden] =
        if value.nil?
          CnpjFormatterOptions::DEFAULT_HIDDEN
        else
          OptionsValidation.normalize_boolean(value)
        end
    end

    # Returns the string used to replace hidden CNPJ characters.
    #
    # This string is used when +hidden+ is +true+ to mask characters in the range
    # from +hidden_start+ to +hidden_end+ (inclusive).
    #
    # @return [String]
    def hidden_key
      @options[:hidden_key]
    end

    # Sets the string used to replace hidden CNPJ characters.
    #
    # This string is used when +hidden+ is +true+ to mask characters in the range
    # from +hidden_start+ to +hidden_end+ (inclusive).
    #
    # @param value [String, nil] replacement string; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value
    #   contains any disallowed key character
    def hidden_key=(value)
      assign_string_key_option('hidden_key', value, CnpjFormatterOptions::DEFAULT_HIDDEN_KEY)
    end

    # Returns the start index (inclusive) for hiding CNPJ characters.
    #
    # This is the first position in the CNPJ string where characters will be
    # replaced with the +hidden_key+ string when +hidden+ is +true+. Must be
    # between +0+ and +13+ ({CNPJ_LENGTH} - 1).
    #
    # @return [Integer]
    def hidden_start
      @options[:hidden_start]
    end

    # Sets the start index (inclusive) for hiding CNPJ characters.
    #
    # This is the first position in the CNPJ string where characters will be
    # replaced with the +hidden_key+ when +hidden+ is +true+. The value is
    # validated and will be swapped with +hidden_end+ if necessary to ensure
    # +hidden_start <= hidden_end+.
    #
    # @param value [Integer, nil] start index; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not an integer
    # @raise [OutOfRangeError] if the value is out
    #   of valid range +[0, CNPJ_LENGTH - 1]+
    def hidden_start=(value)
      set_hidden_range(value, @options[:hidden_end])
    end

    # Returns the end index (inclusive) for hiding CNPJ characters.
    #
    # This is the last position in the CNPJ string where characters will be
    # replaced with the +hidden_key+ string when +hidden+ is +true+. Must be
    # between +0+ and +13+ ({CNPJ_LENGTH} - 1).
    #
    # @return [Integer]
    def hidden_end
      @options[:hidden_end]
    end

    # Sets the end index (inclusive) for hiding CNPJ characters.
    #
    # This is the last position in the CNPJ string where characters will be
    # replaced with the +hidden_key+ when +hidden+ is +true+. The value is
    # validated and will be swapped with +hidden_start+ if necessary to ensure
    # +hidden_start <= hidden_end+.
    #
    # @param value [Integer, nil] end index; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not an integer
    # @raise [OutOfRangeError] if the value is out
    #   of valid range +[0, CNPJ_LENGTH - 1]+
    def hidden_end=(value)
      set_hidden_range(@options[:hidden_start], value)
    end

    # Returns the string used as the dot delimiter.
    #
    # This string is used to separate the first groups of characters in the
    # formatted CNPJ (e.g., +"."+ in +"12.345.678/0001-90"+).
    #
    # @return [String]
    def dot_key
      @options[:dot_key]
    end

    # Sets the string used as the dot delimiter.
    #
    # This string is used to separate the first groups of characters in the
    # formatted CNPJ (e.g., +"."+ in +"12.345.678/0001-90"+).
    #
    # @param value [String, nil] delimiter string; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value
    #   contains any disallowed key character
    def dot_key=(value)
      assign_string_key_option('dot_key', value, CnpjFormatterOptions::DEFAULT_DOT_KEY)
    end

    # Returns the string used as the slash delimiter.
    #
    # This string is used to separate the first group of characters from the
    # branch identifier in the formatted CNPJ (e.g., +"/"+ in
    # +"12.345.678/0001-90"+).
    #
    # @return [String]
    def slash_key
      @options[:slash_key]
    end

    # Sets the string used as the slash delimiter.
    #
    # This string is used to separate the first group of characters from the
    # branch identifier in the formatted CNPJ (e.g., +"/"+ in
    # +"12.345.678/0001-90"+).
    #
    # @param value [String, nil] delimiter string; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value
    #   contains any disallowed key character
    def slash_key=(value)
      assign_string_key_option('slash_key', value, CnpjFormatterOptions::DEFAULT_SLASH_KEY)
    end

    # Returns the string used as the dash delimiter.
    #
    # This string is used to separate the check digits at the end in the
    # formatted CNPJ (e.g., +"-"+ in +"12.345.678/0001-90"+).
    #
    # @return [String]
    def dash_key
      @options[:dash_key]
    end

    # Sets the string used as the dash delimiter.
    #
    # This string is used to separate the check digits at the end in the
    # formatted CNPJ (e.g., +"-"+ in +"12.345.678/0001-90"+).
    #
    # @param value [String, nil] delimiter string; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value
    #   contains any disallowed key character
    def dash_key=(value)
      assign_string_key_option('dash_key', value, CnpjFormatterOptions::DEFAULT_DASH_KEY)
    end

    # Returns whether HTML escaping is enabled.
    #
    # When +true+, HTML special characters (like +<+, +>+, +&+, etc.) in the
    # formatted CNPJ string will be escaped. This is useful when using custom
    # delimiters that may contain HTML characters or when displaying CNPJ in HTML.
    #
    # @return [Boolean]
    def escape
      @options[:escape]
    end

    # Sets whether HTML escaping is enabled.
    #
    # When set to +true+, HTML special characters (like +<+, +>+, +&+, etc.) in
    # the formatted CNPJ string will be escaped. This is useful when using custom
    # delimiters that may contain HTML characters or when displaying CNPJ in HTML.
    # The value is converted to a boolean, so truthy/falsy values are handled
    # appropriately.
    #
    # @param value [Boolean, nil] enable escaping when truthy; +nil+ uses default
    def escape=(value)
      @options[:escape] =
        if value.nil?
          CnpjFormatterOptions::DEFAULT_ESCAPE
        else
          OptionsValidation.normalize_boolean(value)
        end
    end

    # Returns whether URL encoding is enabled.
    #
    # When +true+, the formatted CNPJ string will be URL-encoded, making it safe
    # to use in URL query parameters or path segments.
    #
    # @return [Boolean]
    def encode
      @options[:encode]
    end

    # Sets whether URL encoding is enabled.
    #
    # When set to +true+, the formatted CNPJ string will be URL-encoded, making
    # it safe to use in URL query parameters or path segments. The value is
    # converted to a boolean, so truthy/falsy values are handled appropriately.
    #
    # @param value [Boolean, nil] enable encoding when truthy; +nil+ uses default
    def encode=(value)
      @options[:encode] =
        if value.nil?
          CnpjFormatterOptions::DEFAULT_ENCODE
        else
          OptionsValidation.normalize_boolean(value)
        end
    end

    # Returns the callback executed when formatting fails.
    #
    # This function is called when the formatter encounters an error (e.g.,
    # invalid input length). It receives the input value and an exception object,
    # and should return a string to use as the fallback output.
    #
    # @return [Proc] failure callback
    def on_fail
      @options[:on_fail]
    end

    # Sets the callback executed when formatting fails.
    #
    # This function is called when the formatter encounters an error (e.g.,
    # invalid input length). It receives the input value and an exception object,
    # and should return a string to use as the fallback output.
    #
    # @param value [Proc, nil] callback; +nil+ uses {CnpjFormatterOptions.default_on_fail}
    # @raise [TypeMismatchError] if the value is not callable
    def on_fail=(value)
      actual_on_fail = value.nil? ? CnpjFormatterOptions.default_on_fail : value
      raise TypeMismatchError.new(value, 'function', option_name: 'on_fail') unless actual_on_fail.respond_to?(:call)

      @options[:on_fail] = actual_on_fail
    end
  end
end
