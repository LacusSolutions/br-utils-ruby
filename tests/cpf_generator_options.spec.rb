# frozen_string_literal: true

require 'spec_helper'

CPF_GENERATOR_OPTIONS_REPEATED_DIGIT_PREFIXES = %w[
  111111111
  222222222
  333333333
  444444444
  555555555
  666666666
  777777777
  888888888
  999999999
].freeze

RSpec.describe CpfGen::CpfGeneratorOptions do
  def expect_options_match(actual, expected)
    expected.each do |key, value|
      expect(actual[key]).to eq(value)
    end
  end

  let(:default_parameters) do
    {
      format: described_class::DEFAULT_FORMAT,
      prefix: described_class::DEFAULT_PREFIX
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
        options = described_class.new(format: nil, prefix: nil)

        expect_options_match(options.all, default_parameters)
      end
    end

    context 'when called with all parameters' do
      it 'sets all options to the provided values' do
        parameters = { format: true, prefix: '12345' }

        expect_options_match(described_class.new(parameters).all, parameters)
      end
    end

    context 'when called with some parameters' do
      it 'sets only the provided non-nil values' do
        options = described_class.new(format: true)

        expect_options_match(
          options.all,
          default_parameters.merge(format: true)
        )
      end
    end

    context 'when called with a CpfGeneratorOptions instance' do
      it 'creates a new instance with the same values' do
        original_options = described_class.new(format: true, prefix: '12345')
        options = described_class.new(original_options)

        aggregate_failures do
          expect(options).not_to equal(original_options)
          expect_options_match(options.all, original_options.all)
        end
      end
    end

    context 'when called with override parameters' do
      it 'uses the last option with two params' do
        options = described_class.new({ prefix: '12345' }, { prefix: '11222333' })

        expect(options.prefix).to eq('11222333')
      end

      it 'uses the last option with one hash and one instance' do
        options = described_class.new(
          { prefix: '12345' },
          described_class.new(prefix: '11222333')
        )

        expect(options.prefix).to eq('11222333')
      end

      it 'uses the last option with five params' do
        options = described_class.new(
          { prefix: '123456780009' },
          { prefix: '11' },
          { prefix: '22333' },
          { prefix: '44555666' },
          { prefix: '77888999' }
        )

        expect(options.prefix).to eq('77888999')
      end

      it 'ignores a nil value inside a later layer' do
        options = described_class.new({ prefix: '11222333' }, { prefix: nil })

        expect(options.prefix).to eq('11222333')
      end

      it 'gives keyword arguments precedence over every positional layer' do
        options = described_class.new({ prefix: '12345' }, { prefix: '11222333' }, prefix: '99999999')

        expect(options.prefix).to eq('99999999')
      end

      it 'ignores a nil keyword argument in favor of the positional layers' do
        options = described_class.new({ prefix: '11222333' }, prefix: nil)

        expect(options.prefix).to eq('11222333')
      end
    end
  end

  describe '#set' do
    context 'when called with partial overrides' do
      it 'updates only the provided keys and keeps current values' do
        options = described_class.new(format: true, prefix: '12345')
        options.set(prefix: '11222333')

        expect_options_match(options.all, format: true, prefix: '11222333')
      end

      it 'folds positional layers left to right then applies keywords' do
        options = described_class.new(format: false, prefix: '12345')
        options.set({ prefix: '11' }, { prefix: '22333' }, format: true)

        expect_options_match(options.all, format: true, prefix: '22333')
      end

      it 'ignores nil values and keeps the previously resolved value' do
        options = described_class.new(format: true, prefix: '12345')
        options.set(format: nil, prefix: '11222333')

        expect_options_match(options.all, format: true, prefix: '11222333')
      end

      it 'returns self' do
        options = described_class.new

        expect(options.set(format: true)).to equal(options)
      end
    end
  end

  describe '#format=' do
    context 'when setting to a boolean value' do
      it 'sets format to true' do
        options = described_class.new(format: false)
        options.format = true

        expect(options.format).to be(true)
      end

      it 'sets format to false' do
        options = described_class.new(format: true)
        options.format = false

        expect(options.format).to be(false)
      end
    end

    context 'when setting to a nil value' do
      it 'raises TypeMismatchError' do
        options = described_class.new(format: !described_class::DEFAULT_FORMAT)

        expect { options.format = nil }
          .to raise_error(
            CpfGen::TypeMismatchError,
            'CPF generator option "format" must be of type boolean. Got nil.'
          )
      end
    end

    context 'when setting to a non-boolean value' do
      it 'coerces an object to true' do
        options = described_class.new(format: false)
        options.format = { not: 'a boolean' }

        expect(options.format).to be(true)
      end

      it 'coerces a truthy string to true' do
        options = described_class.new(format: false)
        options.format = 'not a boolean'

        expect(options.format).to be(true)
      end

      it 'coerces a truthy number to true' do
        options = described_class.new(format: false)
        options.format = 123

        expect(options.format).to be(true)
      end

      it 'coerces an empty string to false' do
        options = described_class.new(format: false)
        options.format = ''

        expect(options.format).to be(false)
      end

      it 'coerces zero to false' do
        options = described_class.new(format: false)
        options.format = 0

        expect(options.format).to be(false)
      end
    end
  end

  describe '#prefix=' do
    context 'when setting to a valid string value' do
      it 'sets prefix to the provided value' do
        options = described_class.new(prefix: '12345')
        options.prefix = '11222333'

        expect(options.prefix).to eq('11222333')
      end

      it 'strips non-digit characters' do
        options = described_class.new
        options.prefix = '123.ABC.def'

        expect(options.prefix).to eq('123')
      end

      it 'truncates extra characters beyond 9' do
        options = described_class.new
        options.prefix = '12345678910'

        expect(options.prefix).to eq('123456789')
      end
    end

    context 'when setting to a nil value' do
      it 'raises TypeMismatchError' do
        options = described_class.new(prefix: '12345')

        expect { options.prefix = nil }
          .to raise_error(
            CpfGen::TypeMismatchError,
            'CPF generator option "prefix" must be of type string. Got nil.'
          )
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.prefix = { not: 'a string' } }
          .to raise_error(
            CpfGen::TypeMismatchError,
            'CPF generator option "prefix" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.prefix = 123 }
          .to raise_error(
            CpfGen::TypeMismatchError,
            'CPF generator option "prefix" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.prefix = true }
          .to raise_error(
            CpfGen::TypeMismatchError,
            'CPF generator option "prefix" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to an invalid string' do
      it 'raises for a zeroed base ID' do
        options = described_class.new

        expect { options.prefix = '000000000' }
          .to raise_error(
            CpfGen::ValidationError,
            'CPF generator option "prefix" with value "000000000" is invalid. ' \
            'Zeroed base ID is not eligible.'
          )
      end

      CPF_GENERATOR_OPTIONS_REPEATED_DIGIT_PREFIXES.each do |prefix|
        it "raises for repeated digits in #{prefix}" do
          options = described_class.new

          expect { options.prefix = prefix }
            .to raise_error(
              CpfGen::ValidationError,
              %(CPF generator option "prefix" with value "#{prefix}" is invalid. ) \
              'Repeated digits are not considered valid.'
            )
        end
      end
    end
  end

  describe '#all' do
    it 'returns all properties with expected types' do
      snapshot = described_class.new.all

      aggregate_failures do
        expect([true, false]).to include(snapshot[:format])
        expect(snapshot[:prefix]).to be_a(String)
      end
    end
  end
end
