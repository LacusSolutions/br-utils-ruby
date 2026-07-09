# frozen_string_literal: true

require_relative 'generator_options_validation'

module CnpjGen
  # Property accessors for {CnpjGeneratorOptions}.
  module CnpjGeneratorOptionProperties
    # Returns a shallow copy of all current options.
    #
    # Exposes resolved +format+, +prefix+, and +type+ values. This is useful for
    # creating snapshots of the current configuration.
    #
    # @return [Hash{Symbol => Object}] shallow copy of option values
    def all
      @options.dup
    end

    # Returns whether the generated CNPJ string will have the standard formatting
    # (+00.000.000/0000-00+).
    #
    # @return [Boolean]
    def format
      @options[:format]
    end

    # Sets whether the generated CNPJ string will have the standard formatting
    # (+00.000.000/0000-00+). The value is converted to a boolean, so truthy/falsy
    # values are handled appropriately.
    #
    # @param value [Boolean, nil] enable formatting when truthy; +nil+ uses default
    def format=(value)
      actual_format =
        if value.nil?
          CnpjGeneratorOptions::DEFAULT_FORMAT
        else
          GeneratorOptionsValidation.normalize_boolean(value)
        end

      @options[:format] = actual_format
    end

    # Returns the string used as the initial string of the generated CNPJ.
    #
    # Note: If the evaluated +prefix+ (after stripping non-alphanumeric characters)
    # is longer than 12 characters, the extra characters are ignored, because a
    # CNPJ has 12 base characters followed by 2 calculated check digits.
    #
    # @return [String]
    def prefix
      @options[:prefix]
    end

    # Sets the string used as the initial string of the generated CNPJ. Only
    # alphanumeric characters are kept and the rest is stripped. If provided,
    # only the missing characters are generated randomly. For example, if the
    # +prefix+ +"AAABBB"+ (6 characters) is given, only the next 8 characters are
    # randomly generated and concatenated to the +prefix+.
    #
    # Note: If the evaluated +prefix+ (after stripping non-alphanumeric characters)
    # is longer than 12 characters, the extra characters are ignored, because a
    # CNPJ has 12 base characters followed by 2 calculated check digits.
    #
    # @param value [String, nil] partial start string; +nil+ uses default
    # @raise [CnpjGeneratorOptionsTypeError] if the value is not a +String+
    # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
    def prefix=(value)
      actual_prefix = GeneratorOptionsValidation.sanitize_prefix(value)

      GeneratorOptionsValidation.validate_prefix!(actual_prefix)

      @options[:prefix] = actual_prefix
    end

    # Returns the type of characters to generate for the CNPJ.
    #
    # @return [String]
    def type
      @options[:type]
    end

    # Sets the type of characters to generate for the CNPJ.
    #
    # The options are:
    #
    # - +alphabetic+ — generates a sequence of alphabetic characters (+A-Z+).
    # - +alphanumeric+ — generates a sequence of alphanumeric characters (+0-9A-Z+).
    # - +numeric+ — generates a sequence of numbers-only characters (+0-9+).
    #
    # If a +prefix+ is provided, only the remaining characters (those generated
    # randomly) use this +type+.
    #
    # @param value [String, nil] one of {CNPJ_TYPE_VALUES}; +nil+ uses default
    # @raise [CnpjGeneratorOptionsTypeError] if the value is not a +String+
    # @raise [CnpjGeneratorOptionTypeInvalidException] if the value is not allowed
    def type=(value)
      actual_type = value.nil? ? CnpjGeneratorOptions::DEFAULT_TYPE : value

      GeneratorOptionsValidation.assert_string_option!('type', actual_type)

      unless CNPJ_TYPE_VALUES.include?(actual_type)
        raise CnpjGeneratorOptionTypeInvalidException.new(actual_type, CNPJ_TYPE_OPTIONS_ORDER)
      end

      @options[:type] = actual_type
    end
  end
end
