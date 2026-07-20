# frozen_string_literal: true

require 'spec_helper'
require 'cgi'
require 'erb'

RSpec.describe CnpjFmt::Utils do
  describe '.sanitize_cnpj_input' do
    it 'returns an already clean uppercase alphanumeric string unchanged' do
      expect(described_class.sanitize_cnpj_input('12ABC34500DE35')).to eq('12ABC34500DE35')
    end

    it 'uppercases a clean alphanumeric string' do
      expect(described_class.sanitize_cnpj_input('12abc34500de35')).to eq('12ABC34500DE35')
    end

    it 'strips punctuation and uppercases letters' do
      expect(described_class.sanitize_cnpj_input('12.abc.345/00de-35')).to eq('12ABC34500DE35')
    end
  end

  describe '.to_string_input' do
    it 'returns a string unchanged' do
      expect(described_class.to_string_input('12ABC34500DE35')).to eq('12ABC34500DE35')
    end

    it 'joins an array of strings' do
      expect(described_class.to_string_input(%w[12 ABC 345 00DE 35])).to eq('12ABC34500DE35')
    end

    it 'raises TypeMismatchError for a non-string, non-array input' do
      expect { described_class.to_string_input(12_345) }
        .to raise_error(CnpjFmt::TypeMismatchError) { |error|
          expect(error.option_name).to be_nil
          expect(error.expected_type).to eq('string or string[]')
          expect(error.actual_input).to eq(12_345)
        }
    end

    it 'raises TypeMismatchError when an array contains a non-string' do
      input = ['12', 34, '56']

      expect { described_class.to_string_input(input) }
        .to raise_error(CnpjFmt::TypeMismatchError) { |error|
          expect(error.expected_type).to eq('string or string[]')
          expect(error.actual_input).to eq(input)
        }
    end
  end

  describe '.insert_delimiters' do
    it 'inserts default delimiter keys' do
      options = CnpjFmt::CnpjFormatterOptions.new

      expect(described_class.insert_delimiters('12ABC34500DE35', options))
        .to eq('12.ABC.345/00DE-35')
    end

    it 'uses custom delimiter keys' do
      options = CnpjFmt::CnpjFormatterOptions.new(dot_key: ' ', slash_key: '|', dash_key: '_')

      expect(described_class.insert_delimiters('12ABC34500DE35', options))
        .to eq('12 ABC 345|00DE_35')
    end
  end

  describe '.apply_hidden_mask' do
    it 'replaces the inclusive hidden range with the placeholder character' do
      options = CnpjFmt::CnpjFormatterOptions.new(hidden_start: 5, hidden_end: 11)
      placeholder = described_class::HIDDEN_KEY_PLACEHOLDER

      expect(described_class.apply_hidden_mask('12ABC34500DE35', options))
        .to eq("12ABC#{placeholder * 7}35")
    end
  end

  describe '.replace_hidden_placeholders' do
    it 'substitutes each placeholder with the hidden key' do
      placeholder = described_class::HIDDEN_KEY_PLACEHOLDER
      masked = "12ABC#{placeholder * 3}DE35"

      expect(described_class.replace_hidden_placeholders(masked, '#'))
        .to eq('12ABC###DE35')
    end
  end

  describe '.apply_post_processing' do
    it 'returns the string unchanged when escape and encode are false' do
      options = CnpjFmt::CnpjFormatterOptions.new(escape: false, encode: false)

      expect(described_class.apply_post_processing('12.ABC.345/00DE-35', options))
        .to eq('12.ABC.345/00DE-35')
    end

    it 'HTML-escapes when escape is true' do
      options = CnpjFmt::CnpjFormatterOptions.new(escape: true, encode: false)

      expect(described_class.apply_post_processing('12.ABC.345/00DE-35', options))
        .to eq(CGI.escapeHTML('12.ABC.345/00DE-35'))
    end

    it 'URL-encodes when encode is true' do
      options = CnpjFmt::CnpjFormatterOptions.new(escape: false, encode: true)

      expect(described_class.apply_post_processing('12.ABC.345/00DE-35', options))
        .to eq(ERB::Util.url_encode('12.ABC.345/00DE-35'))
    end

    it 'applies escape before encode when both are true' do
      options = CnpjFmt::CnpjFormatterOptions.new(escape: true, encode: true)
      escaped = CGI.escapeHTML('12.ABC.345/00DE-35')

      expect(described_class.apply_post_processing('12.ABC.345/00DE-35', options))
        .to eq(ERB::Util.url_encode(escaped))
    end
  end

  describe '.invoke_on_fail' do
    let(:error) { CnpjFmt::InvalidLengthError.new('short', 'short', 14) }

    it 'returns the callback string result' do
      on_fail = lambda { |value, raised|
        expect(value).to eq('short')
        expect(raised).to equal(error)
        'fallback'
      }

      expect(described_class.invoke_on_fail(on_fail, 'short', error)).to eq('fallback')
    end

    it 'raises TypeMismatchError when the callback does not return a string' do
      on_fail = ->(_value, _raised) { 123 }

      expect { described_class.invoke_on_fail(on_fail, 'short', error) }
        .to raise_error(CnpjFmt::TypeMismatchError) { |raised|
          expect(raised.option_name).to eq('on_fail')
          expect(raised.actual_input).to eq(123)
          expect(raised.expected_type).to eq('string')
        }
    end
  end
end
