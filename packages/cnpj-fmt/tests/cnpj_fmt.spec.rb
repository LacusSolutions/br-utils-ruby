# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjFmt do
  describe '.cnpj_fmt' do
    context 'when called' do
      it 'matches CnpjFormatter#format behavior' do
        input = '91415732000793'
        formatter = CnpjFmt::CnpjFormatter.new

        expect(described_class.cnpj_fmt(input)).to eq(formatter.format(input))
      end

      it 'accepts options and forwards formatting' do
        input = '01ABC234000X56'
        options = { slash_key: '|' }

        expect(described_class.cnpj_fmt(input, options)).to eq('01.ABC.234|000X-56')
      end
    end

    context 'when called with keyword options' do
      let(:input) { '12ABC34500DE99' }
      let(:default_hidden_length) do
        described_class::CnpjFormatterOptions::DEFAULT_HIDDEN_END -
          described_class::CnpjFormatterOptions::DEFAULT_HIDDEN_START + 1
      end

      it 'forwards hidden to the formatter' do
        formatter = described_class::CnpjFormatter.new(hidden: true)

        aggregate_failures do
          expect(described_class.cnpj_fmt(input, hidden: true)).to eq(formatter.format(input))
          expect(described_class.cnpj_fmt(input, hidden: true).count('*')).to eq(default_hidden_length)
        end
      end

      it 'forwards encode to the formatter' do
        formatter = described_class::CnpjFormatter.new(encode: true)

        aggregate_failures do
          expect(described_class.cnpj_fmt(input, encode: true)).to eq(formatter.format(input))
          expect(described_class.cnpj_fmt(input, encode: true)).to eq('12.ABC.345%2F00DE-99')
        end
      end

      it 'forwards on_fail to the formatter' do
        on_fail = ->(_value, _error) { 'fallback' }
        formatter = described_class::CnpjFormatter.new(on_fail: on_fail)

        expect(described_class.cnpj_fmt('short', on_fail: on_fail)).to eq(formatter.format('short'))
      end

      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { described_class.cnpj_fmt(input, { slash_key: '|' }, hidden: true) }
          .to raise_error(CnpjFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end
end
