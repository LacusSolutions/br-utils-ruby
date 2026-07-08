# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjDV::CnpjCheckDigitsTypeError do
  before do
    stub_const('CnpjDV::TestTypeError', Class.new(described_class))
  end

  subject(:error) { CnpjDV::TestTypeError.new(123, 'number', 'string', 'some error') }

  context 'when instantiated through a subclass' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjCheckDigitsTypeError' do
      expect(error).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjDV::TestTypeError')
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

RSpec.describe CnpjDV::CnpjCheckDigitsInputTypeError do
  subject(:error) { described_class.new(123, 'string') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjCheckDigitsTypeError' do
      expect(error).to be_a(CnpjDV::CnpjCheckDigitsTypeError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjDV::CnpjCheckDigitsInputTypeError')
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

    it 'builds a descriptive message' do
      expect(described_class.new(123, 'string[]').message)
        .to eq('CNPJ input must be of type string[]. Got integer number.')
    end
  end
end

RSpec.describe CnpjDV::CnpjCheckDigitsException do
  before do
    stub_const('CnpjDV::TestException', Class.new(described_class))
  end

  subject(:exception) { CnpjDV::TestException.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjCheckDigitsException' do
      expect(exception).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(exception.class.name).to eq('CnpjDV::TestException')
    end

    it 'exposes the message' do
      expect(exception.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjDV::CnpjCheckDigitsInputLengthException do
  subject(:exception) do
    described_class.new('1.2.3.4.5', '12345', 12, 14)
  end

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjCheckDigitsException' do
      expect(exception).to be_a(CnpjDV::CnpjCheckDigitsException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjDV::CnpjCheckDigitsInputLengthException')
    end

    it 'sets actual_input' do
      expect(exception.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets evaluated_input' do
      expect(exception.evaluated_input).to eq('12345')
    end

    it 'sets min_expected_length' do
      expect(exception.min_expected_length).to eq(12)
    end

    it 'sets max_expected_length' do
      expect(exception.max_expected_length).to eq(14)
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'CNPJ input "1.2.3.4.5" does not contain 12 to 14 characters. Got 5 in "12345".'
      )
    end
  end
end

RSpec.describe CnpjDV::CnpjCheckDigitsInputInvalidException do
  subject(:exception) do
    described_class.new('1.2.3.4.5', 'repeated digits')
  end

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjCheckDigitsException' do
      expect(exception).to be_a(CnpjDV::CnpjCheckDigitsException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjDV::CnpjCheckDigitsInputInvalidException')
    end

    it 'sets actual_input' do
      expect(exception.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets reason' do
      expect(exception.reason).to eq('repeated digits')
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'CNPJ input "1.2.3.4.5" is invalid. repeated digits'
      )
    end
  end
end
