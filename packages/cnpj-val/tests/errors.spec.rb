# frozen_string_literal: true

require 'spec_helper'

# Deliberately independent of CnpjVal::CNPJ_TYPE_OPTIONS so production changes fail loudly.
TYPE_INVALID_EXPECTED_VALUES = %w[alphanumeric numeric].freeze

RSpec.describe CnpjVal::Error do
  it 'is a module' do
    expect(described_class).to be_a(Module)
    expect(described_class).not_to be_a(Class)
  end
end

RSpec.describe CnpjVal::TypeMismatchError do
  context 'when instantiated for CNPJ input' do
    subject(:error) { described_class.new(123, 'string') }

    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'includes CnpjVal::Error' do
      expect(error).to be_a(CnpjVal::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjVal::TypeMismatchError')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq(123)
    end

    it 'sets actual_type' do
      expect(error.actual_type).to eq('integer number')
    end

    it 'sets expected_type' do
      expect(described_class.new(123, 'string or string[]').expected_type)
        .to eq('string or string[]')
    end

    it 'leaves option_name nil' do
      expect(error.option_name).to be_nil
    end

    it 'builds a descriptive message' do
      expect(described_class.new(123, 'string').message)
        .to eq('CNPJ input must be of type string. Got integer number.')
    end
  end

  context 'when instantiated for an option' do
    subject(:error) { described_class.new(123, 'string', option_name: 'type') }

    it 'sets option_name' do
      expect(error.option_name).to eq('type')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq(123)
    end

    it 'sets actual_type' do
      expect(error.actual_type).to eq('integer number')
    end

    it 'sets expected_type' do
      expect(error.expected_type).to eq('string')
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CNPJ validator option "type" must be of type string. Got integer number.'
      )
    end
  end
end

RSpec.describe CnpjVal::InvalidArgumentCombinationError do
  subject(:error) { described_class.new('invalid combination') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CnpjVal::Error' do
    expect(error).to be_a(CnpjVal::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CnpjVal::DomainError)
  end
end

RSpec.describe CnpjVal::DomainError do
  before do
    stub_const('CnpjVal::TestDomainError', Class.new(described_class))
  end

  subject(:error) { CnpjVal::TestDomainError.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(described_class)
    end

    it 'includes CnpjVal::Error' do
      expect(error).to be_a(CnpjVal::Error)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjVal::TestDomainError')
    end

    it 'exposes the message' do
      expect(error.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjVal::ValidationError do
  subject(:error) { described_class.new('type', 'boolean', expected_values: TYPE_INVALID_EXPECTED_VALUES) }

  context 'when instantiated' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(CnpjVal::DomainError)
    end

    it 'includes CnpjVal::Error' do
      expect(error).to be_a(CnpjVal::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjVal::ValidationError')
    end

    it 'sets option_name' do
      expect(error.option_name).to eq('type')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq('boolean')
    end

    it 'sets expected_values' do
      expect(error.expected_values).to eq(TYPE_INVALID_EXPECTED_VALUES)
    end

    it 'freezes expected_values' do
      expect(error.expected_values).to be_frozen
    end

    it 'builds a descriptive message' do
      expected_values_string = TYPE_INVALID_EXPECTED_VALUES.map { |value| %("#{value}") }.join(', ')

      expect(error.message).to eq(
        %(CNPJ validator option "type" accepts only the following values: #{expected_values_string}. Got "boolean".)
      )
    end
  end
end
