# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjFmt::CnpjFormatterOptions do
  def expect_options_match(actual, expected)
    expected.each do |key, value|
      if key == :on_fail
        expect(actual[key]).to equal(value)
      else
        expect(actual[key]).to eq(value)
      end
    end
  end

  def forbidden_key_message(option_name, value)
    quoted = described_class::DISALLOWED_KEY_CHARACTERS.map { |char| %("#{char}") }.join(', ')

    %(Value "#{value}" for CNPJ formatting option "#{option_name}" contains disallowed characters (#{quoted}).)
  end

  let(:default_parameters) do
    {
      hidden: described_class::DEFAULT_HIDDEN,
      hidden_key: described_class::DEFAULT_HIDDEN_KEY,
      hidden_start: described_class::DEFAULT_HIDDEN_START,
      hidden_end: described_class::DEFAULT_HIDDEN_END,
      dot_key: described_class::DEFAULT_DOT_KEY,
      slash_key: described_class::DEFAULT_SLASH_KEY,
      dash_key: described_class::DEFAULT_DASH_KEY,
      escape: described_class::DEFAULT_ESCAPE,
      encode: described_class::DEFAULT_ENCODE,
      on_fail: described_class::DEFAULT_ON_FAIL
    }
  end

  describe '#initialize' do
    context 'when called with no parameters' do
      it 'sets all options to default values' do
        expect_options_match(described_class.new.all, default_parameters)
      end
    end

    context 'when called with all parameters set to nil' do
      it 'sets all options to default values' do
        options = described_class.new(
          {
            hidden: nil,
            hidden_key: nil,
            hidden_start: nil,
            hidden_end: nil,
            dot_key: nil,
            slash_key: nil,
            dash_key: nil,
            escape: nil,
            encode: nil,
            on_fail: nil
          }
        )

        expect_options_match(options.all, default_parameters)
      end
    end

    context 'when called with all parameters' do
      it 'sets all options to the provided values' do
        on_fail = ->(value, _error) { "ERROR: #{value}" }
        parameters = {
          hidden: true,
          hidden_key: '#',
          hidden_start: 1,
          hidden_end: 8,
          dot_key: '|',
          slash_key: '_',
          dash_key: '~',
          escape: true,
          encode: true,
          on_fail: on_fail
        }

        expect_options_match(described_class.new(parameters).all, parameters)
      end
    end

    context 'when called with some parameters' do
      it 'sets only the provided non-nil values' do
        options = described_class.new(
          hidden: true,
          hidden_key: '#',
          hidden_start: nil,
          hidden_end: nil,
          escape: true,
          encode: false,
          on_fail: nil
        )

        expect_options_match(
          options.all,
          default_parameters.merge(
            hidden: true,
            hidden_key: '#',
            escape: true,
            encode: false
          )
        )
      end
    end

    context 'when called with a CnpjFormatterOptions instance' do
      it 'creates a new instance with the same values' do
        original_options = described_class.new(
          hidden: true,
          hidden_start: 1,
          hidden_end: 8,
          slash_key: '|',
          escape: true,
          on_fail: ->(value, _error) { "ERROR: #{value}" }
        )

        options = described_class.new(original_options)

        aggregate_failures do
          expect(options).not_to equal(original_options)
          expect_options_match(options.all, original_options.all)
        end
      end
    end

    context 'when called with override parameters' do
      it 'uses the last option with two params' do
        options = described_class.new({ hidden_key: '#' }, { hidden_key: 'X' })

        expect(options.hidden_key).to eq('X')
      end

      it 'uses the last option with one hash and one instance' do
        options = described_class.new(
          { hidden_key: '#' },
          described_class.new(hidden_key: 'X')
        )

        expect(options.hidden_key).to eq('X')
      end

      it 'uses the last option with five params' do
        options = described_class.new(
          { hidden_key: '.' },
          { hidden_key: '_' },
          { hidden_key: '#' },
          { hidden_key: 'X' },
          { hidden_key: '@' }
        )

        expect(options.hidden_key).to eq('@')
      end
    end
  end

  describe '#hidden=' do
    context 'when setting to a boolean value' do
      it 'sets hidden to true' do
        options = described_class.new(hidden: false)
        options.hidden = true

        expect(options.hidden).to be(true)
      end

      it 'sets hidden to false' do
        options = described_class.new(hidden: true)
        options.hidden = false

        expect(options.hidden).to be(false)
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(hidden: !default_parameters[:hidden])
        options.hidden = nil

        expect(options.hidden).to eq(default_parameters[:hidden])
      end
    end

    context 'when setting to a non-boolean value' do
      it 'coerces an object to true' do
        options = described_class.new(hidden: false)
        options.hidden = { not: 'a boolean' }

        expect(options.hidden).to be(true)
      end

      it 'coerces a truthy string to true' do
        options = described_class.new(hidden: false)
        options.hidden = 'not a boolean'

        expect(options.hidden).to be(true)
      end

      it 'coerces a truthy number to true' do
        options = described_class.new(hidden: false)
        options.hidden = 123

        expect(options.hidden).to be(true)
      end

      it 'coerces an empty string to false' do
        options = described_class.new(hidden: false)
        options.hidden = ''

        expect(options.hidden).to be(false)
      end

      it 'coerces zero to false' do
        options = described_class.new(hidden: false)
        options.hidden = 0

        expect(options.hidden).to be(false)
      end
    end
  end

  describe '#hidden_key=' do
    context 'when setting to a string value' do
      it 'sets hidden_key to the provided value' do
        options = described_class.new(hidden_key: '*')
        options.hidden_key = 'X'

        expect(options.hidden_key).to eq('X')
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(hidden_key: '#')
        options.hidden_key = nil

        expect(options.hidden_key).to eq(default_parameters[:hidden_key])
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.hidden_key = { not: 'a string' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_key" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.hidden_key = 123 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_key" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.hidden_key = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_key" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to a forbidden key character' do
      described_class::DISALLOWED_KEY_CHARACTERS.each do |forbidden_char|
        it "raises ValidationError for #{forbidden_char}" do
          options = described_class.new

          expect { options.hidden_key = forbidden_char }
            .to raise_error(
              CnpjFmt::ValidationError,
              forbidden_key_message('hidden_key', forbidden_char)
            )
        end
      end
    end
  end

  describe '#hidden_start=' do
    context 'when setting to a number value' do
      it 'sets hidden_start to the provided value' do
        options = described_class.new(hidden_start: 0)
        options.hidden_start = 1

        expect(options.hidden_start).to eq(1)
      end
    end

    context 'when setting to an invalid range' do
      it 'raises OutOfRangeError for -1' do
        options = described_class.new

        expect { options.hidden_start = -1 }
          .to raise_error(
            CnpjFmt::OutOfRangeError,
            'CNPJ formatting option "hidden_start" must be an integer between 0 and 13. Got -1.'
          )
      end

      it 'raises OutOfRangeError for 14' do
        options = described_class.new

        expect { options.hidden_start = 14 }
          .to raise_error(
            CnpjFmt::OutOfRangeError,
            'CNPJ formatting option "hidden_start" must be an integer between 0 and 13. Got 14.'
          )
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(hidden_start: 0)
        options.hidden_start = nil

        expect(options.hidden_start).to eq(default_parameters[:hidden_start])
      end
    end

    context 'when setting to a non-integer value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.hidden_start = { not: 'a number' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_start" must be of type integer. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a string' do
        options = described_class.new

        expect { options.hidden_start = 'not a number' }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_start" must be of type integer. Got string.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.hidden_start = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_start" must be of type integer. Got boolean.'
          )
      end

      it 'raises TypeMismatchError for a float' do
        options = described_class.new

        expect { options.hidden_start = 1.5 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_start" must be of type integer. Got float number.'
          )
      end
    end
  end

  describe '#hidden_end=' do
    context 'when setting to a number value' do
      it 'sets hidden_end to the provided value' do
        options = described_class.new(hidden_end: 13)
        options.hidden_end = 12

        expect(options.hidden_end).to eq(12)
      end
    end

    context 'when setting to an invalid range' do
      it 'raises OutOfRangeError for -1' do
        options = described_class.new

        expect { options.hidden_end = -1 }
          .to raise_error(
            CnpjFmt::OutOfRangeError,
            'CNPJ formatting option "hidden_end" must be an integer between 0 and 13. Got -1.'
          )
      end

      it 'raises OutOfRangeError for 14' do
        options = described_class.new

        expect { options.hidden_end = 14 }
          .to raise_error(
            CnpjFmt::OutOfRangeError,
            'CNPJ formatting option "hidden_end" must be an integer between 0 and 13. Got 14.'
          )
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(hidden_end: 0)
        options.hidden_end = nil

        expect(options.hidden_end).to eq(default_parameters[:hidden_end])
      end
    end

    context 'when setting to a non-integer value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.hidden_end = { not: 'a number' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_end" must be of type integer. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a string' do
        options = described_class.new

        expect { options.hidden_end = 'not a number' }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_end" must be of type integer. Got string.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.hidden_end = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_end" must be of type integer. Got boolean.'
          )
      end

      it 'raises TypeMismatchError for a float' do
        options = described_class.new

        expect { options.hidden_end = 1.5 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "hidden_end" must be of type integer. Got float number.'
          )
      end
    end
  end

  describe '#dot_key=' do
    context 'when setting to a string value' do
      it 'sets dot_key to the provided value' do
        options = described_class.new(dot_key: '.')
        options.dot_key = '_'

        expect(options.dot_key).to eq('_')
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(dot_key: '_')
        options.dot_key = nil

        expect(options.dot_key).to eq(default_parameters[:dot_key])
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.dot_key = { not: 'a string' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dot_key" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.dot_key = 123 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dot_key" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.dot_key = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dot_key" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to a forbidden key character' do
      described_class::DISALLOWED_KEY_CHARACTERS.each do |forbidden_char|
        it "raises ValidationError for #{forbidden_char}" do
          options = described_class.new

          expect { options.dot_key = forbidden_char }
            .to raise_error(
              CnpjFmt::ValidationError,
              forbidden_key_message('dot_key', forbidden_char)
            )
        end
      end
    end
  end

  describe '#slash_key=' do
    context 'when setting to a string value' do
      it 'sets slash_key to the provided value' do
        options = described_class.new(slash_key: '.')
        options.slash_key = '_'

        expect(options.slash_key).to eq('_')
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(slash_key: '_')
        options.slash_key = nil

        expect(options.slash_key).to eq(default_parameters[:slash_key])
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.slash_key = { not: 'a string' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "slash_key" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.slash_key = 123 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "slash_key" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.slash_key = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "slash_key" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to a forbidden key character' do
      described_class::DISALLOWED_KEY_CHARACTERS.each do |forbidden_char|
        it "raises ValidationError for #{forbidden_char}" do
          options = described_class.new

          expect { options.slash_key = forbidden_char }
            .to raise_error(
              CnpjFmt::ValidationError,
              forbidden_key_message('slash_key', forbidden_char)
            )
        end
      end
    end
  end

  describe '#dash_key=' do
    context 'when setting to a string value' do
      it 'sets dash_key to the provided value' do
        options = described_class.new(dash_key: '.')
        options.dash_key = '_'

        expect(options.dash_key).to eq('_')
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(dash_key: '_')
        options.dash_key = nil

        expect(options.dash_key).to eq(default_parameters[:dash_key])
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.dash_key = { not: 'a string' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dash_key" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.dash_key = 123 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dash_key" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.dash_key = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "dash_key" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to a forbidden key character' do
      described_class::DISALLOWED_KEY_CHARACTERS.each do |forbidden_char|
        it "raises ValidationError for #{forbidden_char}" do
          options = described_class.new

          expect { options.dash_key = forbidden_char }
            .to raise_error(
              CnpjFmt::ValidationError,
              forbidden_key_message('dash_key', forbidden_char)
            )
        end
      end
    end
  end

  describe '#escape=' do
    context 'when setting to a boolean value' do
      it 'sets escape to true' do
        options = described_class.new(escape: false)
        options.escape = true

        expect(options.escape).to be(true)
      end

      it 'sets escape to false' do
        options = described_class.new(escape: true)
        options.escape = false

        expect(options.escape).to be(false)
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(escape: !default_parameters[:escape])
        options.escape = nil

        expect(options.escape).to eq(default_parameters[:escape])
      end
    end

    context 'when setting to a non-boolean value' do
      it 'coerces an object to true' do
        options = described_class.new(escape: false)
        options.escape = { not: 'a boolean' }

        expect(options.escape).to be(true)
      end

      it 'coerces a truthy string to true' do
        options = described_class.new(escape: false)
        options.escape = 'not a boolean'

        expect(options.escape).to be(true)
      end

      it 'coerces a truthy number to true' do
        options = described_class.new(escape: false)
        options.escape = 123

        expect(options.escape).to be(true)
      end

      it 'coerces an empty string to false' do
        options = described_class.new(escape: false)
        options.escape = ''

        expect(options.escape).to be(false)
      end

      it 'coerces zero to false' do
        options = described_class.new(escape: false)
        options.escape = 0

        expect(options.escape).to be(false)
      end
    end
  end

  describe '#encode=' do
    context 'when setting to a boolean value' do
      it 'sets encode to true' do
        options = described_class.new(encode: false)
        options.encode = true

        expect(options.encode).to be(true)
      end

      it 'sets encode to false' do
        options = described_class.new(encode: true)
        options.encode = false

        expect(options.encode).to be(false)
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default value' do
        options = described_class.new(encode: !default_parameters[:encode])
        options.encode = nil

        expect(options.encode).to eq(default_parameters[:encode])
      end
    end

    context 'when setting to a non-boolean value' do
      it 'coerces an object to true' do
        options = described_class.new(encode: false)
        options.encode = { not: 'a boolean' }

        expect(options.encode).to be(true)
      end

      it 'coerces a truthy string to true' do
        options = described_class.new(encode: false)
        options.encode = 'not a boolean'

        expect(options.encode).to be(true)
      end

      it 'coerces a truthy number to true' do
        options = described_class.new(encode: false)
        options.encode = 123

        expect(options.encode).to be(true)
      end

      it 'coerces an empty string to false' do
        options = described_class.new(encode: false)
        options.encode = ''

        expect(options.encode).to be(false)
      end

      it 'coerces zero to false' do
        options = described_class.new(encode: false)
        options.encode = 0

        expect(options.encode).to be(false)
      end
    end
  end

  describe '#on_fail=' do
    context 'when using the default callback value' do
      it 'returns an empty string' do
        expect(described_class::DEFAULT_ON_FAIL.call('some value')).to eq('')
      end
    end

    context 'when setting to a callable value' do
      it 'sets on_fail to the provided callback' do
        callback = ->(value, _error) { "ERROR: #{value}" }
        options = described_class.new
        options.on_fail = callback

        expect(options.on_fail).to equal(callback)
      end
    end

    context 'when setting to a nil value' do
      it 'restores the default callback' do
        callback = ->(value, _error) { "ERROR: #{value}" }
        options = described_class.new(on_fail: callback)
        options.on_fail = nil

        expect(options.on_fail).to equal(default_parameters[:on_fail])
      end
    end

    context 'when setting to a non-callable value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.on_fail = { not: 'a function' } }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "on_fail" must be of type function. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a string' do
        options = described_class.new

        expect { options.on_fail = 'not a function' }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "on_fail" must be of type function. Got string.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.on_fail = 123 }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "on_fail" must be of type function. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.on_fail = true }
          .to raise_error(
            CnpjFmt::TypeMismatchError,
            'CNPJ formatting option "on_fail" must be of type function. Got boolean.'
          )
      end
    end
  end

  describe '#all' do
    it 'returns all properties with expected types' do
      all_options = described_class.new.all

      aggregate_failures do
        expect([true, false]).to include(all_options[:hidden])
        expect(all_options[:hidden_key]).to be_a(String)
        expect(all_options[:hidden_start]).to be_a(Integer)
        expect(all_options[:hidden_end]).to be_a(Integer)
        expect(all_options[:dot_key]).to be_a(String)
        expect(all_options[:slash_key]).to be_a(String)
        expect(all_options[:dash_key]).to be_a(String)
        expect([true, false]).to include(all_options[:escape])
        expect([true, false]).to include(all_options[:encode])
        expect(all_options[:on_fail]).to be_a(Proc)
      end
    end
  end

  describe '#set_hidden_range' do
    context 'when called with valid values' do
      it 'sets hidden_start and hidden_end' do
        options = described_class.new
        options.set_hidden_range(0, 10)

        aggregate_failures do
          expect(options.hidden_start).to eq(0)
          expect(options.hidden_end).to eq(10)
        end
      end

      context 'when hidden_start equals hidden_end' do
        it 'accepts 0 for both ends' do
          options = described_class.new
          options.set_hidden_range(0, 0)

          aggregate_failures do
            expect(options.hidden_start).to eq(0)
            expect(options.hidden_end).to eq(0)
          end
        end

        it 'accepts 13 for both ends' do
          options = described_class.new
          options.set_hidden_range(13, 13)

          aggregate_failures do
            expect(options.hidden_start).to eq(13)
            expect(options.hidden_end).to eq(13)
          end
        end
      end

      context 'when hidden_start is greater than hidden_end' do
        it 'swaps start and end values' do
          options = described_class.new
          options.set_hidden_range(8, 2)

          aggregate_failures do
            expect(options.hidden_start).to eq(2)
            expect(options.hidden_end).to eq(8)
          end
        end
      end
    end

    context 'when called with nil values' do
      it 'restores default values for both fields' do
        options = described_class.new
        options.set_hidden_range(nil, nil)

        aggregate_failures do
          expect(options.hidden_start).to eq(default_parameters[:hidden_start])
          expect(options.hidden_end).to eq(default_parameters[:hidden_end])
        end
      end

      context 'when hidden_start is nil' do
        it 'restores hidden_start and keeps hidden_end' do
          options = described_class.new(hidden_start: 0)
          options.set_hidden_range(nil, 13)

          aggregate_failures do
            expect(options.hidden_start).to eq(default_parameters[:hidden_start])
            expect(options.hidden_end).to eq(13)
          end
        end
      end

      context 'when hidden_end is nil' do
        it 'keeps hidden_start and restores hidden_end' do
          options = described_class.new(hidden_end: 13)
          options.set_hidden_range(0, nil)

          aggregate_failures do
            expect(options.hidden_start).to eq(0)
            expect(options.hidden_end).to eq(default_parameters[:hidden_end])
          end
        end
      end
    end

    context 'when called with invalid values' do
      context 'when hidden_start is out of range' do
        it 'raises OutOfRangeError for -1' do
          options = described_class.new

          expect { options.set_hidden_range(-1, 13) }
            .to raise_error(
              CnpjFmt::OutOfRangeError,
              'CNPJ formatting option "hidden_start" must be an integer between 0 and 13. Got -1.'
            )
        end

        it 'raises OutOfRangeError for 14' do
          options = described_class.new

          expect { options.set_hidden_range(14, 13) }
            .to raise_error(
              CnpjFmt::OutOfRangeError,
              'CNPJ formatting option "hidden_start" must be an integer between 0 and 13. Got 14.'
            )
        end
      end

      context 'when hidden_end is out of range' do
        it 'raises OutOfRangeError for -1' do
          options = described_class.new

          expect { options.set_hidden_range(0, -1) }
            .to raise_error(
              CnpjFmt::OutOfRangeError,
              'CNPJ formatting option "hidden_end" must be an integer between 0 and 13. Got -1.'
            )
        end

        it 'raises OutOfRangeError for 14' do
          options = described_class.new

          expect { options.set_hidden_range(0, 14) }
            .to raise_error(
              CnpjFmt::OutOfRangeError,
              'CNPJ formatting option "hidden_end" must be an integer between 0 and 13. Got 14.'
            )
        end
      end

      context 'when hidden_start is not an integer' do
        it 'raises TypeMismatchError for an object' do
          options = described_class.new

          expect { options.set_hidden_range({ not: 'a number' }, 13) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_start" must be of type integer. Got hash.'
            )
        end

        it 'raises TypeMismatchError for a string' do
          options = described_class.new

          expect { options.set_hidden_range('not a number', 13) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_start" must be of type integer. Got string.'
            )
        end

        it 'raises TypeMismatchError for a boolean' do
          options = described_class.new

          expect { options.set_hidden_range(true, 13) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_start" must be of type integer. Got boolean.'
            )
        end

        it 'raises TypeMismatchError for a float' do
          options = described_class.new

          expect { options.set_hidden_range(1.5, 13) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_start" must be of type integer. Got float number.'
            )
        end
      end

      context 'when hidden_end is not an integer' do
        it 'raises TypeMismatchError for an object' do
          options = described_class.new

          expect { options.set_hidden_range(0, { not: 'a number' }) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_end" must be of type integer. Got hash.'
            )
        end

        it 'raises TypeMismatchError for a string' do
          options = described_class.new

          expect { options.set_hidden_range(0, 'not a number') }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_end" must be of type integer. Got string.'
            )
        end

        it 'raises TypeMismatchError for a boolean' do
          options = described_class.new

          expect { options.set_hidden_range(0, true) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_end" must be of type integer. Got boolean.'
            )
        end

        it 'raises TypeMismatchError for a float' do
          options = described_class.new

          expect { options.set_hidden_range(0, 1.5) }
            .to raise_error(
              CnpjFmt::TypeMismatchError,
              'CNPJ formatting option "hidden_end" must be of type integer. Got float number.'
            )
        end
      end
    end
  end
end
