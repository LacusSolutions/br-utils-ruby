# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfGen::Utils do
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
      expect { described_class.assert_string_option!('prefix', '123') }.not_to raise_error
    end

    it 'raises TypeMismatchError for a non-string' do
      expect { described_class.assert_string_option!('prefix', 1) }
        .to raise_error(CpfGen::TypeMismatchError)
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
    it 'strips non-digit characters' do
      expect(described_class.sanitize_prefix('ABC.123.DEF.456')).to eq('123456')
    end

    it 'truncates to the maximum prefix length' do
      long_prefix = '1' * 20

      expect(described_class.sanitize_prefix(long_prefix).length)
        .to eq(CpfGen::CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH)
    end

    it 'raises TypeMismatchError for a non-string' do
      expect { described_class.sanitize_prefix(123) }
        .to raise_error(CpfGen::TypeMismatchError)
    end
  end

  describe '.validate_prefix!' do
    it 'accepts a valid partial prefix' do
      expect { described_class.validate_prefix!('123456') }.not_to raise_error
    end

    it 'accepts eight zeros as a partial prefix' do
      expect { described_class.validate_prefix!('00000000') }.not_to raise_error
    end

    it 'raises when the base ID is zeroed' do
      expect { described_class.validate_prefix!('000000000') }
        .to raise_error(CpfGen::ValidationError, /Zeroed base ID/)
    end

    it 'raises when the full prefix is repeated digits' do
      expect { described_class.validate_prefix!('111111111') }
        .to raise_error(CpfGen::ValidationError, /Repeated digits/)
    end
  end

  describe '.format_cpf' do
    it 'inserts the standard CPF delimiters' do
      expect(described_class.format_cpf('47844241055')).to eq('478.442.410-55')
    end
  end
end
