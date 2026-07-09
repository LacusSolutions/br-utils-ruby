# frozen_string_literal: true

require_relative 'types'
require_relative 'exceptions'
require_relative 'generator_options_validation'
require_relative 'cnpj_generator_option_properties'

module CnpjGen
  # Stores configuration for the CNPJ generator.
  #
  # Provides a centralized way to configure how CNPJ characters are generated,
  # including partial start string (+prefix+), formatting (+format+), and the type
  # of characters to be generated (+numeric+, +alphabetic+, or +alphanumeric+).
  class CnpjGeneratorOptions
    include CnpjGeneratorOptionProperties

    # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
    # identifier (14 alphanumeric characters).
    CNPJ_LENGTH = 14

    # Maximum length of the +prefix+ (base ID and branch ID) of a CNPJ.
    CNPJ_PREFIX_MAX_LENGTH = CNPJ_LENGTH - 2

    # Default value for the +format+ option. When +true+, the generated CNPJ
    # string will have the standard formatting (+00.000.000/0000-00+).
    DEFAULT_FORMAT = false

    # Default string used as the initial string of the generated CNPJ.
    DEFAULT_PREFIX = ''

    # Default type of characters to generate for the CNPJ.
    DEFAULT_TYPE = 'alphanumeric'

    CNPJ_BASE_ID_LENGTH = 8
    CNPJ_BASE_ID_LAST_INDEX = CNPJ_BASE_ID_LENGTH - 1
    ZEROED_CNPJ_BASE_ID = '0' * CNPJ_BASE_ID_LENGTH

    CNPJ_BRANCH_ID_LENGTH = 4
    CNPJ_BRANCH_ID_LAST_INDEX = CNPJ_BASE_ID_LAST_INDEX + CNPJ_BRANCH_ID_LENGTH
    ZEROED_CNPJ_BRANCH_ID = '0' * CNPJ_BRANCH_ID_LENGTH

    PREFIX_SANITIZE_PATTERN = /[^0-9A-Za-z]/

    # Creates a new {CnpjGeneratorOptions} instance.
    #
    # Options can be provided in multiple ways:
    #
    # 1. As a single options {Hash} or another {CnpjGeneratorOptions} instance.
    # 2. As multiple override objects that are merged in order (later overrides
    #    take precedence).
    #
    # All options are optional and will default to their predefined values if not
    # provided.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] initial options
    # @param extra_overrides [Array<CnpjGeneratorOptions, Hash>] additional option
    #   layers merged in order (later overrides win)
    # @param format [Boolean, nil] whether to format the generated CNPJ
    # @param prefix [String, nil] partial start string for the generated CNPJ
    # @param type [String, nil] character set for random segments
    # @raise [CnpjGeneratorOptionsTypeError] if any option has an invalid type
    # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
    # @raise [CnpjGeneratorOptionTypeInvalidException] if +type+ is not allowed
    def initialize(options = nil, *extra_overrides, format: nil, prefix: nil, type: nil)
      @options = {}

      apply_initial_options(options, format: format, prefix: prefix, type: type)
      extra_overrides.each { |override| set(override) }
    end

    # Sets multiple options at once. This method allows you to update multiple
    # options in a single call. Only the provided options are updated; options
    # not included in the object retain their current values. You can pass either
    # a partial options {Hash} or another {CnpjGeneratorOptions} instance.
    #
    # @param options [CnpjGeneratorOptions, Hash, nil] options to merge
    # @return [CnpjGeneratorOptions] +self+
    # @raise [CnpjGeneratorOptionsTypeError] if any option has an invalid type
    # @raise [CnpjGeneratorOptionPrefixInvalidException] if +prefix+ is invalid
    # @raise [CnpjGeneratorOptionTypeInvalidException] if +type+ is not allowed
    def set(options)
      return self if options.nil?

      source = merge_source(options)
      return self if source.nil?

      apply_merge_source(source)
      self
    end

    private

    def apply_initial_options(options, format:, prefix:, type:)
      return copy_options(options) if options.is_a?(CnpjGeneratorOptions)
      return apply_hash_options(options) if options.is_a?(Hash)

      self.format = format
      self.prefix = prefix
      self.type = type
    end

    def copy_options(options)
      self.format = options.format
      self.prefix = options.prefix
      self.type = options.type
    end

    def apply_hash_options(options)
      self.format = GeneratorOptionsValidation.fetch_option(options, :format)
      self.prefix = GeneratorOptionsValidation.fetch_option(options, :prefix)
      self.type = GeneratorOptionsValidation.fetch_option(options, :type)
    end

    def merge_source(options)
      return options_set_values(options) if options.is_a?(CnpjGeneratorOptions)
      return options if options.is_a?(Hash)

      nil
    end

    def options_set_values(options)
      {
        format: options.format,
        prefix: options.prefix,
        type: options.type
      }
    end

    def apply_merge_source(source)
      apply_merge_value(source, :format)
      apply_merge_value(source, :prefix)
      apply_merge_value(source, :type)
    end

    def apply_merge_value(source, key)
      return unless source.key?(key) || source.key?(key.to_s)

      value = GeneratorOptionsValidation.fetch_option(source, key)
      return if value.nil?

      public_send("#{key}=", value)
    end
  end
end
