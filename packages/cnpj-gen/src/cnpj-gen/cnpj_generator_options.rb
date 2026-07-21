# frozen_string_literal: true

require_relative 'types'

module CnpjGen
  # Layered option-resolution helpers for {CnpjGeneratorOptions}.
  module GeneratorOptionsResolution
    private

    def fold_layers(layers)
      resolved = {}

      layers.each do |layer|
        source = layer_source(layer)
        next if source.nil?

        CnpjGeneratorOptions::OPTION_KEYS.each do |key|
          value = Utils.fetch_option(source, key)
          resolved[key] = value unless value.nil?
        end
      end

      resolved
    end

    def layer_source(layer)
      return layer.all if layer.is_a?(CnpjGeneratorOptions)
      return layer if layer.is_a?(Hash)

      nil
    end

    def apply_keyword_overrides(resolved, keywords)
      CnpjGeneratorOptions::OPTION_KEYS.each do |key|
        value = keywords[key]
        resolved[key] = value unless value.nil?
      end
    end

    def assign_resolved_or_default(resolved)
      CnpjGeneratorOptions::OPTION_KEYS.each do |key|
        value = resolved.key?(key) ? resolved[key] : CnpjGeneratorOptions::DEFAULTS[key]
        public_send("#{key}=", value)
      end
    end
  end

  # Property accessors for {CnpjGeneratorOptions}. Kept as a sibling module in this
  # file (not a separate public API) so the options class stays under RuboCop's
  # +Metrics/ClassLength+ budget.
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
    # +nil+ is not accepted: pass {CnpjGeneratorOptions::DEFAULT_FORMAT} explicitly
    # to reset this option to its default value.
    #
    # @param value [Boolean] enable formatting when truthy
    # @raise [TypeMismatchError] if the value is +nil+
    def format=(value)
      raise TypeMismatchError.new(value, 'boolean', option_name: 'format') if value.nil?

      @options[:format] = Utils.normalize_boolean(value)
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
    # +nil+ is not accepted: pass {CnpjGeneratorOptions::DEFAULT_PREFIX} explicitly
    # to reset this option to its default value.
    #
    # @param value [String] partial start string
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if +prefix+ is invalid
    def prefix=(value)
      actual_prefix = Utils.sanitize_prefix(value)

      Utils.validate_prefix!(actual_prefix)

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
    # +nil+ is not accepted: pass {CnpjGeneratorOptions::DEFAULT_TYPE} explicitly
    # to reset this option to its default value.
    #
    # @param value [String] one of {CNPJ_TYPE_VALUES}
    # @raise [TypeMismatchError] if the value is not a +String+
    # @raise [ValidationError] if the value is not allowed
    def type=(value)
      Utils.assert_string_option!('type', value)

      unless CNPJ_TYPE_VALUES.include?(value)
        raise ValidationError.new('type', value, expected_values: CNPJ_TYPE_OPTIONS_ORDER)
      end

      @options[:type] = value
    end
  end

  # Stores configuration for the CNPJ generator.
  #
  # Provides a centralized way to configure how CNPJ characters are generated,
  # including partial start string (+prefix+), formatting (+format+), and the type
  # of characters to be generated (+numeric+, +alphabetic+, or +alphanumeric+).
  class CnpjGeneratorOptions
    include GeneratorOptionsResolution
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

    # Option keys managed by this class, in assignment order.
    OPTION_KEYS = %i[format prefix type].freeze

    # Default value for each key in {OPTION_KEYS}, used to fill any option that
    # is still unresolved once {#initialize} finishes merging its arguments.
    DEFAULTS = {
      format: DEFAULT_FORMAT,
      prefix: DEFAULT_PREFIX,
      type: DEFAULT_TYPE
    }.freeze

    # Creates a new {CnpjGeneratorOptions} instance.
    #
    # Options are resolved in three steps. Each step only overrides a key when it
    # is given a non-+nil+ value; a +nil+ is always ignored in favor of whatever
    # was resolved by a previous step.
    #
    # 1. Every positional +options+ layer (each either a {Hash} or another
    #    {CnpjGeneratorOptions} instance) is folded left to right, so later
    #    layers take precedence over earlier ones.
    # 2. The +format+, +prefix+, and +type+ keyword arguments are then applied on
    #    top of the folded layers. Keywords always have the highest precedence,
    #    overriding every positional layer.
    # 3. Any option that is still unresolved after steps 1 and 2 is assigned its
    #    +DEFAULT_*+ value (see {DEFAULTS}).
    #
    # Because every option is fully resolved to a concrete, non-+nil+ value
    # before assignment, the individual property setters (e.g. {#format=}) never
    # receive +nil+ from this method — they always raise if given +nil+ directly.
    #
    # @param options [Array<CnpjGeneratorOptions, Hash>] option layers merged in
    #   order (later layers win); a missing or +nil+ value for a key inside a
    #   layer is ignored and the previously resolved value is kept
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
    def initialize(*options, **keywords)
      @options = {}

      resolved = fold_layers(options)
      apply_keyword_overrides(resolved, keywords)
      assign_resolved_or_default(resolved)
    end

    # Sets multiple options at once, following the same layered-override
    # semantics as {#initialize} (positional layers folded left to right, then
    # keyword arguments applied with the highest precedence; +nil+ is always
    # ignored). Unlike {#initialize}, any option that is still unresolved after
    # merging keeps its **current** value on this instance instead of falling
    # back to its default — this method performs a partial update, not a
    # re-initialization.
    #
    # @param options [Array<CnpjGeneratorOptions, Hash>] option layers merged in
    #   order (later layers win)
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @return [CnpjGeneratorOptions] +self+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
    def set(*options, **keywords)
      resolved = fold_layers(options)
      apply_keyword_overrides(resolved, keywords)
      resolved.each { |key, value| public_send("#{key}=", value) }
      self
    end

    # Returns a shallow copy of this options instance.
    #
    # @return [CnpjGeneratorOptions] duplicated options for per-call merging
    def copy
      duplicate = self.class.allocate
      duplicate.instance_variable_set(:@options, @options.dup)
      duplicate
    end
  end
end
