# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfVal do
  describe '.cpf_val' do
    context 'when called' do
      it 'matches CpfValidator#is_valid behavior' do
        input = '82911017366'
        validator = described_class::CpfValidator.new

        expect(described_class.cpf_val(input)).to eq(validator.is_valid(input))
      end

      it 'returns true for a valid cpf' do
        expect(described_class.cpf_val('82911017366')).to be(true)
      end

      it 'returns false for an invalid cpf' do
        expect(described_class.cpf_val('33528612691')).to be(false)
      end
    end

    context 'when validating smoke-test vectors' do
      it 'returns true for a valid unformatted CPF' do
        expect(described_class.cpf_val('33528612690')).to be(true)
      end

      it 'returns false for an invalid check digit' do
        expect(described_class.cpf_val('33528612691')).to be(false)
      end
    end
  end

  context 'when inspecting constants' do
    it 'exposes CPF_LENGTH as 11' do
      expect(described_class::CPF_LENGTH).to eq(11)
    end
  end

  context 'when inspecting public constants' do
    it 'defines CpfValidator' do
      expect(described_class.const_defined?(:CpfValidator)).to be(true)
    end

    it 'defines Error' do
      expect(described_class.const_defined?(:Error)).to be(true)
    end

    it 'defines TypeMismatchError' do
      expect(described_class.const_defined?(:TypeMismatchError)).to be(true)
    end
  end

  context 'when inspecting public types' do
    it 'exposes cpf_val as a callable helper' do
      aggregate_failures do
        expect(described_class).to respond_to(:cpf_val)
        expect(described_class.cpf_val('33528612690')).to be(true)
        expect(described_class.cpf_val('33528612691')).to be(false)
      end
    end

    it 'exposes CpfValidator as an instantiable class' do
      validator = described_class::CpfValidator.new
      result = validator.is_valid('33528612690')

      aggregate_failures do
        expect(validator).to be_a(described_class::CpfValidator)
        expect(result).to be(true)
      end
    end

    it 'exposes TypeMismatchError as a TypeError' do
      expect(described_class::TypeMismatchError < TypeError).to be(true)
    end

    it 'exposes instantiable TypeMismatchError' do
      error = described_class::TypeMismatchError.new(123, 'string')

      aggregate_failures do
        expect(error.actual_input).to eq(123)
        expect(error.actual_type).to eq('integer number')
        expect(error.expected_type).to eq('string')
        expect(error).to be_a(described_class::Error)
        expect(error.message).to eq('CPF input must be of type string. Got integer number.')
      end
    end
  end
end
