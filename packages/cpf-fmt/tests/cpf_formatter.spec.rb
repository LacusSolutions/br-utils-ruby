# frozen_string_literal: true

require 'spec_helper'

INVALID_LENGTH_CASES = [
  ['1', 1],
  ['12', 2],
  ['123', 3],
  ['1234', 4],
  ['12345', 5],
  ['123456', 6],
  ['1234567', 7],
  ['12345678', 8],
  ['123456789', 9],
  ['1234567890', 10],
  ['123456789012', 12],
  ['1234567890123', 13]
].freeze

INVALID_TYPE_CASES = [
  [nil, 'nil'],
  [42, 'integer number'],
  [3.14, 'float number'],
  [false, 'boolean'],
  [true, 'boolean'],
  [{}, 'hash']
].freeze

ON_FAIL_INVALID_RETURN_CASES = [
  [42, 'integer number'],
  [true, 'boolean'],
  [nil, 'nil'],
  [{}, 'hash']
].freeze

RSpec.describe CpfFmt::CpfFormatter do
  let(:formatter) { described_class.new }
  subject(:format) { formatter.method(:format) }

  describe '#initialize' do
    context 'when called with no arguments' do
      it 'creates an instance with default options' do
        default_options = CpfFmt::CpfFormatterOptions.new

        expect(described_class.new.options.all).to eq(default_options.all)
      end
    end

    context 'when called with arguments' do
      it 'sets default options with empty hash' do
        default_options = CpfFmt::CpfFormatterOptions.new

        expect(described_class.new({}).options.all).to eq(default_options.all)
      end

      it 'uses the provided options instance' do
        options = CpfFmt::CpfFormatterOptions.new

        expect(described_class.new(options).options).to be(options)
      end

      it 'overrides defaults with a literal hash' do
        options = {
          hidden: true,
          dash_key: '_',
          dot_key: ' ',
          encode: true
        }

        formatter = described_class.new(options)

        options.each do |key, value|
          expect(formatter.options.all[key]).to eq(value)
        end
      end

      it 'overrides defaults with an options instance' do
        options = CpfFmt::CpfFormatterOptions.new(
          hidden: true,
          dash_key: '_',
          dot_key: ' ',
          encode: true
        )

        expect(described_class.new(options).options.all).to eq(options.all)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        options = CpfFmt::CpfFormatterOptions.new(dot_key: ' ')

        expect { described_class.new(options, hidden: true) }
          .to raise_error(CpfFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        expect { described_class.new({ dot_key: ' ' }, hidden: true) }
          .to raise_error(CpfFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  describe '#format' do
    context 'when input is a string' do
      it 'handles unformatted input' do
        expect(format.call('12345678910')).to eq('123.456.789-10')
      end

      it 'handles standard formatting' do
        expect(format.call('123.456.789-10')).to eq('123.456.789-10')
      end

      it 'handles custom formatting' do
        expect(format.call('123 456 789 _ 10')).to eq('123.456.789-10')
      end

      it 'handles input with dashes' do
        expect(format.call('809-765-110-61')).to eq('809.765.110-61')
      end

      it 'handles input with spaces' do
        expect(format.call('809 765 110 61')).to eq('809.765.110-61')
      end

      it 'handles input with trailing space' do
        expect(format.call('80976511061 ')).to eq('809.765.110-61')
      end

      it 'handles input with leading space' do
        expect(format.call(' 80976511061')).to eq('809.765.110-61')
      end

      it 'handles input with individual dots' do
        expect(format.call('8.0.9.7.6.5.1.1.0.6.1')).to eq('809.765.110-61')
      end

      it 'handles input with individual dashes' do
        expect(format.call('8-0-9-7-6-5-1-1-0-6-1')).to eq('809.765.110-61')
      end

      it 'handles input with individual spaces' do
        expect(format.call('8 0 9 7 6 5 1 1 0 6 1')).to eq('809.765.110-61')
      end

      it 'strips non-digit characters' do
        expect(format.call('80976511061abc')).to eq('809.765.110-61')
      end

      it 'strips mixed non-digit separators' do
        expect(format.call('809765110 dv 61')).to eq('809.765.110-61')
      end

      it 'preserves leading zeros' do
        expect(format.call('03603568195')).to eq('036.035.681-95')
      end
    end

    context 'when input is an array of strings' do
      it 'handles array of only digits' do
        result = format.call(
          %w[1 2 3 4 5 6 7 8 9 1 0]
        )

        expect(result).to eq('123.456.789-10')
      end

      it 'handles single-item digit array' do
        expect(format.call(['12345678910'])).to eq('123.456.789-10')
      end

      it 'handles grouped digits' do
        expect(format.call(%w[123 456 789 10])).to eq('123.456.789-10')
      end

      it 'handles grouped digits and punctuation' do
        expect(format.call(%w[123 . 456 . 789 - 10])).to eq('123.456.789-10')
      end
    end

    context 'when input is not a string or string array' do
      INVALID_TYPE_CASES.each do |input_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          expect { format.call(input_value) }
            .to raise_error(CpfFmt::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.expected_type).to eq('string or string[]')
                expect(error.actual_input).to equal(input_value)
                expect(error.actual_type).to eq(actual_type)
              end
            end
        end
      end

      it 'raises TypeMismatchError for arrays with non-strings' do
        input_value = ['123', 45, '6789010']

        expect { format.call(input_value) }
          .to raise_error(CpfFmt::TypeMismatchError) do |error|
            aggregate_failures do
              expect(error.expected_type).to eq('string or string[]')
              expect(error.actual_input).to eq(input_value)
            end
          end
      end
    end

    context 'when sanitized input length is not 11' do
      INVALID_LENGTH_CASES.each do |input_value, length|
        it "invokes on_fail for #{length}-digit input" do
          on_fail = lambda do |value, error|
            aggregate_failures do
              expect(error).to be_a(CpfFmt::DomainError)
              expect(error).to be_a(CpfFmt::InvalidLengthError)
              expect(error.evaluated_input.length).to eq(length)
              expect(error.actual_input).to eq(value)
            end

            %(ERROR: "#{value}")
          end

          expect(format.call(input_value, { on_fail: on_fail })).to eq(%(ERROR: "#{input_value}"))
        end
      end

      it 'returns the string from on_fail' do
        on_fail = ->(value, _error) { value.upcase }

        expect(format.call('abc', { on_fail: on_fail })).to eq('ABC')
      end

      it 'returns an empty string from the default on_fail' do
        expect(format.call('abc')).to eq('')
      end
    end

    context 'when on_fail does not return a string' do
      ON_FAIL_INVALID_RETURN_CASES.each do |return_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          on_fail = ->(_value, _error) { return_value }

          expect { format.call('short', { on_fail: on_fail }) }
            .to raise_error(CpfFmt::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.option_name).to eq('on_fail')
                expect(error.actual_input).to equal(return_value)
                expect(error.actual_type).to eq(actual_type)
                expect(error.expected_type).to eq('string')
                expect(error.message).to eq(
                  %(CPF formatting option "on_fail" must be of type string. Got #{actual_type}.)
                )
              end
            end
        end
      end
    end

    context 'when using per-call keyword overrides' do
      it 'applies overrides without mutating defaults' do
        formatter = described_class.new({ dot_key: ' ' })

        aggregate_failures do
          expect(formatter.format('12345678910', hidden: true).count('*')).to be_positive
          expect(formatter.options.hidden).to be(false)
          expect(formatter.options.dot_key).to eq(' ')
        end
      end

      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { format.call('12345678910', { hidden: false }, hidden: true) }
          .to raise_error(CpfFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end

      it 'applies encode via keyword override' do
        expect(format.call('12345678910', encode: true, dash_key: '/')).to eq('123.456.789%2F10')
      end

      it 'applies on_fail via keyword override' do
        on_fail = ->(_value, _error) { 'fallback' }

        expect(format.call('short', on_fail: on_fail)).to eq('fallback')
      end
    end

    context 'when using hidden option' do
      let(:default_hidden_length) do
        CpfFmt::CpfFormatterOptions::DEFAULT_HIDDEN_END -
          CpfFmt::CpfFormatterOptions::DEFAULT_HIDDEN_START + 1
      end
      let(:standard_cpf_format_length) { '000.000.000-00'.length }

      it 'masks with asterisks when true' do
        result = format.call('12345678910', { hidden: true })
        hidden_chars = result.chars.select { |char| char == '*' }

        aggregate_failures do
          expect(hidden_chars.length).to eq(default_hidden_length)
          expect(result.length).to eq(standard_cpf_format_length)
        end
      end

      it 'masks a given range with asterisks' do
        result = format.call(
          '12345678910',
          { hidden: true, hidden_start: 3, hidden_end: 7 }
        )

        aggregate_failures do
          expect(result).to eq('123.***.**9-10')
          expect(result.length).to eq(standard_cpf_format_length)
        end
      end

      it 'masks with a custom key' do
        result = format.call('12345678910', { hidden: true, hidden_key: '#' })
        hidden_chars = result.chars.select { |char| char == '#' }

        aggregate_failures do
          expect(result).not_to include('*')
          expect(hidden_chars.length).to eq(default_hidden_length)
          expect(result.length).to eq(standard_cpf_format_length)
        end
      end

      it 'masks with a zero-width key' do
        result = format.call('12345678910', { hidden: true, hidden_key: '' })

        aggregate_failures do
          expect(result).not_to include('*')
          expect(result.length).to eq(standard_cpf_format_length - default_hidden_length)
        end
      end

      it 'masks with a multi-character key' do
        result = format.call('12345678910', { hidden: true, hidden_key: '[]' })
        bracket_chars = result.chars.select { |char| ['[', ']'].include?(char) }.join

        aggregate_failures do
          expect(result).not_to include('*')
          expect(bracket_chars).to match(/\A(\[\]){#{default_hidden_length}}\z/)
          expect(result.length).to eq(standard_cpf_format_length + default_hidden_length)
        end
      end

      it 'masks from a custom start index' do
        expect(format.call('80976511061', { hidden: true, hidden_start: 6 }))
          .to eq('809.765.***-**')
      end

      it 'masks up to a custom end index' do
        expect(format.call('80976511061', { hidden: true, hidden_end: 8 }))
          .to eq('809.***.***-61')
      end

      it 'masks a full custom range' do
        expect(format.call('80976511061', { hidden: true, hidden_start: 0, hidden_end: 8 }))
          .to eq('***.***.***-61')
      end

      it 'swaps reversed hidden range values' do
        expect(format.call('80976511061', { hidden: true, hidden_start: 9, hidden_end: 3 }))
          .to eq('809.***.***-*1')
      end

      it 'masks with a custom key and start index' do
        expect(
          format.call('80976511061', { hidden: true, hidden_key: '#', hidden_start: 6 })
        ).to eq('809.765.###-##')
      end

      it 'raises OutOfRangeError for start below zero' do
        expect { format.call('12345678910', { hidden: true, hidden_start: -1 }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end

      it 'raises OutOfRangeError for start above 10' do
        expect { format.call('12345678910', { hidden: true, hidden_start: 11 }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end

      it 'raises OutOfRangeError for end below zero' do
        expect { format.call('12345678910', { hidden: true, hidden_end: -1 }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end

      it 'raises OutOfRangeError for end above 10' do
        expect { format.call('12345678910', { hidden: true, hidden_end: 11 }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end
    end

    context 'when customizing punctuation' do
      it 'replaces dots with a custom key' do
        expect(format.call('12345678910', { dot_key: ' ' })).to eq('123 456 789-10')
      end

      it 'replaces dots with a zero-width key' do
        expect(format.call('12345678910', { dot_key: '' })).to eq('123456789-10')
      end

      it 'replaces dots with a multi-character key' do
        expect(format.call('12345678910', { dot_key: '[]' })).to eq('123[]456[]789-10')
      end

      it 'replaces dash with a custom key' do
        expect(format.call('12345678910', { dash_key: '_' })).to eq('123.456.789_10')
      end

      it 'replaces dash with a zero-width key' do
        expect(format.call('12345678910', { dash_key: '' })).to eq('123.456.78910')
      end

      it 'replaces dash with a multi-character key' do
        expect(format.call('12345678910', { dash_key: ' dv ' })).to eq('123.456.789 dv 10')
      end

      it 'uses dash_key as a trailing delimiter with a dot character' do
        expect(format.call('80976511061', { dash_key: '.' })).to eq('809.765.110.61')
      end

      it 'removes all delimiters' do
        expect(format.call('809.765.110-61', { dot_key: '', dash_key: '' })).to eq('80976511061')
      end
    end

    context 'when using escape option' do
      it 'escapes HTML special characters' do
        result = format.call(
          '12345678910',
          {
            dot_key: '&',
            dash_key: '<>',
            escape: true
          }
        )

        expect(result).to eq('123&amp;456&amp;789&lt;&gt;10')
      end

      it 'escapes angle-bracket delimiters' do
        result = format.call(
          '80976511061',
          {
            dot_key: '<',
            dash_key: '>',
            escape: true
          }
        )

        expect(result).to eq('809&lt;765&lt;110&gt;61')
      end
    end

    context 'when using encode option' do
      it 'URL-encodes the result' do
        expect(format.call('12345678910', { dash_key: '/', encode: true }))
          .to eq('123.456.789%2F10')
      end
    end

    context 'with multi-character delimiter edge case' do
      it 'combines hidden and custom delimiter keys' do
        result = format.call(
          '12345678910',
          {
            hidden: true,
            hidden_start: 3,
            hidden_end: 7,
            hidden_key: '[*]',
            dot_key: '[.]',
            dash_key: '[-]'
          }
        )

        expect(result).to eq('123[.][*][*][*][.][*][*]9[-]10')
      end
    end
  end
end
