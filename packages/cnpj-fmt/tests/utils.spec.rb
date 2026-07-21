# frozen_string_literal: true

require 'spec_helper'
require 'cgi'
require 'erb'

RSpec.describe CnpjFmt::Utils do
  describe '.normalize_boolean' do
    it 'returns false for false, empty string, and zero' do
      aggregate_failures do
        expect(described_class.normalize_boolean(false)).to be(false)
        expect(described_class.normalize_boolean('')).to be(false)
        expect(described_class.normalize_boolean(0)).to be(false)
      end
    end

    it 'returns true for other truthy values' do
      aggregate_failures do
        expect(described_class.normalize_boolean(true)).to be(true)
        expect(described_class.normalize_boolean('yes')).to be(true)
        expect(described_class.normalize_boolean(1)).to be(true)
      end
    end
  end

  describe '.assert_string_option!' do
    it 'accepts a string' do
      expect { described_class.assert_string_option!('dot_key', '.') }.not_to raise_error
    end

    it 'raises TypeMismatchError for a non-string' do
      expect { described_class.assert_string_option!('dot_key', 1) }
        .to raise_error(CnpjFmt::TypeMismatchError) { |error|
          expect(error.option_name).to eq('dot_key')
          expect(error.expected_type).to eq('string')
        }
    end
  end

  describe '.assert_no_disallowed_key_characters!' do
    # Deliberately independent of CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS.
    let(:forbidden) { %w[å ë ï ö].freeze }

    it 'accepts a value without disallowed characters' do
      expect do
        described_class.assert_no_disallowed_key_characters!('dot_key', '.', forbidden)
      end.not_to raise_error
    end

    it 'raises ValidationError when a disallowed character is present' do
      expect do
        described_class.assert_no_disallowed_key_characters!('dot_key', forbidden.first, forbidden)
      end.to raise_error(CnpjFmt::ValidationError) { |error|
        expect(error.option_name).to eq('dot_key')
        expect(error.forbidden_characters).to include(forbidden.first)
      }
    end
  end

  describe '.fetch_option' do
    it 'reads a symbol key' do
      expect(described_class.fetch_option({ hidden: true }, :hidden)).to be(true)
    end

    it 'reads a string key' do
      expect(described_class.fetch_option({ 'hidden' => true }, :hidden)).to be(true)
    end

    it 'returns nil when the key is absent' do
      expect(described_class.fetch_option({}, :hidden)).to be_nil
    end
  end

  describe '.normalize_hidden_range' do
    it 'returns the range unchanged when start is less than or equal to end' do
      expect(described_class.normalize_hidden_range(2, 8, 0, 13)).to eq([2, 8])
    end

    it 'swaps the bounds when start is greater than end' do
      expect(described_class.normalize_hidden_range(8, 2, 0, 13)).to eq([2, 8])
    end

    it 'raises TypeMismatchError for a non-integer bound' do
      expect { described_class.normalize_hidden_range('a', 8, 0, 13) }
        .to raise_error(CnpjFmt::TypeMismatchError)
    end

    it 'raises OutOfRangeError for an out-of-range bound' do
      expect { described_class.normalize_hidden_range(-1, 8, 0, 13) }
        .to raise_error(CnpjFmt::OutOfRangeError)
    end
  end

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
        expect(raised).to be_a(CnpjFmt::DomainError)
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
