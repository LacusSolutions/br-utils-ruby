# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjVal::CnpjValidatorOptions do
  let(:default_parameters) do
    {
      case_sensitive: described_class::DEFAULT_CASE_SENSITIVE,
      type: described_class::DEFAULT_TYPE
    }
  end

  describe '#initialize' do
    context 'when called with no parameters' do
      it 'sets all options to default values' do
        expect(described_class.new.all).to eq(default_parameters)
      end
    end

    context 'when called with all parameters set to nil' do
      it 'sets all options to default values' do
        options = described_class.new(case_sensitive: nil, type: nil)

        expect(options.all).to eq(default_parameters)
      end
    end

    context 'when called with all parameters' do
      it 'sets all options to the provided values' do
        parameters = {
          case_sensitive: true,
          type: 'numeric'
        }

        expect(described_class.new(parameters).all).to eq(parameters)
      end
    end

    context 'when called with some parameters' do
      it 'sets only the provided non-nil values' do
        options = described_class.new(type: 'numeric')

        expect(options.all).to eq(default_parameters.merge(type: 'numeric'))
      end
    end

    context 'when called with a CnpjValidatorOptions instance' do
      it 'creates a new instance with the same values' do
        original_options = described_class.new(case_sensitive: true, type: 'numeric')

        options = described_class.new(original_options)

        aggregate_failures do
          expect(options).not_to equal(original_options)
          expect(options.all).to eq(original_options.all)
        end
      end
    end

    context 'when called with override parameters' do
      it 'uses the last option with two params' do
        options = described_class.new({ type: 'numeric' }, { type: 'alphanumeric' })

        expect(options.type).to eq('alphanumeric')
      end

      it 'uses the last option with five params' do
        options = described_class.new(
          { type: 'numeric' },
          { type: 'alphanumeric' },
          { type: 'numeric' },
          { type: 'alphanumeric' },
          { type: 'numeric' }
        )

        expect(options.type).to eq('numeric')
      end
    end
  end

  describe '#case_sensitive=' do
    context 'when setting to a boolean value' do
      it 'sets case_sensitive to true' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = true

        expect(options.case_sensitive).to be(true)
      end

      it 'sets case_sensitive to false' do
        options = described_class.new(case_sensitive: true)

        options.case_sensitive = false

        expect(options.case_sensitive).to be(false)
      end
    end

    context 'when setting to a nilish value' do
      it 'sets default value for nil' do
        options = described_class.new(case_sensitive: !default_parameters[:case_sensitive])

        options.case_sensitive = nil

        expect(options.case_sensitive).to eq(default_parameters[:case_sensitive])
      end
    end

    context 'when setting to a non-boolean value' do
      it 'coerces object value to true' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = { not: 'a boolean' }

        expect(options.case_sensitive).to be(true)
      end

      it 'coerces truthy string value to true' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = 'not a boolean'

        expect(options.case_sensitive).to be(true)
      end

      it 'coerces truthy number value to true' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = 123

        expect(options.case_sensitive).to be(true)
      end

      it 'coerces empty string value to false' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = ''

        expect(options.case_sensitive).to be(false)
      end

      it 'coerces zero number value to false' do
        options = described_class.new(case_sensitive: false)

        options.case_sensitive = 0

        expect(options.case_sensitive).to be(false)
      end
    end
  end

  describe '#type=' do
    context 'when setting to a valid option value' do
      %w[alphanumeric numeric].each do |type_value|
        it "sets type to #{type_value}" do
          options = described_class.new(type: type_value)

          options.type = type_value

          expect(options.type).to eq(type_value)
        end
      end
    end

    context 'when setting to a nilish value' do
      it 'sets default value for nil' do
        options = described_class.new(type: 'numeric')

        options.type = nil

        expect(options.type).to eq(default_parameters[:type])
      end
    end

    context 'when setting to a non-string value' do
      it 'raises TypeMismatchError for an object' do
        options = described_class.new

        expect { options.type = { not: 'a string' } }
          .to raise_error(
            CnpjVal::TypeMismatchError,
            'CNPJ validator option "type" must be of type string. Got hash.'
          )
      end

      it 'raises TypeMismatchError for a number' do
        options = described_class.new

        expect { options.type = 123 }
          .to raise_error(
            CnpjVal::TypeMismatchError,
            'CNPJ validator option "type" must be of type string. Got integer number.'
          )
      end

      it 'raises TypeMismatchError for a boolean' do
        options = described_class.new

        expect { options.type = true }
          .to raise_error(
            CnpjVal::TypeMismatchError,
            'CNPJ validator option "type" must be of type string. Got boolean.'
          )
      end
    end

    context 'when setting to an invalid option' do
      it 'raises ValidationError with unexpected value' do
        options = described_class.new

        expect { options.type = 'something' }
          .to raise_error(
            CnpjVal::ValidationError,
            'CNPJ validator option "type" accepts only the following values: ' \
            '"alphanumeric", "numeric". Got "something".'
          )
      end
    end
  end

  describe '#all' do
    it 'returns all properties' do
      options = described_class.new

      aggregate_failures do
        expect([true, false]).to include(options.all[:case_sensitive])
        expect(options.all[:type]).to be_a(String)
      end
    end
  end
end
