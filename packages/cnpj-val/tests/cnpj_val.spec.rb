# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjVal do
  describe '.cnpj_val' do
    context 'when called' do
      it 'matches CnpjValidator#is_valid behavior' do
        input = '91415732000793'
        validator = described_class::CnpjValidator.new

        expect(described_class.cnpj_val(input)).to eq(validator.is_valid(input))
      end

      it 'accepts options and forwards validation behavior' do
        input = '01ABC234000X56'
        options = { type: 'numeric' }

        expect(described_class.cnpj_val(input, options)).to be(false)
      end
    end

    context 'when called with keyword options' do
      let(:input) { '9jn7mgljzxio50' }

      it 'forwards type to the validator' do
        aggregate_failures do
          expect(described_class.cnpj_val(input, type: 'numeric'))
            .to eq(described_class::CnpjValidator.new(type: 'numeric').is_valid(input))
          expect(described_class.cnpj_val(input, type: 'numeric')).to be(false)
        end
      end

      it 'forwards case_sensitive to the validator' do
        aggregate_failures do
          expect(described_class.cnpj_val(input, case_sensitive: false))
            .to eq(described_class::CnpjValidator.new(case_sensitive: false).is_valid(input))
          expect(described_class.cnpj_val(input, case_sensitive: false)).to be(true)
        end
      end

      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { described_class.cnpj_val(input, { type: 'alphanumeric' }, case_sensitive: false) }
          .to raise_error(CnpjVal::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when validating smoke-test vectors' do
      it 'returns true for a valid numeric CNPJ' do
        expect(described_class.cnpj_val('91415732000793')).to be(true)
      end

      it 'returns true for a valid alphanumeric CNPJ' do
        expect(described_class.cnpj_val('9JN7MGLJZXIO50')).to be(true)
      end

      it 'returns false for an invalid check digit' do
        expect(described_class.cnpj_val('9JN7MGLJZXIO51')).to be(false)
      end
    end
  end
end
