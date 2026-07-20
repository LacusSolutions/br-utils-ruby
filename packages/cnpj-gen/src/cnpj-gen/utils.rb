# frozen_string_literal: true

module CnpjGen
  # Low-level helpers used by {CnpjGenerator} and {CnpjGeneratorOptions}.
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

      sanitized = value.gsub(CnpjGeneratorOptions::PREFIX_SANITIZE_PATTERN, '').upcase
      sanitized[0, CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH]
    end

    def validate_prefix!(partial_cnpj)
      validate_prefix_base_id!(partial_cnpj)
      validate_prefix_branch_id!(partial_cnpj)
      validate_prefix_non_repeated_digits!(partial_cnpj)
    end

    def validate_prefix_base_id!(partial_cnpj)
      return if partial_cnpj.length < CnpjGeneratorOptions::CNPJ_BASE_ID_LENGTH

      cnpj_base_id = partial_cnpj[0, CnpjGeneratorOptions::CNPJ_BASE_ID_LAST_INDEX + 1]

      return unless cnpj_base_id == CnpjGeneratorOptions::ZEROED_CNPJ_BASE_ID

      raise ValidationError.new(
        'prefix',
        partial_cnpj,
        reason: 'Zeroed base ID is not eligible.'
      )
    end

    def validate_prefix_branch_id!(partial_cnpj)
      minimum_length = CnpjGeneratorOptions::CNPJ_BASE_ID_LENGTH + CnpjGeneratorOptions::CNPJ_BRANCH_ID_LENGTH
      branch_id = partial_cnpj[CnpjGeneratorOptions::CNPJ_BASE_ID_LENGTH, CnpjGeneratorOptions::CNPJ_BRANCH_ID_LENGTH]

      return if partial_cnpj.length < minimum_length
      return unless branch_id == CnpjGeneratorOptions::ZEROED_CNPJ_BRANCH_ID

      raise ValidationError.new(
        'prefix',
        partial_cnpj,
        reason: 'Zeroed branch ID is not eligible.'
      )
    end

    def validate_prefix_non_repeated_digits!(cnpj_prefix)
      return if cnpj_prefix.length < CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH

      first_character = cnpj_prefix[0]

      return unless first_character.match?(/\A\d\z/)
      return unless cnpj_prefix == first_character * CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH

      raise ValidationError.new(
        'prefix',
        cnpj_prefix,
        reason: 'Repeated digits are not considered valid.'
      )
    end

    # Formats a raw 14-character CNPJ into the standard masked representation.
    def format_cnpj(raw)
      "#{raw[0, 2]}.#{raw[2, 3]}.#{raw[5, 3]}/#{raw[8, 4]}-#{raw[12, 2]}"
    end
  end
end
