# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjFmt::CnpjFormatterTypeError do
  before do
    stub_const('CnpjFmt::TestTypeError', Class.new(described_class))
  end

  subject(:error) { CnpjFmt::TestTypeError.new(123, 'number', 'string', 'some error') }

  context 'when instantiated through a subclass' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjFormatterTypeError' do
      expect(error).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjFmt::TestTypeError')
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

RSpec.describe CnpjFmt::CnpjFormatterInputTypeError do
  subject(:error) { described_class.new(123, 'string') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjFormatterTypeError' do
      expect(error).to be_a(CnpjFmt::CnpjFormatterTypeError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::CnpjFormatterInputTypeError')
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

RSpec.describe CnpjFmt::CnpjFormatterOptionsTypeError do
  subject(:error) { described_class.new('hidden', 123, 'boolean') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'is a CnpjFormatterTypeError' do
      expect(error).to be_a(CnpjFmt::CnpjFormatterTypeError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::CnpjFormatterOptionsTypeError')
    end

    it 'sets option_name' do
      expect(described_class.new('hidden_key', 123, 'string').option_name).to eq('hidden_key')
    end

    it 'sets actual_input' do
      expect(described_class.new('hidden_key', 123, 'string').actual_input).to eq(123)
    end

    it 'sets actual_type' do
      expect(described_class.new('hidden_key', 123, 'string').actual_type).to eq('integer number')
    end

    it 'sets expected_type' do
      expect(described_class.new('hidden_key', 123, 'string').expected_type).to eq('string')
    end

    it 'builds a descriptive message' do
      expect(described_class.new('hidden_key', 123, 'string').message).to eq(
        'CNPJ formatting option "hidden_key" must be of type string. Got integer number.'
      )
    end
  end
end

RSpec.describe CnpjFmt::CnpjFormatterException do
  before do
    stub_const('CnpjFmt::TestException', Class.new(described_class))
  end

  subject(:exception) { CnpjFmt::TestException.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjFormatterException' do
      expect(exception).to be_a(described_class)
    end

    it 'exposes the subclass name' do
      expect(exception.class.name).to eq('CnpjFmt::TestException')
    end

    it 'exposes the message' do
      expect(exception.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjFmt::CnpjFormatterInputLengthException do
  subject(:exception) { described_class.new('1.2.3.4.5', '12345', 14) }

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjFormatterException' do
      expect(exception).to be_a(CnpjFmt::CnpjFormatterException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjFmt::CnpjFormatterInputLengthException')
    end

    it 'sets actual_input' do
      expect(exception.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets evaluated_input' do
      expect(exception.evaluated_input).to eq('12345')
    end

    it 'sets expected_length' do
      expect(exception.expected_length).to eq(14)
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'CNPJ input "1.2.3.4.5" does not contain 14 characters. Got 5 in "12345".'
      )
    end

    it 'summarizes sequence input without serializing contents' do
      sequence_exception = described_class.new(%w[12 345], '12345', 14)

      aggregate_failures do
        expect(sequence_exception.actual_input).to eq(%w[12 345])
        expect(sequence_exception.message).to eq(
          'CNPJ input sequence[2] does not contain 14 characters. Got 5 in "12345".'
        )
      end
    end
  end
end

RSpec.describe CnpjFmt::CnpjFormatterOptionsHiddenRangeInvalidException do
  subject(:exception) { described_class.new('hidden_start', 20, 5, 13) }

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjFormatterException' do
      expect(exception).to be_a(CnpjFmt::CnpjFormatterException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjFmt::CnpjFormatterOptionsHiddenRangeInvalidException')
    end

    it 'sets option_name' do
      expect(exception.option_name).to eq('hidden_start')
    end

    it 'sets actual_input' do
      expect(exception.actual_input).to eq(20)
    end

    it 'sets min_expected_value' do
      expect(exception.min_expected_value).to eq(5)
    end

    it 'sets max_expected_value' do
      expect(exception.max_expected_value).to eq(13)
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'CNPJ formatting option "hidden_start" must be an integer between 5 and 13. Got 20.'
      )
    end
  end
end

RSpec.describe CnpjFmt::CnpjFormatterOptionsForbiddenKeyCharacterException do
  subject(:exception) do
    described_class.new('dot_key', 'å', %w[å ë ï ö])
  end

  context 'when instantiated' do
    it 'is a StandardError' do
      expect(exception).to be_a(StandardError)
    end

    it 'is a CnpjFormatterException' do
      expect(exception).to be_a(CnpjFmt::CnpjFormatterException)
    end

    it 'exposes the class name' do
      expect(exception.class.name).to eq('CnpjFmt::CnpjFormatterOptionsForbiddenKeyCharacterException')
    end

    it 'sets option_name' do
      expect(described_class.new('hidden_key', 'x', ['x']).option_name).to eq('hidden_key')
    end

    it 'sets actual_input' do
      expect(described_class.new('slash_key', '/', ['/']).actual_input).to eq('/')
    end

    it 'sets forbidden_characters' do
      expect(described_class.new('dash_key', 'å', %w[å ë ï ö]).forbidden_characters)
        .to eq(%w[å ë ï ö])
    end

    it 'builds a descriptive message' do
      expect(exception.message).to eq(
        'Value "å" for CNPJ formatting option "dot_key" contains disallowed characters ("å", "ë", "ï", "ö").'
      )
    end
  end
end
