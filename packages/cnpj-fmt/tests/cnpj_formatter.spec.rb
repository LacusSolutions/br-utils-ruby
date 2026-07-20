# frozen_string_literal: true

require 'spec_helper'

INVALID_LENGTH_CASES = [
  ['1', 1],
  ['12', 2],
  ['12.A', 3],
  ['12.AB', 4],
  ['12.ABC', 5],
  ['12.ABC.3', 6],
  ['12.ABC.34', 7],
  ['12.ABC.345', 8],
  ['12.ABC.345/0', 9],
  ['12.ABC.345/00', 10],
  ['12.ABC.345/00D', 11],
  ['12.ABC.345/00DE', 12],
  ['12.ABC.345/00DE-6', 13],
  ['12.ABC.345/00DE-678', 15]
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

RSpec.describe CnpjFmt::CnpjFormatter do
  let(:formatter) { described_class.new }
  subject(:format) { formatter.method(:format) }

  describe '#initialize' do
    context 'when called with no arguments' do
      it 'creates an instance with default options' do
        default_options = CnpjFmt::CnpjFormatterOptions.new

        expect(described_class.new.options.all).to eq(default_options.all)
      end
    end

    context 'when called with arguments' do
      it 'sets default options with empty hash' do
        default_options = CnpjFmt::CnpjFormatterOptions.new

        expect(described_class.new({}).options.all).to eq(default_options.all)
      end

      it 'uses the provided options instance' do
        options = CnpjFmt::CnpjFormatterOptions.new

        expect(described_class.new(options).options).to be(options)
      end

      it 'overrides defaults with a literal hash' do
        options = {
          hidden: true,
          slash_key: '|',
          dot_key: '_',
          encode: true
        }

        formatter = described_class.new(options)

        options.each do |key, value|
          expect(formatter.options.all[key]).to eq(value)
        end
      end

      it 'overrides defaults with an options instance' do
        options = CnpjFmt::CnpjFormatterOptions.new(
          hidden: true,
          slash_key: '|',
          dot_key: '_',
          encode: true
        )

        expect(described_class.new(options).options.all).to eq(options.all)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        options = CnpjFmt::CnpjFormatterOptions.new(slash_key: '|')

        expect { described_class.new(options, hidden: true) }
          .to raise_error(CnpjFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        expect { described_class.new({ slash_key: '|' }, hidden: true) }
          .to raise_error(CnpjFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  describe '#format' do
    context 'when input is a string with only digits' do
      it 'handles unformatted input' do
        expect(format.call('12345678000910')).to eq('12.345.678/0009-10')
      end

      it 'handles standard formatting' do
        expect(format.call('12.345.678/0009-10')).to eq('12.345.678/0009-10')
      end

      it 'handles custom formatting' do
        expect(format.call('12 345 678 | 0009 _ 10')).to eq('12.345.678/0009-10')
      end
    end

    context 'when input is a string with only letters' do
      it 'handles unformatted input' do
        expect(format.call('ABCDEFGHIJKLMN')).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles standard formatting' do
        expect(format.call('AB.CDE.FGH/IJKL-MN')).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles custom formatting' do
        expect(format.call('AB CDE FGH | IJKL _ MN')).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'uppercases lowercase letters' do
        expect(format.call('AbCdEfGhIjKlMn')).to eq('AB.CDE.FGH/IJKL-MN')
      end
    end

    context 'when input is a string with mixed digits and letters' do
      it 'handles unformatted input' do
        expect(format.call('12ABC34500DE00')).to eq('12.ABC.345/00DE-00')
      end

      it 'handles standard formatting' do
        expect(format.call('12.ABC.345/00DE-00')).to eq('12.ABC.345/00DE-00')
      end

      it 'handles custom formatting' do
        expect(format.call('12 ABC 345 | 00DE _ 00')).to eq('12.ABC.345/00DE-00')
      end

      it 'uppercases lowercase letters' do
        expect(format.call('12abcDEF00eF00')).to eq('12.ABC.DEF/00EF-00')
      end
    end

    context 'when input is an array of strings' do
      it 'handles array of only digits' do
        result = format.call(
          %w[1 2 3 4 5 6 7 8 0 0 0 9 1 0]
        )

        expect(result).to eq('12.345.678/0009-10')
      end

      it 'handles single-item digit array' do
        expect(format.call(['12345678000910'])).to eq('12.345.678/0009-10')
      end

      it 'handles grouped digits' do
        expect(format.call(%w[12 345 678 0009 10])).to eq('12.345.678/0009-10')
      end

      it 'handles grouped digits and punctuation' do
        expect(format.call(%w[12 . 345 . 678 / 0009 - 10])).to eq('12.345.678/0009-10')
      end

      it 'handles array of only letters' do
        result = format.call(
          %w[A B C D E F G H I J K L M N]
        )

        expect(result).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles single-item letter array' do
        expect(format.call(['ABCDEFGHIJKLMN'])).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles lowercase letter array' do
        expect(format.call(['abcdefghijklmn'])).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles grouped letters' do
        expect(format.call(%w[AB CDE FGH IJKL MN])).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles grouped letters and punctuation' do
        expect(format.call(%w[AB . CDE . FGH / IJKL - MN])).to eq('AB.CDE.FGH/IJKL-MN')
      end

      it 'handles mixed digits and letters' do
        result = format.call(
          %w[1 2 a b c D E F 0 0 g H 3 4]
        )

        expect(result).to eq('12.ABC.DEF/00GH-34')
      end

      it 'handles single mixed item' do
        expect(format.call(['12abcDEF00gH34'])).to eq('12.ABC.DEF/00GH-34')
      end

      it 'handles grouped mixed content' do
        expect(format.call(%w[12 abc DEF 00gH 34])).to eq('12.ABC.DEF/00GH-34')
      end

      it 'handles grouped mixed content and punctuation' do
        expect(format.call(%w[12 . abc . DEF / 00gH - 34])).to eq('12.ABC.DEF/00GH-34')
      end
    end

    context 'when input is not a string or string array' do
      INVALID_TYPE_CASES.each do |input_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          expect { format.call(input_value) }
            .to raise_error(CnpjFmt::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.expected_type).to eq('string or string[]')
                expect(error.actual_input).to equal(input_value)
                expect(error.actual_type).to eq(actual_type)
              end
            end
        end
      end

      it 'raises TypeMismatchError for arrays with non-strings' do
        input_value = ['12', 34, '56']

        expect { format.call(input_value) }
          .to raise_error(CnpjFmt::TypeMismatchError) do |error|
            aggregate_failures do
              expect(error.expected_type).to eq('string or string[]')
              expect(error.actual_input).to eq(input_value)
            end
          end
      end
    end

    context 'when sanitized input length is not 14' do
      INVALID_LENGTH_CASES.each do |input_value, length|
        it "invokes on_fail for #{length}-char input" do
          on_fail = lambda do |value, error|
            aggregate_failures do
              expect(error).to be_a(CnpjFmt::DomainError)
              expect(error).to be_a(CnpjFmt::InvalidLengthError)
              expect(error.evaluated_input.length).to eq(length)
              expect(error.actual_input).to eq(value)
            end

            %(ERROR: "#{value}")
          end

          expect(format.call(input_value, { on_fail: on_fail })).to eq(%(ERROR: "#{input_value}"))
        end
      end

      it 'returns the string from on_fail' do
        on_fail = ->(_value, _error) { 'fallback' }

        expect(format.call('short', { on_fail: on_fail })).to eq('fallback')
      end
    end

    context 'when on_fail does not return a string' do
      ON_FAIL_INVALID_RETURN_CASES.each do |return_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          on_fail = ->(_value, _error) { return_value }

          expect { format.call('short', { on_fail: on_fail }) }
            .to raise_error(CnpjFmt::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.option_name).to eq('on_fail')
                expect(error.actual_input).to equal(return_value)
                expect(error.actual_type).to eq(actual_type)
                expect(error.expected_type).to eq('string')
                expect(error.message).to eq(
                  %(CNPJ formatting option "on_fail" must be of type string. Got #{actual_type}.)
                )
              end
            end
        end
      end
    end

    context 'when using per-call keyword overrides' do
      it 'applies overrides without mutating defaults' do
        formatter = described_class.new({ slash_key: '|' })

        aggregate_failures do
          expect(formatter.format('12ABC34500DE99', hidden: true).count('*')).to be_positive
          expect(formatter.options.hidden).to be(false)
          expect(formatter.options.slash_key).to eq('|')
        end
      end

      it 'raises InvalidArgumentCombinationError when options and keywords are both given' do
        expect { format.call('12ABC34500DE99', { hidden: false }, hidden: true) }
          .to raise_error(CnpjFmt::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end

      it 'applies encode via keyword override' do
        expect(format.call('12ABC34500DE99', encode: true)).to eq('12.ABC.345%2F00DE-99')
      end

      it 'applies on_fail via keyword override' do
        on_fail = ->(_value, _error) { 'fallback' }

        expect(format.call('short', on_fail: on_fail)).to eq('fallback')
      end
    end

    context 'when using hidden option' do
      let(:default_hidden_length) do
        CnpjFmt::CnpjFormatterOptions::DEFAULT_HIDDEN_END -
          CnpjFmt::CnpjFormatterOptions::DEFAULT_HIDDEN_START + 1
      end
      let(:standard_cnpj_format_length) { '00.000.000/0000-00'.length }

      it 'masks with asterisks when true' do
        result = format.call('12ABC34500DE99', { hidden: true })
        hidden_chars = result.chars.select { |char| char == '*' }

        aggregate_failures do
          expect(hidden_chars.length).to eq(default_hidden_length)
          expect(result.length).to eq(standard_cnpj_format_length)
        end
      end

      it 'masks a given range with asterisks' do
        result = format.call(
          '12ABC34500DE99',
          { hidden: true, hidden_start: 8, hidden_end: 11 }
        )

        aggregate_failures do
          expect(result).to eq('12.ABC.345/****-99')
          expect(result.length).to eq(standard_cnpj_format_length)
        end
      end

      it 'masks with a custom key' do
        result = format.call('12ABC34500DE99', { hidden: true, hidden_key: '#' })
        hidden_chars = result.chars.select { |char| char == '#' }

        aggregate_failures do
          expect(result).not_to include('*')
          expect(hidden_chars.length).to eq(default_hidden_length)
          expect(result.length).to eq(standard_cnpj_format_length)
        end
      end

      it 'masks with a zero-width key' do
        result = format.call('12ABC34500DE99', { hidden: true, hidden_key: '' })

        aggregate_failures do
          expect(result).not_to include('*')
          expect(result.length).to eq(standard_cnpj_format_length - default_hidden_length)
        end
      end

      it 'masks with a multi-character key' do
        result = format.call('12ABC34500DE99', { hidden: true, hidden_key: '[]' })
        bracket_chars = result.chars.select { |char| ['[', ']'].include?(char) }.join

        aggregate_failures do
          expect(result).not_to include('*')
          expect(bracket_chars).to match(/\A(\[\]){#{default_hidden_length}}\z/)
          expect(result.length).to eq(standard_cnpj_format_length + default_hidden_length)
        end
      end
    end

    context 'when customizing punctuation' do
      it 'replaces dots with a custom key' do
        expect(format.call('12ABC34500DE99', { dot_key: ' ' })).to eq('12 ABC 345/00DE-99')
      end

      it 'replaces dots with a zero-width key' do
        expect(format.call('12ABC34500DE99', { dot_key: '' })).to eq('12ABC345/00DE-99')
      end

      it 'replaces dots with a multi-character key' do
        expect(format.call('12ABC34500DE99', { dot_key: '[]' })).to eq('12[]ABC[]345/00DE-99')
      end

      it 'replaces slash with a custom key' do
        expect(format.call('12ABC34500DE99', { slash_key: '|' })).to eq('12.ABC.345|00DE-99')
      end

      it 'replaces slash with a zero-width key' do
        expect(format.call('12ABC34500DE99', { slash_key: '' })).to eq('12.ABC.34500DE-99')
      end

      it 'replaces slash with a multi-character key' do
        expect(format.call('12ABC34500DE99', { slash_key: '[]' })).to eq('12.ABC.345[]00DE-99')
      end

      it 'replaces dash with a custom key' do
        expect(format.call('12ABC34500DE99', { dash_key: '_' })).to eq('12.ABC.345/00DE_99')
      end

      it 'replaces dash with a zero-width key' do
        expect(format.call('12ABC34500DE99', { dash_key: '' })).to eq('12.ABC.345/00DE99')
      end

      it 'replaces dash with a multi-character key' do
        expect(format.call('12ABC34500DE99', { dash_key: '[]' })).to eq('12.ABC.345/00DE[]99')
      end
    end

    context 'when using escape option' do
      it 'escapes HTML special characters' do
        result = format.call(
          '12ABC34500DE99',
          {
            dot_key: '&',
            slash_key: '"',
            dash_key: '<>',
            escape: true
          }
        )

        expect(result).to eq('12&amp;ABC&amp;345&quot;00DE&lt;&gt;99')
      end
    end

    context 'when using encode option' do
      it 'URL-encodes the result' do
        expect(format.call('12ABC34500DE99', { encode: true })).to eq('12.ABC.345%2F00DE-99')
      end
    end

    context 'with multi-character delimiter edge case' do
      it 'combines hidden and custom delimiter keys' do
        result = format.call(
          '12ABC34500DE99',
          {
            hidden: true,
            hidden_start: 5,
            hidden_end: 9,
            hidden_key: '[*]',
            dot_key: '[.]',
            slash_key: '[/]',
            dash_key: '[-]'
          }
        )

        expect(result).to eq('12[.]ABC[.][*][*][*][/][*][*]DE[-]99')
      end
    end
  end
end
