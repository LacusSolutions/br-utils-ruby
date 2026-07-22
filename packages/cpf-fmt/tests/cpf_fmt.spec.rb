# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfFmt do
  describe '.cpf_fmt' do
    context 'when called' do
      it 'matches CpfFormatter#format behavior' do
        input = '12345678910'
        formatter = CpfFmt::CpfFormatter.new

        expect(described_class.cpf_fmt(input)).to eq(formatter.format(input))
      end

      it 'accepts options and forwards formatting' do
        input = '12345678910'
        options = { dot_key: ' ', dash_key: '_' }

        expect(described_class.cpf_fmt(input, options)).to eq('123 456 789_10')
      end
    end

    context 'when called with keyword options' do
      let(:input) { '12345678910' }
      let(:default_hidden_length) do
        described_class::CpfFormatterOptions::DEFAULT_HIDDEN_END -
          described_class::CpfFormatterOptions::DEFAULT_HIDDEN_START + 1
      end

      it 'forwards hidden to the formatter' do
        formatter = described_class::CpfFormatter.new(hidden: true)

        aggregate_failures do
          expect(described_class.cpf_fmt(input, hidden: true)).to eq(formatter.format(input))
          expect(described_class.cpf_fmt(input, hidden: true).count('*')).to eq(default_hidden_length)
        end
      end

      it 'forwards encode to the formatter' do
        formatter = described_class::CpfFormatter.new(encode: true, dash_key: '/')

        aggregate_failures do
          expect(described_class.cpf_fmt(input, encode: true, dash_key: '/'))
            .to eq(formatter.format(input))
          expect(described_class.cpf_fmt(input, encode: true, dash_key: '/'))
            .to eq('123.456.789%2F10')
        end
      end

      it 'forwards on_fail to the formatter' do
        on_fail = ->(_value, _error) { 'fallback' }
        formatter = described_class::CpfFormatter.new(on_fail: on_fail)

        expect(described_class.cpf_fmt('short', on_fail: on_fail)).to eq(formatter.format('short'))
      end

      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { described_class.cpf_fmt(input, { dot_key: ' ' }, hidden: true) }
          .to raise_error(CpfFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  context 'when inspecting public types' do
    it 'exposes CpfInput as a String or Array<String> predicate' do
      aggregate_failures do
        expect(described_class::CpfInput.accept?('82911017366')).to be(true)
        expect(described_class::CpfInput.accept?(%w[8 2 9])).to be(true)
        expect(described_class::CpfInput.accept?(123)).to be(false)
        expect(described_class::CpfInput.accept?([1, 2, 3])).to be(false)
        expect(described_class::CpfInput.accept?(['8', 2])).to be(false)
        # rubocop:disable Style/CaseEquality -- public case-equality protocol
        expect(described_class::CpfInput === 123).to be(false)
        expect(described_class::CpfInput === '82911017366').to be(true)
        # rubocop:enable Style/CaseEquality
      end
    end
  end
end
