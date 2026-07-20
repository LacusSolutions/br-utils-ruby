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

    it 'defines Error' do
      expect(described_class.const_defined?(:Error)).to be(true)
    end

    it 'defines TypeMismatchError' do
      expect(described_class.const_defined?(:TypeMismatchError)).to be(true)
    end

    it 'defines DomainError' do
      expect(described_class.const_defined?(:DomainError)).to be(true)
    end

    it 'defines InvalidLengthError' do
      expect(described_class.const_defined?(:InvalidLengthError)).to be(true)
    end

    it 'defines ValidationError' do
      expect(described_class.const_defined?(:ValidationError)).to be(true)
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

    it 'exposes TypeMismatchError as a TypeError' do
      expect(described_class::TypeMismatchError < TypeError).to be(true)
    end

    it 'exposes instantiable TypeMismatchError' do
      instance = described_class::TypeMismatchError.new(123, 'string')

      aggregate_failures do
        expect(instance.actual_input).to eq(123)
        expect(instance).to be_a(described_class::Error)
        expect(instance.message).to eq(
          'CNPJ input must be of type string. Got integer number.'
        )
      end
    end

    it 'exposes DomainError as a RangeError' do
      expect(described_class::DomainError < RangeError).to be(true)
    end

    it 'exposes instantiable InvalidLengthError' do
      instance = described_class::InvalidLengthError.new('x', '1', 12, 14)

      aggregate_failures do
        expect(instance.min_expected_length).to eq(12)
        expect(instance.max_expected_length).to eq(14)
        expect(instance).to be_a(described_class::DomainError)
        expect(instance).to be_a(described_class::Error)
      end
    end

    it 'exposes instantiable ValidationError' do
      instance = described_class::ValidationError.new(
        '123',
        'some reason'
      )

      aggregate_failures do
        expect(instance.actual_input).to eq('123')
        expect(instance.reason).to eq('some reason')
        expect(instance).to be_a(described_class::DomainError)
        expect(instance).to be_a(RangeError)
        expect(instance).to be_a(described_class::Error)
        expect(instance.message).to eq('CNPJ input "123" is invalid. some reason')
      end
    end
  end
end
