# frozen_string_literal: true

require_relative 'types'

module CpfGen
  # Layered option-resolution helpers for {CpfGeneratorOptions}.
  module GeneratorOptionsResolution
    private

    def fold_layers(layers)
      resolved = {}

      layers.each do |layer|
        source = layer_source(layer)
        next if source.nil?

        CpfGeneratorOptions::OPTION_KEYS.each do |key|
          value = Utils.fetch_option(source, key)
          resolved[key] = value unless value.nil?
        end
      end

      resolved
    end

    def layer_source(layer)
      return layer.all if layer.is_a?(CpfGeneratorOptions)
      return layer if layer.is_a?(Hash)

      nil
    end

    def apply_keyword_overrides(resolved, keywords)
      CpfGeneratorOptions::OPTION_KEYS.each do |key|
        value = keywords[key]
        resolved[key] = value unless value.nil?
      end
    end

    def assign_resolved_or_default(resolved)
      CpfGeneratorOptions::OPTION_KEYS.each do |key|
        value = resolved.key?(key) ? resolved[key] : CpfGeneratorOptions::DEFAULTS[key]
        public_send("#{key}=", value)
      end
    end
  end

  # Property accessors for {CpfGeneratorOptions}. Kept as a sibling module in this
  # file (not a separate public API) so the options class stays under RuboCop's
  # +Metrics/ClassLength+ budget.
  module CpfGeneratorOptionProperties
    # Returns a shallow copy of all current options.
    #
    # Exposes resolved +format+ and +prefix+ values. This is useful for creating
    # snapshots of the current configuration.
    #
    # @return [Hash{Symbol => Object}] shallow copy of option values
    def all
      @options.dup
    end

    # Returns whether the generated CPF string will have the standard formatting
    # (+000.000.000-00+).
    #
    # @return [Boolean]
    def format
      @options[:format]
    end

    # Sets whether the generated CPF string will have the standard formatting
    # (+000.000.000-00+). The value is converted to a boolean, so truthy/falsy
    # values are handled appropriately.
    #
    # +nil+ is not accepted: pass {CpfGeneratorOptions::DEFAULT_FORMAT} explicitly
    # to reset this option to its default value.
    #
    # @param value [Boolean] enable formatting when truthy
    # @raise [TypeMismatchError] if the value is +nil+
    def format=(value)
      raise TypeMismatchError.new(value, 'boolean', option_name: 'format') if value.nil?

      @options[:format] = Utils.normalize_boolean(value)
    end

    # Returns the string used as the initial string of the generated CPF.
    #
    # Note: If the evaluated +prefix+ (after stripping non-digit characters) is
    # longer than 9 digits, the extra digits are ignored, because a CPF has 9
    # base digits followed by 2 calculated check digits.
    #
    # @return [String]
    def prefix
      @options[:prefix]
    end

    # Sets the string used as the initial string of the generated CPF. Only
    # digits are kept and the rest is stripped. If provided, only the missing
    # digits are generated randomly. For example, if the +prefix+ +"123456"+ (6
    # digits) is given, only the next 3 digits are randomly generated and
    # concatenated to the +prefix+.
    #
    # Note: If the evaluated +prefix+ (after stripping non-digit characters) is
    # longer than 9 digits, the extra digits are ignored, because a CPF has 9
    # base digits followed by 2 calculated check digits.
    #
    # +nil+ is not accepted: pass {CpfGeneratorOptions::DEFAULT_PREFIX} explicitly
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
  end

  # Stores configuration for the CPF generator.
  #
  # Provides a centralized way to configure how CPF digits are generated,
  # including partial start string (+prefix+) and formatting (+format+).
  class CpfGeneratorOptions
    include GeneratorOptionsResolution
    include CpfGeneratorOptionProperties

    # The standard length of a CPF (Cadastro de Pessoa Física) identifier (11
    # digits).
    CPF_LENGTH = 11

    # Maximum length of the +prefix+ of a CPF.
    CPF_PREFIX_MAX_LENGTH = CPF_LENGTH - 2

    # Default value for the +format+ option. When +true+, the generated CPF
    # string will have the standard formatting (+000.000.000-00+).
    DEFAULT_FORMAT = false

    # Default string used as the initial string of the generated CPF.
    DEFAULT_PREFIX = ''

    CPF_BASE_ID_LENGTH = 9
    CPF_BASE_ID_LAST_INDEX = CPF_BASE_ID_LENGTH - 1
    ZEROED_CPF_BASE_ID = '0' * CPF_BASE_ID_LENGTH

    PREFIX_SANITIZE_PATTERN = /\D/

    # Option keys managed by this class, in assignment order.
    OPTION_KEYS = %i[format prefix].freeze

    # Default value for each key in {OPTION_KEYS}, used to fill any option that
    # is still unresolved once {#initialize} finishes merging its arguments.
    DEFAULTS = {
      format: DEFAULT_FORMAT,
      prefix: DEFAULT_PREFIX
    }.freeze

    # Creates a new {CpfGeneratorOptions} instance.
    #
    # Options are resolved in three steps. Each step only overrides a key when it
    # is given a non-+nil+ value; a +nil+ is always ignored in favor of whatever
    # was resolved by a previous step.
    #
    # 1. Every positional +options+ layer (each either a {Hash} or another
    #    {CpfGeneratorOptions} instance) is folded left to right, so later
    #    layers take precedence over earlier ones.
    # 2. The +format+ and +prefix+ keyword arguments are then applied on top of
    #    the folded layers. Keywords always have the highest precedence,
    #    overriding every positional layer.
    # 3. Any option that is still unresolved after steps 1 and 2 is assigned its
    #    +DEFAULT_*+ value (see {DEFAULTS}).
    #
    # Because every option is fully resolved to a concrete, non-+nil+ value
    # before assignment, the individual property setters (e.g. {#format=}) never
    # receive +nil+ from this method — they always raise if given +nil+ directly.
    #
    # @param options [Array<CpfGeneratorOptions, Hash>] option layers merged in
    #   order (later layers win); a missing or +nil+ value for a key inside a
    #   layer is ignored and the previously resolved value is kept
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid
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
    # @param options [Array<CpfGeneratorOptions, Hash>] option layers merged in
    #   order (later layers win)
    # @param keywords [Hash] highest-precedence option overrides (see {OPTION_KEYS})
    # @return [CpfGeneratorOptions] +self+
    # @raise [TypeMismatchError] if any option has an invalid type
    # @raise [ValidationError] if +prefix+ is invalid
    def set(*options, **keywords)
      resolved = fold_layers(options)
      apply_keyword_overrides(resolved, keywords)
      resolved.each { |key, value| public_send("#{key}=", value) }
      self
    end

    # Returns a shallow copy of this options instance.
    #
    # @return [CpfGeneratorOptions] duplicated options for per-call merging
    def copy
      duplicate = self.class.allocate
      duplicate.instance_variable_set(:@options, @options.dup)
      duplicate
    end
  end
end
