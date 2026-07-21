# frozen_string_literal: true

require_relative 'types'

module CpfFmt
  # Layered option-resolution helpers for {CpfFormatterOptions}.
  module FormatterOptionsResolution
    private

    def fold_layers(layers)
      resolved = {}

      layers.each do |layer|
        source = layer_source(layer)
        next if source.nil?

        CpfFormatterOptions::OPTION_KEYS.each do |key|
          value = Utils.fetch_option(source, key)
          resolved[key] = value unless value.nil?
        end
      end

      resolved
    end

    def layer_source(layer)
      return layer.all if layer.is_a?(CpfFormatterOptions)
      return layer if layer.is_a?(Hash)

      nil
    end

    def apply_keyword_overrides(resolved, keywords)
      CpfFormatterOptions::OPTION_KEYS.each do |key|
        value = keywords[key]
        resolved[key] = value unless value.nil?
      end
    end

    def assign_resolved_or_default(resolved)
      CpfFormatterOptions::SIMPLE_OPTION_KEYS.each do |key|
        value = resolved.key?(key) ? resolved[key] : CpfFormatterOptions::DEFAULTS[key]
        public_send("#{key}=", value)
      end

      set_hidden_range(
        resolved.key?(:hidden_start) ? resolved[:hidden_start] : CpfFormatterOptions::DEFAULTS[:hidden_start],
        resolved.key?(:hidden_end) ? resolved[:hidden_end] : CpfFormatterOptions::DEFAULTS[:hidden_end]
      )
    end

    def assign_resolved_keeping_current(resolved)
      CpfFormatterOptions::SIMPLE_OPTION_KEYS.each do |key|
        next unless resolved.key?(key)

        public_send("#{key}=", resolved[key])
      end

      return unless resolved.key?(:hidden_start) || resolved.key?(:hidden_end)

      set_hidden_range(
        resolved.key?(:hidden_start) ? resolved[:hidden_start] : hidden_start,
        resolved.key?(:hidden_end) ? resolved[:hidden_end] : hidden_end
      )
    end

    def assign_string_key_option(option_name, value)
      Utils.assert_string_option!(option_name, value)
      Utils.assert_no_disallowed_key_characters!(
        option_name,
        value,
        CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS
      )
      @options[option_name.to_sym] = value
    end
  end

  # Property accessors for {CpfFormatterOptions}. Kept as a sibling module in this
  # file (not a separate public API) so the options class stays under RuboCop's
  # +Metrics/ClassLength+ budget.
  module CpfFormatterOptionProperties
    # @return [Boolean]
    def hidden
      @options[:hidden]
    end

    # Sets whether hidden digit replacement is enabled. +nil+ is not accepted:
    # pass {CpfFormatterOptions::DEFAULT_HIDDEN} to reset explicitly.
    #
    # @param value [Boolean] enable masking when truthy
    # @raise [TypeMismatchError] if the value is +nil+
    def hidden=(value)
      raise TypeMismatchError.new(value, 'boolean', option_name: 'hidden') if value.nil?

      @options[:hidden] = Utils.normalize_boolean(value)
    end

    # @return [String]
    def hidden_key
      @options[:hidden_key]
    end

    # Sets the string used to replace hidden CPF digits. +nil+ is not accepted:
    # pass {CpfFormatterOptions::DEFAULT_HIDDEN_KEY} to reset explicitly.
    #
    # @param value [String] replacement string
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value contains any disallowed key character
    def hidden_key=(value)
      assign_string_key_option('hidden_key', value)
    end

    # @return [Integer]
    def hidden_start
      @options[:hidden_start]
    end

    # Sets the start index for hiding CPF digits. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_HIDDEN_START} to reset explicitly.
    #
    # @param value [Integer] start index
    # @raise [TypeMismatchError] if the value is not an integer
    # @raise [OutOfRangeError] if the value is out of valid range
    def hidden_start=(value)
      set_hidden_range(value, @options[:hidden_end])
    end

    # @return [Integer]
    def hidden_end
      @options[:hidden_end]
    end

    # Sets the end index for hiding CPF digits. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_HIDDEN_END} to reset explicitly.
    #
    # @param value [Integer] end index
    # @raise [TypeMismatchError] if the value is not an integer
    # @raise [OutOfRangeError] if the value is out of valid range
    def hidden_end=(value)
      set_hidden_range(@options[:hidden_start], value)
    end

    # @return [String]
    def dot_key
      @options[:dot_key]
    end

    # Sets the dot delimiter. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_DOT_KEY} to reset explicitly.
    #
    # @param value [String] delimiter string
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value contains any disallowed key character
    def dot_key=(value)
      assign_string_key_option('dot_key', value)
    end

    # @return [String]
    def dash_key
      @options[:dash_key]
    end

    # Sets the dash delimiter. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_DASH_KEY} to reset explicitly.
    #
    # @param value [String] delimiter string
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value contains any disallowed key character
    def dash_key=(value)
      assign_string_key_option('dash_key', value)
    end

    # @return [Boolean]
    def escape
      @options[:escape]
    end

    # Sets whether HTML escaping is enabled. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_ESCAPE} to reset explicitly.
    #
    # @param value [Boolean] enable escaping when truthy
    # @raise [TypeMismatchError] if the value is +nil+
    def escape=(value)
      raise TypeMismatchError.new(value, 'boolean', option_name: 'escape') if value.nil?

      @options[:escape] = Utils.normalize_boolean(value)
    end

    # @return [Boolean]
    def encode
      @options[:encode]
    end

    # Sets whether URL encoding is enabled. +nil+ is not accepted: pass
    # {CpfFormatterOptions::DEFAULT_ENCODE} to reset explicitly.
    #
    # @param value [Boolean] enable encoding when truthy
    # @raise [TypeMismatchError] if the value is +nil+
    def encode=(value)
      raise TypeMismatchError.new(value, 'boolean', option_name: 'encode') if value.nil?

      @options[:encode] = Utils.normalize_boolean(value)
    end

    # @return [Proc] failure callback
    def on_fail
      @options[:on_fail]
    end

    # Sets the callback executed when formatting fails. +nil+ is not accepted:
    # pass {CpfFormatterOptions::DEFAULT_ON_FAIL} to reset explicitly.
    #
    # @param value [Proc] callback
    # @raise [TypeMismatchError] if the value is not callable
    def on_fail=(value)
      raise TypeMismatchError.new(value, 'function', option_name: 'on_fail') unless value.respond_to?(:call)

      @options[:on_fail] = value
    end
  end

  # Stores configuration for the CPF formatter.
  #
  # Provides a centralized way to configure how CPF numbers are formatted,
  # including delimiters, hidden digit ranges, HTML escaping, URL encoding,
  # and error handling callbacks.
  class CpfFormatterOptions
    include FormatterOptionsResolution
    include CpfFormatterOptionProperties

    # The standard length of a CPF (Cadastro de Pessoas Físicas) identifier
    # (11 digits).
    CPF_LENGTH = 11

    # Minimum valid index for the hidden range (inclusive). Must be between 0 and
    # {CPF_LENGTH} - 1.
    MIN_HIDDEN_RANGE = 0

    # Maximum valid index for the hidden range (inclusive). Must be between 0 and
    # {CPF_LENGTH} - 1.
    MAX_HIDDEN_RANGE = CPF_LENGTH - 1

    # Default value for the +hidden+ option. When +false+, all CPF digits are
    # displayed.
    DEFAULT_HIDDEN = false

    # Default string used to replace hidden CPF digits.
    DEFAULT_HIDDEN_KEY = '*'

    # Default start index (inclusive) for hiding CPF digits. Digits from this
    # index onwards will be replaced with the +hidden_key+ value.
    DEFAULT_HIDDEN_START = 3

    # Default end index (inclusive) for hiding CPF digits. Digits up to and
    # including this index will be replaced with the +hidden_key+ value.
    DEFAULT_HIDDEN_END = 10

    # Default string used as the dot delimiter in formatted CPF. Used to separate
    # the first groups of digits (+XXX.XXX.XXX+).
    DEFAULT_DOT_KEY = '.'

    # Default string used as the dash delimiter in formatted CPF. Used to
    # separate the first group of digits from the check digits at the end
    # (+XXXX-XX+).
    DEFAULT_DASH_KEY = '-'

    # Default value for the +escape+ option. When +false+, HTML special characters
    # are not escaped.
    DEFAULT_ESCAPE = false

    # Default value for the +encode+ option. When +false+, the CPF string is not
    # URL-encoded.
    DEFAULT_ENCODE = false

    # Characters that are not allowed in key options (+hidden_key+, +dot_key+,
    # +dash_key+). They are reserved for internal formatting logic.
    #
    # For now, the first character is only used to replace the hidden key
    # placeholder in {CpfFormatter}. However, this set of characters is reserved
    # for future use already.
    DISALLOWED_KEY_CHARACTERS = %w[å ë ï ö].freeze

    # Option keys managed by this class, in assignment order.
    OPTION_KEYS = FORMATTER_OPTION_KEYS

    # The +hidden_start+/+hidden_end+ pair is resolved and assigned together (via
    # {#set_hidden_range}) because their validation (range + swap) is coupled.
    RANGE_OPTION_KEYS = %i[hidden_start hidden_end].freeze

    # Every option key except {RANGE_OPTION_KEYS}, each assignable independently
    # through its own property setter.
    SIMPLE_OPTION_KEYS = (OPTION_KEYS - RANGE_OPTION_KEYS).freeze

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

    # Default value for each key in {OPTION_KEYS}, used to fill any option that is
    # still unresolved once {#initialize} finishes merging its arguments.
    DEFAULTS = {
      hidden: DEFAULT_HIDDEN,
      hidden_key: DEFAULT_HIDDEN_KEY,
      hidden_start: DEFAULT_HIDDEN_START,
      hidden_end: DEFAULT_HIDDEN_END,
      dot_key: DEFAULT_DOT_KEY,
      dash_key: DEFAULT_DASH_KEY,
      escape: DEFAULT_ESCAPE,
      encode: DEFAULT_ENCODE,
      on_fail: DEFAULT_ON_FAIL
    }.freeze

    # Creates a new {CpfFormatterOptions} instance.
    #
    # Options are resolved in three steps. Each step only overrides a key when it
    # is given a non-+nil+ value; a +nil+ is always ignored in favor of whatever
    # was resolved by a previous step.
    #
    # 1. Every positional +options+ layer (each either a {Hash} or another
    #    {CpfFormatterOptions} instance) is folded left to right, so later layers
    #    take precedence over earlier ones.
    # 2. The keyword arguments are then applied on top of the folded layers.
    #    Keywords always have the highest precedence, overriding every positional
    #    layer.
    # 3. Any option that is still unresolved after steps 1 and 2 is assigned its
    #    +DEFAULT_*+ value (see {DEFAULTS}).
    #
    # Because every option is fully resolved to a concrete, non-+nil+ value before
    # assignment, the individual property setters (e.g. {#hidden=}) never receive
    # +nil+ from this method — they always raise if given +nil+ directly.
    #
    # @param options [Array<CpfFormatterOptions, Hash>] option layers merged in
    #   order (later layers win); a missing or +nil+ value for a key inside a
    #   layer is ignored and the previously resolved value is kept
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key option contains a disallowed character
    def initialize(*options, **keywords)
      @options = {}

      resolved = fold_layers(options)
      apply_keyword_overrides(resolved, keywords)
      assign_resolved_or_default(resolved)
    end

    # Sets +hidden_start+ and +hidden_end+ with validation.
    #
    # Validates that both indices are integers within the valid range
    # +[0, CPF_LENGTH - 1]+. If +hidden_start > hidden_end+, the values are
    # automatically swapped to ensure a valid range. This method is used internally
    # to keep both bounds consistent whenever either one changes.
    #
    # Neither argument accepts +nil+: pass the current or default value explicitly
    # if only the other bound is changing.
    #
    # @param hidden_start [Integer] inclusive start index (0–10)
    # @param hidden_end [Integer] inclusive end index (0–10)
    # @return [CpfFormatterOptions] +self+
    # @raise [TypeMismatchError] if either value is not an integer
    # @raise [OutOfRangeError] if either value is out of valid range +[0, CPF_LENGTH - 1]+
    def set_hidden_range(hidden_start, hidden_end)
      start_index, end_index = Utils.normalize_hidden_range(
        hidden_start,
        hidden_end,
        MIN_HIDDEN_RANGE,
        MAX_HIDDEN_RANGE
      )
      @options[:hidden_start] = start_index
      @options[:hidden_end] = end_index
      self
    end

    # Returns a shallow copy of this options instance.
    #
    # @return [CpfFormatterOptions] duplicated options for per-call merging
    def copy
      duplicate = self.class.allocate
      duplicate.instance_variable_set(:@options, @options.dup)
      duplicate
    end

    # Sets multiple options at once, following the same layered-override
    # semantics as {#initialize} (positional layers folded left to right, then
    # keyword arguments applied with the highest precedence; +nil+ is always
    # ignored). Unlike {#initialize}, any option that is still unresolved after
    # merging keeps its **current** value on this instance instead of falling
    # back to its default — this method performs a partial update, not a
    # re-initialization.
    #
    # @param options [Array<CpfFormatterOptions, Hash>] option layers merged in
    #   order (later layers win)
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @return [CpfFormatterOptions] +self+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [OutOfRangeError] if +hidden_start+ or +hidden_end+ are out of valid range
    # @raise [ValidationError] if any key option contains a disallowed character
    def set(*options, **keywords)
      resolved = fold_layers(options)
      apply_keyword_overrides(resolved, keywords)
      assign_resolved_keeping_current(resolved)
      self
    end

    # Returns a shallow copy of all current options.
    #
    # @return [Hash{Symbol => Object}] shallow copy of option values
    def all
      @options.dup
    end
  end
end
