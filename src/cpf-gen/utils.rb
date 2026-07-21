# frozen_string_literal: true

module CpfGen
  # Low-level helpers used by {CpfGenerator} and {CpfGeneratorOptions}.
  #
  # @api private
  module Utils
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

    def fetch_option(source, key)
      return source[key] if source.key?(key)
      return source[key.to_s] if source.key?(key.to_s)

      nil
    end

    def sanitize_prefix(value)
      assert_string_option!('prefix', value)

      sanitized = value.gsub(CpfGeneratorOptions::PREFIX_SANITIZE_PATTERN, '')
      sanitized[0, CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH]
    end

    def validate_prefix!(partial_cpf)
      validate_prefix_base_id!(partial_cpf)
      validate_prefix_non_repeated_digits!(partial_cpf)
    end

    def validate_prefix_base_id!(partial_cpf)
      return if partial_cpf.length < CpfGeneratorOptions::CPF_BASE_ID_LENGTH

      cpf_base_id = partial_cpf[0, CpfGeneratorOptions::CPF_BASE_ID_LAST_INDEX + 1]

      return unless cpf_base_id == CpfGeneratorOptions::ZEROED_CPF_BASE_ID

      raise ValidationError.new(
        'prefix',
        partial_cpf,
        reason: 'Zeroed base ID is not eligible.'
      )
    end

    def validate_prefix_non_repeated_digits!(partial_cpf)
      return if partial_cpf.length < CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH

      first_character = partial_cpf[0]

      return unless partial_cpf == first_character * CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH

      raise ValidationError.new(
        'prefix',
        partial_cpf,
        reason: 'Repeated digits are not considered valid.'
      )
    end

    # Formats a raw 11-digit CPF into the standard masked representation.
    def format_cpf(raw)
      "#{raw[0, 3]}.#{raw[3, 3]}.#{raw[6, 3]}-#{raw[9, 2]}"
    end
  end
end
