# frozen_string_literal: true

require_relative 'types'
require_relative 'exceptions'

module CnpjGen
  # Internal validation helpers for {CnpjGeneratorOptions}.
  module GeneratorOptionsValidation
    module_function

    # rubocop:disable Naming/PredicateMethod -- coercion helper, not a predicate query
    def normalize_boolean(value)
      return false if [false, '', 0].include?(value)

      !!value
    end
    # rubocop:enable Naming/PredicateMethod

    def assert_string_option!(option_name, value)
      return if value.is_a?(String)

      raise CnpjGeneratorOptionsTypeError.new(option_name, value, 'string')
    end

    def fetch_option(source, key)
      return source[key] if source.key?(key)
      return source[key.to_s] if source.key?(key.to_s)

      nil
    end

    def sanitize_prefix(value)
      actual_prefix = value.nil? ? CnpjGeneratorOptions::DEFAULT_PREFIX : value

      assert_string_option!('prefix', actual_prefix)

      actual_prefix = actual_prefix.gsub(CnpjGeneratorOptions::PREFIX_SANITIZE_PATTERN, '').upcase
      actual_prefix[0, CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH]
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

      raise CnpjGeneratorOptionPrefixInvalidException.new(
        partial_cnpj,
        'Zeroed base ID is not eligible.'
      )
    end

    def validate_prefix_branch_id!(partial_cnpj)
      minimum_length = CnpjGeneratorOptions::CNPJ_BASE_ID_LENGTH + CnpjGeneratorOptions::CNPJ_BRANCH_ID_LENGTH
      branch_id = partial_cnpj[CnpjGeneratorOptions::CNPJ_BASE_ID_LENGTH, CnpjGeneratorOptions::CNPJ_BRANCH_ID_LENGTH]

      return if partial_cnpj.length < minimum_length
      return unless branch_id == CnpjGeneratorOptions::ZEROED_CNPJ_BRANCH_ID

      raise CnpjGeneratorOptionPrefixInvalidException.new(
        partial_cnpj,
        'Zeroed branch ID is not eligible.'
      )
    end

    def validate_prefix_non_repeated_digits!(cnpj_prefix)
      return if cnpj_prefix.length < CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH

      first_character = cnpj_prefix[0]

      return unless first_character.match?(/\A\d\z/)
      return unless cnpj_prefix == first_character * CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH

      raise CnpjGeneratorOptionPrefixInvalidException.new(
        cnpj_prefix,
        'Repeated digits are not considered valid.'
      )
    end
  end
end
