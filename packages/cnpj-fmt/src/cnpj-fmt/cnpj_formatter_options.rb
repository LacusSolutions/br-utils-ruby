# frozen_string_literal: true

require_relative 'types'
require_relative 'cnpj_formatter_option_properties'

module CnpjFmt
  # Internal validation helpers for {CnpjFormatterOptions}.
  module OptionsValidation
    module_function

    def valid_integer?(value)
      value.is_a?(Integer)
    end

    # rubocop:disable Naming/PredicateMethod -- coercion helper, not a predicate query
    def normalize_boolean(value)
      return false if [false, '', 0].include?(value)

      !!value
    end
    # rubocop:enable Naming/PredicateMethod

    def assert_string_option!(option_name, value)
      return if value.is_a?(String)

      raise CnpjFormatterOptionsTypeError.new(option_name, value, 'string')
    end

    def assert_no_disallowed_key_characters!(option_name, value, forbidden_characters)
      return unless value.chars.intersect?(forbidden_characters)

      raise CnpjFormatterOptionsForbiddenKeyCharacterException.new(
        option_name,
        value,
        forbidden_characters
      )
    end

    def assert_hidden_index_type!(option_name, value)
      return if valid_integer?(value)

      raise CnpjFormatterOptionsTypeError.new(option_name, value, 'integer')
    end

    def assert_hidden_index!(option_name, value, min_value, max_value)
      return if value.between?(min_value, max_value)

      raise CnpjFormatterOptionsHiddenRangeInvalidException.new(
        option_name,
        value,
        min_value,
        max_value
      )
    end

    def normalize_hidden_range(hidden_start, hidden_end, defaults)
      actual_start = hidden_start.nil? ? defaults[:hidden_start] : hidden_start
      actual_end = hidden_end.nil? ? defaults[:hidden_end] : hidden_end

      assert_hidden_index_type!('hidden_start', actual_start)
      assert_hidden_index_type!('hidden_end', actual_end)
      assert_hidden_index!('hidden_start', actual_start, defaults[:min], defaults[:max])
      assert_hidden_index!('hidden_end', actual_end, defaults[:min], defaults[:max])

      actual_start, actual_end = actual_end, actual_start if actual_start > actual_end
      [actual_start, actual_end]
    end
  end

  # Stores configuration for the CNPJ formatter.
  #
  # Provides a centralized way to configure how CNPJ numbers are formatted,
  # including delimiters, hidden character ranges, HTML escaping, URL encoding,
  # and error handling callbacks.
  class CnpjFormatterOptions
    include CnpjFormatterOptionProperties

    # The standard length of a CNPJ (Cadastro Nacional da Pessoa Jurídica)
    # identifier (14 alphanumeric characters).
    CNPJ_LENGTH = 14

    # Minimum valid index for the hidden range (inclusive). Must be between 0 and
    # {CNPJ_LENGTH} - 1.
    MIN_HIDDEN_RANGE = 0

    # Maximum valid index for the hidden range (inclusive). Must be between 0 and
    # {CNPJ_LENGTH} - 1.
    MAX_HIDDEN_RANGE = CNPJ_LENGTH - 1

    # Default value for the +hidden+ option. When +false+, all CNPJ characters are
    # displayed.
    DEFAULT_HIDDEN = false

    # Default string used to replace hidden CNPJ characters.
    DEFAULT_HIDDEN_KEY = '*'

    # Default start index (inclusive) for hiding CNPJ characters. Characters from
    # this index onwards will be replaced with the +hidden_key+ value.
    DEFAULT_HIDDEN_START = 5

    # Default end index (inclusive) for hiding CNPJ characters. Characters up to
    # and including this index will be replaced with the +hidden_key+ value.
    DEFAULT_HIDDEN_END = 13

    # Default string used as the dot delimiter in formatted CNPJ. Used to separate
    # the first groups of characters (+XX.XXX.XXX+).
    DEFAULT_DOT_KEY = '.'

    # Default string used as the slash delimiter in formatted CNPJ. Used to
    # separate the first group of characters from the branch identifier
    # (+XXXXXXXX/XXXX+).
    DEFAULT_SLASH_KEY = '/'

    # Default string used as the dash delimiter in formatted CNPJ. Used to
    # separate the branch identifier from the check digits at the end (+XXXX-XX+).
    DEFAULT_DASH_KEY = '-'

    # Default value for the +escape+ option. When +false+, HTML special characters
    # are not escaped.
    DEFAULT_ESCAPE = false

    # Default value for the +encode+ option. When +false+, the CNPJ string is not
    # URL-encoded.
    DEFAULT_ENCODE = false

    # Characters that are not allowed in key options (+hidden_key+, +dot_key+,
    # +slash_key+, +dash_key+). They are reserved for internal formatting logic.
    #
    # For now, the first character is only used to replace the hidden key
    # placeholder in {CnpjFormatter}. However, this set of characters is reserved
    # for future use already.
    DISALLOWED_KEY_CHARACTERS = %w[å ë ï ö].freeze

    SIMPLE_OPTION_KEYS = (FORMATTER_OPTION_KEYS - %i[hidden_start hidden_end]).freeze

    class << self
      # Returns the shared default +on_fail+ callback.
      #
      # Returns an empty string by default. The callback is created lazily on first
      # use.
      #
      # @return [Proc] default failure callback
      def default_on_fail
        @default_on_fail ||= proc { |_value, _error| '' }
      end
    end

    # Default callback function executed when formatting fails. Returns an empty
    # string by default.
    DEFAULT_ON_FAIL = default_on_fail

    # Creates a new options instance.
    #
    # Options can be provided in multiple ways:
    #
    # 1. As a single options {Hash} or another {CnpjFormatterOptions} instance.
    # 2. As multiple override objects that are merged in order (later overrides
    #    take precedence).
    #
    # All options are optional and will default to their predefined values if not
    # provided. The +hidden_start+ and +hidden_end+ options are validated to ensure
    # they are within the valid range +[0, CNPJ_LENGTH - 1]+ and will be swapped
    # if +hidden_start > hidden_end+.
    #
    # @param options [CnpjFormatterOptions, Hash, nil] initial options
    # @param extra_overrides [Array<CnpjFormatterOptions, Hash>] additional option
    #   layers merged in order (later overrides win)
    # @param keywords [Hash] option keyword overrides
    # @raise [CnpjFormatterOptionsTypeError] if any option has an invalid type
    # @raise [CnpjFormatterOptionsHiddenRangeInvalidException] if +hidden_start+ or
    #   +hidden_end+ are out of valid range
    # @raise [CnpjFormatterOptionsForbiddenKeyCharacterException] if any key option
    #   contains a disallowed character
    def initialize(options = nil, *extra_overrides, **keywords)
      @options = {}

      apply_initial_keywords(keywords)
      set_hidden_range(keywords[:hidden_start], keywords[:hidden_end])

      to_merge = []
      to_merge << options unless options.nil?
      to_merge.concat(extra_overrides)
      to_merge.each { |item| set(item) }
    end

    # Sets +hidden_start+ and +hidden_end+ with validation.
    #
    # Validates that both indices are integers within the valid range
    # +[0, CNPJ_LENGTH - 1]+. If +hidden_start > hidden_end+, the values are
    # automatically swapped to ensure a valid range. This method is used internally
    # by the +hidden_start+ and +hidden_end+ setters to maintain consistency.
    #
    # @param hidden_start [Integer, nil] inclusive start index (0–13)
    # @param hidden_end [Integer, nil] inclusive end index (0–13)
    # @return [CnpjFormatterOptions] +self+
    # @raise [CnpjFormatterOptionsTypeError] if either value is not an integer
    # @raise [CnpjFormatterOptionsHiddenRangeInvalidException] if either value is
    #   out of valid range +[0, CNPJ_LENGTH - 1]+
    def set_hidden_range(hidden_start, hidden_end)
      start_index, end_index = OptionsValidation.normalize_hidden_range(
        hidden_start,
        hidden_end,
        hidden_range_defaults
      )
      @options[:hidden_start] = start_index
      @options[:hidden_end] = end_index
      self
    end

    # Returns a shallow copy of this options instance.
    #
    # @return [CnpjFormatterOptions] duplicated options for per-call merging
    def copy
      duplicate = self.class.allocate
      duplicate.instance_variable_set(:@options, @options.dup)
      duplicate
    end

    # Sets multiple options at once.
    #
    # Only the provided options are updated; options not included in the object
    # retain their current values. You can pass either a partial options {Hash} or
    # another {CnpjFormatterOptions} instance.
    #
    # @param options [CnpjFormatterOptions, Hash, nil] options to merge
    # @return [CnpjFormatterOptions] +self+
    # @raise [CnpjFormatterOptionsTypeError] if any option has an invalid type
    # @raise [CnpjFormatterOptionsHiddenRangeInvalidException] if +hidden_start+ or
    #   +hidden_end+ are out of valid range
    # @raise [CnpjFormatterOptionsForbiddenKeyCharacterException] if any key option
    #   contains a disallowed character
    def set(options)
      return self if options.nil?

      source = options_source(options)
      return self if source.nil?

      apply_option_updates(source)
      self
    end

    private

    def apply_initial_keywords(keywords)
      SIMPLE_OPTION_KEYS.each { |key| public_send("#{key}=", keywords[key]) }
    end

    def hidden_range_defaults
      {
        hidden_start: DEFAULT_HIDDEN_START,
        hidden_end: DEFAULT_HIDDEN_END,
        min: MIN_HIDDEN_RANGE,
        max: MAX_HIDDEN_RANGE
      }
    end

    def assign_string_key_option(option_name, value, default_value)
      actual_value = value.nil? ? default_value : value
      OptionsValidation.assert_string_option!(option_name, actual_value)
      OptionsValidation.assert_no_disallowed_key_characters!(
        option_name,
        actual_value,
        DISALLOWED_KEY_CHARACTERS
      )
      @options[option_name.to_sym] = actual_value
    end

    def options_source(options)
      return options.all if options.is_a?(CnpjFormatterOptions)
      return options if options.is_a?(Hash)

      nil
    end

    def apply_option_updates(source)
      SIMPLE_OPTION_KEYS.each do |key|
        public_send("#{key}=", coalesce_option(source, key, public_send(key)))
      end

      set_hidden_range(
        coalesce_option(source, :hidden_start, hidden_start),
        coalesce_option(source, :hidden_end, hidden_end)
      )
    end

    def coalesce_option(source, key, current)
      return current unless source.key?(key) || source.key?(key.to_s)

      value = source.fetch(key) { source.fetch(key.to_s) }
      value.nil? ? current : value
    end
  end
end
