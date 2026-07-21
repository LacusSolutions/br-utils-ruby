# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfGen do
  describe '.cpf_gen' do
    context 'when called with no arguments' do
      it 'returns an 11-digit numeric CPF' do
        expect(described_class.cpf_gen).to match(/\A\d{11}\z/)
      end
    end

    context 'when called with options' do
      it 'forwards format and prefix' do
        result = described_class.cpf_gen(format: true, prefix: '12345')

        expect(result).to match(/\A123\.45\d\.\d{3}-\d{2}\z/)
      end
    end

    context 'when called with keyword options' do
      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { described_class.cpf_gen({ format: true }, prefix: '12') }
          .to raise_error(CpfGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end
end
