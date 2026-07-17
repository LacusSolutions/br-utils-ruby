# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjDV::Error do
  it 'is a module' do
    expect(described_class).to be_a(Module)
    expect(described_class).not_to be_a(Class)
  end
end

RSpec.describe CnpjDV::TypeMismatchError do
  subject(:error) { described_class.new(123, 'string') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'includes CnpjDV::Error' do
      expect(error).to be_a(CnpjDV::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjDV::TypeMismatchError')
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

RSpec.describe CnpjDV::MissingArgumentError do
  subject(:error) { described_class.new('missing') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CnpjDV::Error' do
    expect(error).to be_a(CnpjDV::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CnpjDV::DomainError)
  end
end

RSpec.describe CnpjDV::InvalidArgumentCombinationError do
  subject(:error) { described_class.new('invalid combination') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CnpjDV::Error' do
    expect(error).to be_a(CnpjDV::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CnpjDV::DomainError)
  end
end

RSpec.describe CnpjDV::DomainError do
  before do
    stub_const('CnpjDV::TestDomainError', Class.new(described_class))
  end

  subject(:error) { CnpjDV::TestDomainError.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(described_class)
    end

    it 'includes CnpjDV::Error' do
      expect(error).to be_a(CnpjDV::Error)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CnpjDV::TestDomainError')
    end

    it 'exposes the message' do
      expect(error.message).to eq('some error')
    end
  end
end

RSpec.describe CnpjDV::OutOfRangeError do
  subject(:error) { described_class.new('out of range') }

  it 'is a DomainError' do
    expect(error).to be_a(CnpjDV::DomainError)
  end

  it 'is a RangeError' do
    expect(error).to be_a(RangeError)
  end

  it 'includes CnpjDV::Error' do
    expect(error).to be_a(CnpjDV::Error)
  end
end

RSpec.describe CnpjDV::InvalidLengthError do
  subject(:error) do
    described_class.new('1.2.3.4.5', '12345', 12, 14)
  end

  context 'when instantiated' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(CnpjDV::DomainError)
    end

    it 'includes CnpjDV::Error' do
      expect(error).to be_a(CnpjDV::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjDV::InvalidLengthError')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets evaluated_input' do
      expect(error.evaluated_input).to eq('12345')
    end

    it 'sets min_expected_length' do
      expect(error.min_expected_length).to eq(12)
    end

    it 'sets max_expected_length' do
      expect(error.max_expected_length).to eq(14)
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CNPJ input "1.2.3.4.5" does not contain 12 to 14 characters. Got 5 in "12345".'
      )
    end
  end
end

RSpec.describe CnpjDV::ValidationError do
  subject(:error) do
    described_class.new('1.2.3.4.5', 'repeated digits')
  end

  context 'when instantiated' do
    it 'is an ArgumentError' do
      expect(error).to be_a(ArgumentError)
    end

    it 'includes CnpjDV::Error' do
      expect(error).to be_a(CnpjDV::Error)
    end

    it 'is not a DomainError' do
      expect(error).not_to be_a(CnpjDV::DomainError)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CnpjDV::ValidationError')
    end

    it 'sets actual_input' do
      expect(error.actual_input).to eq('1.2.3.4.5')
    end

    it 'sets reason' do
      expect(error.reason).to eq('repeated digits')
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CNPJ input "1.2.3.4.5" is invalid. repeated digits'
      )
    end
  end
end
