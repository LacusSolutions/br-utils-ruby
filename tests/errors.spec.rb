# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfGen::Error do
  it 'is a module' do
    expect(described_class).to be_a(Module)
    expect(described_class).not_to be_a(Class)
  end
end

RSpec.describe CpfGen::TypeMismatchError do
  subject(:error) { described_class.new(123, 'string', option_name: 'format') }

  context 'when instantiated' do
    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'includes CpfGen::Error' do
      expect(error).to be_a(CpfGen::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CpfGen::TypeMismatchError')
    end

    it 'sets option_name' do
      expect(described_class.new(123, 'string', option_name: 'prefix').option_name).to eq('prefix')
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
        'CPF generator option "format" must be of type string. Got integer number.'
      )
    end
  end
end

RSpec.describe CpfGen::InvalidArgumentCombinationError do
  subject(:error) { described_class.new('invalid combination') }

  it 'is an ArgumentError' do
    expect(error).to be_a(ArgumentError)
  end

  it 'includes CpfGen::Error' do
    expect(error).to be_a(CpfGen::Error)
  end

  it 'is not a DomainError' do
    expect(error).not_to be_a(CpfGen::DomainError)
  end
end

RSpec.describe CpfGen::DomainError do
  before do
    stub_const('CpfGen::TestDomainError', Class.new(described_class))
  end

  subject(:error) { CpfGen::TestDomainError.new('some error') }

  context 'when instantiated through a subclass' do
    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(described_class)
    end

    it 'includes CpfGen::Error' do
      expect(error).to be_a(CpfGen::Error)
    end

    it 'exposes the subclass name' do
      expect(error.class.name).to eq('CpfGen::TestDomainError')
    end

    it 'exposes the message' do
      expect(error.message).to eq('some error')
    end
  end
end

RSpec.describe CpfGen::ValidationError do
  context 'when instantiated for an invalid prefix' do
    subject(:error) { described_class.new('prefix', '1.2.3.4.5', reason: 'repeated digits') }

    it 'is a RangeError' do
      expect(error).to be_a(RangeError)
    end

    it 'is a DomainError' do
      expect(error).to be_a(CpfGen::DomainError)
    end

    it 'includes CpfGen::Error' do
      expect(error).to be_a(CpfGen::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CpfGen::ValidationError')
    end

    it 'sets option_name' do
      expect(error.option_name).to eq('prefix')
    end

    it 'sets actual_input' do
      expect(described_class.new('prefix', '77777777', reason: 'repeated digits').actual_input)
        .to eq('77777777')
    end

    it 'sets reason' do
      expect(error.reason).to eq('repeated digits')
    end

    it 'leaves expected_values nil' do
      expect(error.expected_values).to be_nil
    end

    it 'builds a descriptive message' do
      expect(error.message).to eq(
        'CPF generator option "prefix" with value "1.2.3.4.5" is invalid. repeated digits'
      )
    end
  end
end
