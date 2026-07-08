# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjDV do
  context 'when inspecting constants' do
    it 'exposes CNPJ_MIN_LENGTH as 12' do
      expect(described_class::CNPJ_MIN_LENGTH).to eq(12)
    end

    it 'exposes CNPJ_MAX_LENGTH as 14' do
      expect(described_class::CNPJ_MAX_LENGTH).to eq(14)
    end
  end

  context 'when inspecting public constants' do
    it 'defines CnpjCheckDigits' do
      expect(described_class.const_defined?(:CnpjCheckDigits)).to be(true)
    end

    it 'defines CnpjCheckDigitsTypeError' do
      expect(described_class.const_defined?(:CnpjCheckDigitsTypeError)).to be(true)
    end

    it 'defines CnpjCheckDigitsInputTypeError' do
      expect(described_class.const_defined?(:CnpjCheckDigitsInputTypeError)).to be(true)
    end

    it 'defines CnpjCheckDigitsException' do
      expect(described_class.const_defined?(:CnpjCheckDigitsException)).to be(true)
    end

    it 'defines CnpjCheckDigitsInputInvalidException' do
      expect(described_class.const_defined?(:CnpjCheckDigitsInputInvalidException)).to be(true)
    end

    it 'defines CnpjCheckDigitsInputLengthException' do
      expect(described_class.const_defined?(:CnpjCheckDigitsInputLengthException)).to be(true)
    end
  end

  context 'when inspecting public types' do
    it 'exposes an instantiable CnpjCheckDigits' do
      instance = described_class::CnpjCheckDigits.new('914157320007')

      aggregate_failures do
        expect(instance).to be_a(described_class::CnpjCheckDigits)
        expect(instance.first).to eq('9')
        expect(instance.second).to eq('3')
        expect(instance.cnpj).to eq('91415732000793')
      end
    end

    it 'exposes CnpjCheckDigitsTypeError as a TypeError' do
      expect(described_class::CnpjCheckDigitsTypeError < TypeError).to be(true)
    end

    it 'exposes instantiable InputTypeError' do
      instance = described_class::CnpjCheckDigitsInputTypeError.new(123, 'string')

      aggregate_failures do
        expect(instance.actual_input).to eq(123)
        expect(instance.message).to eq(
          'CNPJ input must be of type string. Got integer number.'
        )
      end
    end

    it 'exposes CnpjCheckDigitsException as StandardError' do
      expect(described_class::CnpjCheckDigitsException < StandardError).to be(true)
    end

    it 'exposes instantiable InputInvalidException' do
      instance = described_class::CnpjCheckDigitsInputInvalidException.new(
        '123',
        'some reason'
      )

      aggregate_failures do
        expect(instance.actual_input).to eq('123')
        expect(instance.reason).to eq('some reason')
        expect(instance.message).to eq('CNPJ input "123" is invalid. some reason')
      end
    end

    it 'exposes instantiable InputLengthException' do
      instance = described_class::CnpjCheckDigitsInputLengthException.new('x', '1', 12, 14)

      aggregate_failures do
        expect(instance.min_expected_length).to eq(12)
        expect(instance.max_expected_length).to eq(14)
      end
    end
  end
end
