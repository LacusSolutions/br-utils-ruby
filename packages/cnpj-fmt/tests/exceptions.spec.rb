# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjFmt::Error do
  it 'is a module' do
    expect(described_class).to be_a(Module)
    expect(described_class).not_to be_a(Class)
  end
end

RSpec.describe CnpjFmt::TypeMismatchError do
  context 'when instantiated for CNPJ input' do
    subject(:error) { described_class.new(123, 'string') }

    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'includes CnpjFmt::Error' do
      expect(error).to be_a(CnpjFmt::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::TypeMismatchError')
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
      expect(described_class.new(123, 'string[]').message)
        .to eq('CNPJ input must be of type string[]. Got integer number.')
    end
  end

  context 'when instantiated for an option' do
    subject(:error) { described_class.new(123, 'boolean', option_name: 'hidden') }

    it 'sets option_name' do
      expect(described_class.new(123, 'string', option_name: 'hidden_key').option_name)
        .to eq('hidden_key')
    end

    it 'sets actual_input' do
      expect(described_class.new(123, 'string', option_name: 'hidden_key').actual_input)
        .to eq(123)
    end

    it 'sets actual_type' do
      expect(described_class.new(123, 'string', option_name: 'hidden_key').actual_type)
        .to eq('integer number')
    end

    it 'sets expected_type' do
      expect(described_class.new(123, 'string', option_name: 'hidden_key').expected_type)
        .to eq('string')
    end

    it 'builds a descriptive message' do
      expect(described_class.new(123, 'string', option_name: 'hidden_key').message).to eq(
        'CNPJ formatting option "hidden_key" must be of type string. Got integer number.'
      )
    end
  end
end

RSpec.describe CnpjFmt::MissingArgumentError do
  subject(:error) { described_class.new('missing') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CnpjFmt::Error' do
    expect(error).to be_a(CnpjFmt::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CnpjFmt::DomainError)
  end
end

RSpec.describe CnpjFmt::InvalidArgumentCombinationError do
  subject(:error) { described_class.new('invalid combination') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CnpjFmt::Error' do
    expect(error).to be_a(CnpjFmt::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CnpjFmt::DomainError)
  end
end

RSpec.describe CnpjFmt::DomainError do
  before do
    stub_const('CnpjFmt::TestDomainError', Class.new(described_class))
  end

  subject(:error) { CnpjFmt::TestDomainError.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(described_class)
    end

    it 'includes CnpjFmt::Error' do
      expect(error).to be_a(CnpjFmt::Error)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjFmt::TestDomainError')
    end

    it 'exposes the message' do
      expect(error.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjFmt::OutOfRangeError do
  subject(:error) { described_class.new('hidden_start', 20, 5, 13) }

  context 'when instantiated' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(CnpjFmt::DomainError)
    end

    it 'includes CnpjFmt::Error' do
      expect(error).to be_a(CnpjFmt::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::OutOfRangeError')
    end

    it 'sets option_name' do
      expect(error.option_name).to eq('hidden_start')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq(20)
    end

    it 'sets min_expected_value' do
      expect(error.min_expected_value).to eq(5)
    end

    it 'sets max_expected_value' do
      expect(error.max_expected_value).to eq(13)
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CNPJ formatting option "hidden_start" must be an integer between 5 and 13. Got 20.'
      )
    end
  end
end

RSpec.describe CnpjFmt::InvalidLengthError do
  subject(:error) { described_class.new('1.2.3.4.5', '12345', 14) }

  context 'when instantiated' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(CnpjFmt::DomainError)
    end

    it 'includes CnpjFmt::Error' do
      expect(error).to be_a(CnpjFmt::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::InvalidLengthError')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets evaluated_input' do
      expect(error.evaluated_input).to eq('12345')
    end

    it 'sets expected_length' do
      expect(error.expected_length).to eq(14)
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CNPJ input "1.2.3.4.5" does not contain 14 characters. Got 5 in "12345".'
      )
    end

    it 'summarizes sequence input without serializing contents' do
      sequence_error = described_class.new(%w[12 345], '12345', 14)

      aggregate_failures do
        expect(sequence_error.actual_input).to eq(%w[12 345])
        expect(sequence_error.message).to eq(
          'CNPJ input sequence[2] does not contain 14 characters. Got 5 in "12345".'
        )
      end
    end
  end
end

RSpec.describe CnpjFmt::ValidationError do
  subject(:error) do
    described_class.new('dot_key', 'å', %w[å ë ï ö])
  end

  context 'when instantiated' do
    it 'is an ArgumentError' do
      expect(error).to be_a(ArgumentError)
    end

    it 'includes CnpjFmt::Error' do
      expect(error).to be_a(CnpjFmt::Error)
    end

    it 'is not a DomainError' do
      expect(error).not_to be_a(CnpjFmt::DomainError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjFmt::ValidationError')
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
      expect(error.message).to eq(
        'Value "å" for CNPJ formatting option "dot_key" contains disallowed characters ("å", "ë", "ï", "ö").'
      )
    end
  end
end
