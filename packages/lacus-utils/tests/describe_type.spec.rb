# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LacusUtils do
  describe '.describe_type' do
    context 'when given nil' do
      it 'labels it nil' do
        expect(described_class.describe_type(nil)).to eq('nil')
      end
    end

    context 'when given a string' do
      it 'labels a non-empty string' do
        expect(described_class.describe_type('hello')).to eq('string')
      end

      it 'labels an empty string' do
        expect(described_class.describe_type('')).to eq('string')
      end

      it 'labels a whitespace string' do
        expect(described_class.describe_type('   ')).to eq('string')
      end
    end

    context 'when given a boolean' do
      it 'labels true' do
        expect(described_class.describe_type(true)).to eq('boolean')
      end

      it 'labels false' do
        expect(described_class.describe_type(false)).to eq('boolean')
      end
    end

    context 'when given an integer' do
      it 'labels a positive integer' do
        expect(described_class.describe_type(42)).to eq('integer number')
      end

      it 'labels a negative integer' do
        expect(described_class.describe_type(-42)).to eq('integer number')
      end

      it 'labels zero' do
        expect(described_class.describe_type(0)).to eq('integer number')
      end
    end

    context 'when given a float' do
      it 'labels a positive float' do
        expect(described_class.describe_type(3.14)).to eq('float number')
      end

      it 'labels a negative float' do
        expect(described_class.describe_type(-3.14)).to eq('float number')
      end

      it 'labels NaN' do
        expect(described_class.describe_type(Float::NAN)).to eq('NaN')
      end

      it 'labels positive infinity' do
        expect(described_class.describe_type(Float::INFINITY)).to eq('Infinity')
      end

      it 'labels negative infinity' do
        expect(described_class.describe_type(-Float::INFINITY)).to eq('Infinity')
      end
    end

    context 'when given other numeric types' do
      it 'labels a complex number' do
        expect(described_class.describe_type(Complex(1, 2))).to eq('complex number')
      end

      it 'labels a rational number' do
        expect(described_class.describe_type(Rational(1, 2))).to eq('rational number')
      end
    end

    context 'when given a symbol' do
      it 'labels a symbol' do
        expect(described_class.describe_type(:sym)).to eq('symbol')
      end
    end

    context 'when given a hash' do
      it 'labels a non-empty hash' do
        expect(described_class.describe_type({ a: 1 })).to eq('hash')
      end

      it 'labels an empty hash' do
        expect(described_class.describe_type({})).to eq('hash')
      end
    end

    context 'when given a set' do
      it 'labels a set' do
        expect(described_class.describe_type(Set.new([1]))).to eq('set')
      end
    end

    context 'when given a class or module' do
      it 'labels a class' do
        expect(described_class.describe_type(Integer)).to eq('class')
      end

      it 'labels a module' do
        expect(described_class.describe_type(Comparable)).to eq('class')
      end
    end

    context 'when given a callable' do
      it 'labels a lambda' do
        expect(described_class.describe_type(-> { 0 })).to eq('function')
      end

      it 'labels a proc' do
        expect(described_class.describe_type(proc { 0 })).to eq('function')
      end

      it 'labels a method' do
        expect(described_class.describe_type(method(:puts))).to eq('function')
      end
    end

    context 'when given a plain object' do
      it 'labels it object' do
        expect(described_class.describe_type(Object.new)).to eq('object')
      end
    end

    context 'when given an empty array' do
      it 'labels it Array (empty)' do
        expect(described_class.describe_type([])).to eq('Array (empty)')
      end
    end

    context 'when given a homogeneous array' do
      it 'labels an array of strings' do
        expect(described_class.describe_type(%w[a b c])).to eq('string[]')
      end

      it 'labels an array of integers' do
        expect(described_class.describe_type([1, 2, 3])).to eq('number[]')
      end

      it 'labels an array of floats' do
        expect(described_class.describe_type([1.1, 2.2, 3.3])).to eq('number[]')
      end

      it 'labels an array mixing ints and floats' do
        expect(described_class.describe_type([1, 1.5])).to eq('number[]')
      end

      it 'labels an array of booleans' do
        expect(described_class.describe_type([true, false, true])).to eq('boolean[]')
      end

      it 'labels an array of hashes' do
        expect(described_class.describe_type([{}, { a: 1 }])).to eq('hash[]')
      end

      it 'labels an array of nils' do
        expect(described_class.describe_type([nil, nil])).to eq('nil[]')
      end
    end

    context 'when given a heterogeneous array' do
      it 'joins numbers and strings' do
        expect(described_class.describe_type([1, 'a', 2, 'b'])).to eq('(number | string)[]')
      end

      it 'keeps first-seen insertion order' do
        expect(described_class.describe_type(['hello', 42, true])).to eq('(string | number | boolean)[]')
      end

      it 'joins numbers and hashes' do
        expect(described_class.describe_type([1, {}, 2, { a: 1 }])).to eq('(number | hash)[]')
      end

      it 'joins strings and nils' do
        expect(described_class.describe_type(['a', nil, 'b'])).to eq('(string | nil)[]')
      end
    end
  end
end
