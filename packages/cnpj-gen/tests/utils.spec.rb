# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjGen::Utils do
  describe '.normalize_boolean' do
    it 'returns false for false, empty string, and zero' do
      aggregate_failures do
        expect(described_class.normalize_boolean(false)).to be(false)
        expect(described_class.normalize_boolean('')).to be(false)
        expect(described_class.normalize_boolean(0)).to be(false)
      end
    end

    it 'returns true for other truthy values' do
      aggregate_failures do
        expect(described_class.normalize_boolean(true)).to be(true)
        expect(described_class.normalize_boolean('yes')).to be(true)
        expect(described_class.normalize_boolean(1)).to be(true)
      end
    end
  end

  describe '.assert_string_option!' do
    it 'accepts a string' do
      expect { described_class.assert_string_option!('prefix', 'ABC') }.not_to raise_error
    end

    it 'raises TypeMismatchError for a non-string' do
      expect { described_class.assert_string_option!('prefix', 1) }
        .to raise_error(CnpjGen::TypeMismatchError)
    end
  end

  describe '.fetch_option' do
    it 'reads a symbol key' do
      expect(described_class.fetch_option({ format: true }, :format)).to be(true)
    end

    it 'reads a string key' do
      expect(described_class.fetch_option({ 'format' => true }, :format)).to be(true)
    end

    it 'returns nil when the key is absent' do
      expect(described_class.fetch_option({}, :format)).to be_nil
    end
  end

  describe '.sanitize_prefix' do
    it 'strips non-alphanumeric characters and uppercases letters' do
      expect(described_class.sanitize_prefix('ab-12.cd')).to eq('AB12CD')
    end

    it 'truncates to the maximum prefix length' do
      long_prefix = 'A' * 20

      expect(described_class.sanitize_prefix(long_prefix).length)
        .to eq(CnpjGen::CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH)
    end

    it 'raises TypeMismatchError for a non-string' do
      expect { described_class.sanitize_prefix(123) }
        .to raise_error(CnpjGen::TypeMismatchError)
    end
  end

  describe '.validate_prefix!' do
    it 'accepts a valid partial prefix' do
      expect { described_class.validate_prefix!('ABC123') }.not_to raise_error
    end

    it 'raises when the base ID is zeroed' do
      expect { described_class.validate_prefix!('00000000') }
        .to raise_error(CnpjGen::ValidationError, /Zeroed base ID/)
    end

    it 'raises when the branch ID is zeroed' do
      expect { described_class.validate_prefix!('123456780000') }
        .to raise_error(CnpjGen::ValidationError, /Zeroed branch ID/)
    end

    it 'raises when the full prefix is repeated digits' do
      expect { described_class.validate_prefix!('111111111111') }
        .to raise_error(
          CnpjGen::ValidationError,
          /Repeated digits/
        )
    end

    it 'accepts a full prefix of repeated letters' do
      expect { described_class.validate_prefix!('AAAAAAAAAAAA') }.not_to raise_error
    end
  end

  describe '.format_cnpj' do
    it 'inserts the standard CNPJ delimiters' do
      expect(described_class.format_cnpj('12345678000195')).to eq('12.345.678/0001-95')
    end
  end
end
