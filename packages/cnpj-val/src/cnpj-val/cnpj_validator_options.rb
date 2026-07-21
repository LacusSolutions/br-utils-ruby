# frozen_string_literal: true

require_relative 'types'
require_relative 'errors'

module CnpjVal
  # Internal validation helpers for {CnpjValidatorOptions}.
  module OptionsValidation
    module_function

    # rubocop:disable Naming/PredicateMethod -- coercion helper, not a predicate query
    def normalize_boolean(value)
      return false if [false, '', 0].include?(value)

      !!value
    end
    # rubocop:enable Naming/PredicateMethod

    def assert_string_type!(value)
      return if value.is_a?(String)

      raise TypeMismatchError.new(value, 'string', option_name: 'type')
    end

    def assert_valid_type_value!(value)
      return if CNPJ_TYPE_OPTIONS.include?(value)

      raise ValidationError.new('type', value, expected_values: CNPJ_TYPE_OPTIONS)
    end
  end

  # Class to store the options for the CNPJ validator.
  #
  # Provides a centralized way to configure how CNPJs are validated, including
  # case sensitivity and the type of format that should be considered valid
  # (+numeric+ or +alphanumeric+).
  class CnpjValidatorOptions
    # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
    # identifier (14 alphanumeric characters).
    CNPJ_LENGTH = 14

    # Option keys accepted by validator entry points and this options class.
    OPTION_KEYS = VALIDATOR_OPTION_KEYS

    # Default value for the +case_sensitive+ option.
    #
    # When +false+ and alphanumeric CNPJ is being validated, lowercase
    # characters are also considered valid. Example: for a valid CNPJ
    # +AB.123.CDE/FGHI-45+, if +case_sensitive+ is +false+, +ab.123.cde/fghi-45+
    # is also considered valid.
    DEFAULT_CASE_SENSITIVE = true

    # Default type of characters to validate for the CNPJ.
    DEFAULT_TYPE = 'alphanumeric'

    # Creates a new options instance.
    #
    # Options can be provided in multiple ways:
    #
    # 1. As a single options {Hash} or another {CnpjValidatorOptions} instance.
    # 2. As multiple override objects that are merged in order (later overrides
    #    take precedence).
    #
    # All options are optional and will default to their predefined values if not
    # provided.
    #
    # @param options [CnpjValidatorOptions, Hash, nil] initial options
    # @param extra_overrides [Array<CnpjValidatorOptions, Hash>] additional option
    #   layers merged in order (later overrides win)
    # @param case_sensitive [Boolean, nil] case sensitivity override
    # @param type [String, nil] character set override
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +type+ is not one of the allowed values
    def initialize(options = nil, *extra_overrides, case_sensitive: nil, type: nil)
      @options = {}

      self.case_sensitive = case_sensitive
      self.type = type

      to_merge = []
      to_merge << options unless options.nil?
      to_merge.concat(extra_overrides)
      to_merge.each { |item| set(item) }
    end

    # Returns a shallow, frozen snapshot of all current options.
    #
    # This is useful for creating immutable snapshots of the current configuration.
    # Keys are +case_sensitive+ (+true+ by default) and +type+ (+alphanumeric+ by
    # default). When +case_sensitive+ is +false+ and alphanumeric CNPJ is being
    # validated, lowercase characters are also considered valid (e.g.
    # +ab.123.cde/fghi-45+ for +AB.123.CDE/FGHI-45+).
    #
    # @return [Hash{Symbol => Object}] immutable snapshot of option values
    def all
      {
        case_sensitive: @options[:case_sensitive],
        type: @options[:type]
      }.freeze
    end

    # Returns whether the CNPJ is validated in a case-sensitive manner.
    #
    # @return [Boolean]
    def case_sensitive
      @options[:case_sensitive]
    end

    # Sets whether the CNPJ is validated in a case-sensitive manner.
    #
    # @param value [Boolean, nil] case sensitivity; +nil+ uses default
    def case_sensitive=(value)
      actual_case_sensitive =
        if value.nil?
          DEFAULT_CASE_SENSITIVE
        else
          OptionsValidation.normalize_boolean(value)
        end

      @options[:case_sensitive] = actual_case_sensitive
    end

    # Returns the type of characters to validate for the CNPJ.
    #
    # @return [String] +"alphanumeric"+ or +"numeric"+
    def type
      @options[:type]
    end

    # Sets the type of characters to validate for the CNPJ.
    #
    # The options are:
    #
    # - +alphanumeric+: alphanumeric CNPJ format.
    # - +numeric+: numeric-only (legacy) CNPJ format.
    #
    # @param value [String, nil] character set; +nil+ uses default
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value is not a valid type
    def type=(value)
      actual_type = value.nil? ? DEFAULT_TYPE : value

      OptionsValidation.assert_string_type!(actual_type)
      OptionsValidation.assert_valid_type_value!(actual_type)

      @options[:type] = actual_type
    end

    # Sets multiple options at once.
    #
    # This method allows you to update multiple options in a single call. Only the
    # provided options are updated; options not included in the object retain their
    # current values. You can pass either a partial options {Hash} or another
    # {CnpjValidatorOptions} instance.
    #
    # @param options [CnpjValidatorOptions, Hash, nil] options to merge
    # @return [CnpjValidatorOptions] +self+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +type+ is not one of the allowed values
    def set(options)
      return self if options.nil?

      source_case_sensitive, source_type = option_values_from(options)

      self.case_sensitive = source_case_sensitive unless source_case_sensitive.nil?
      self.type = source_type unless source_type.nil?

      self
    end

    # Returns a shallow copy of this options instance.
    #
    # @return [CnpjValidatorOptions] duplicated options for per-call merging
    def copy
      duplicate = self.class.allocate
      duplicate.instance_variable_set(:@options, @options.dup)
      duplicate
    end

    private

    def option_values_from(options)
      return [options.case_sensitive, options.type] if options.is_a?(CnpjValidatorOptions)

      if options.is_a?(Hash)
        return [
          fetch_option(options, :case_sensitive),
          fetch_option(options, :type)
        ]
      end

      [nil, nil]
    end

    def fetch_option(source, key)
      return source[key] if source.key?(key)
      return source[key.to_s] if source.key?(key.to_s)

      nil
    end
  end
end
