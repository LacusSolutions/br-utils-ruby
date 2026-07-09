# frozen_string_literal: true

require 'spec_helper'

TYPE_INVALID_EXPECTED_VALUES = %w[alphabetic alphanumeric numeric].freeze

RSpec.describe CnpjGen::CnpjGeneratorTypeError do
  before do
    stub_const('CnpjGen::TestTypeError', Class.new(described_class))
  end

  subject(:error) { CnpjGen::TestTypeError.new(123, 'number', 'string', 'some error') }

  context 'when instantiated through a subclass' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjGeneratorTypeError' do
      expect(error).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjGen::TestTypeError')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq(123)
    end

    it 'sets actual_type' do
      expect(error.actual_type).to eq('number')
    end

    it 'sets expected_type' do
      expect(error.expected_type).to eq('string')
    end

    it 'exposes the message' do
      expect(error.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjGen::CnpjGeneratorOptionsTypeError do
  subject(:error) { described_class.new('format', 123, 'string') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjGeneratorTypeError' do
      expect(error).to be_a(CnpjGen::CnpjGeneratorTypeError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjGen::CnpjGeneratorOptionsTypeError')
    end

    it 'sets option_name' do
      expect(described_class.new('prefix', 123, 'string').option_name).to eq('prefix')
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
        'CNPJ generator option "format" must be of type string. Got integer number.'
      )
    end
  end
end

RSpec.describe CnpjGen::CnpjGeneratorException do
  before do
    stub_const('CnpjGen::TestException', Class.new(described_class))
  end

  subject(:exception) { CnpjGen::TestException.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjGeneratorException' do
      expect(exception).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(exception.class.name).to eq('CnpjGen::TestException')
    end

    it 'exposes the message' do
      expect(exception.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjGen::CnpjGeneratorOptionPrefixInvalidException do
  subject(:exception) { described_class.new('1.2.3.4.5', 'repeated digits') }

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjGeneratorException' do
      expect(exception).to be_a(CnpjGen::CnpjGeneratorException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjGen::CnpjGeneratorOptionPrefixInvalidException')
    end

    it 'sets actual_input' do
      expect(described_class.new('77777777', 'repeated digits').actual_input).to eq('77777777')
    end

    it 'sets reason' do
      expect(exception.reason).to eq('repeated digits')
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'CNPJ generator option "prefix" with value "1.2.3.4.5" is invalid. repeated digits'
      )
    end
  end
end

RSpec.describe CnpjGen::CnpjGeneratorOptionTypeInvalidException do
  subject(:exception) { described_class.new('boolean', TYPE_INVALID_EXPECTED_VALUES) }

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjGeneratorException' do
      expect(exception).to be_a(CnpjGen::CnpjGeneratorException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjGen::CnpjGeneratorOptionTypeInvalidException')
    end

    it 'sets actual_input' do
      expect(exception.actual_input).to eq('boolean')
    end

    it 'sets expected_values' do
      expect(exception.expected_values).to eq(TYPE_INVALID_EXPECTED_VALUES)
    end

    it 'builds a descriptive message' do
      expected_values_string = TYPE_INVALID_EXPECTED_VALUES.map { |value| %("#{value}") }.join(', ')

      expect(exception.message).to eq(
        %(CNPJ generator option "type" accepts only the following values: #{expected_values_string}. Got "boolean".)
      )
    end
  end
end
