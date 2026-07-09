# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjGen do
  describe '.cnpj_gen' do
    context 'when called with no arguments' do
      it 'returns a 14-character alphanumeric CNPJ' do
        expect(described_class.cnpj_gen).to match(/\A[0-9A-Z]{14}\z/)
      end
    end

    context 'when called with options' do
      it 'forwards format, prefix, and type' do
        result = described_class.cnpj_gen(format: true, prefix: '12345', type: 'numeric')

        expect(result).to match(%r{\A12\.345\.\d{3}/\d{4}-\d{2}\z})
      end
    end
  end
end
