# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfVal::Error do
  it 'is a module' do
    expect(described_class).to be_a(Module)
    expect(described_class).not_to be_a(Class)
  end
end

RSpec.describe CpfVal::TypeMismatchError do
  context 'when instantiated for CPF input' do
    subject(:error) { described_class.new(123, 'string') }

    it 'is a TypeError' do
      expect(error).to be_a(TypeError)
    end

    it 'includes CpfVal::Error' do
      expect(error).to be_a(CpfVal::Error)
    end

    it 'exposes the class name' do
      expect(error.class.name).to eq('CpfVal::TypeMismatchError')
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
      expect(described_class.new(123, 'string').message)
        .to eq('CPF input must be of type string. Got integer number.')
    end
  end
end
