# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LacusUtils do
  describe '.generate_random_sequence' do
    context 'when generating a numeric sequence' do
      it 'produces the requested length' do
        20.times { expect(described_class.generate_random_sequence(32, :numeric).length).to eq(32) }
      end

      it 'contains only digits' do
        50.times { expect(described_class.generate_random_sequence(100, :numeric)).to match(/\A\d+\z/) }
      end
    end

    context 'when generating an alphabetic sequence' do
      it 'produces the requested length' do
        20.times { expect(described_class.generate_random_sequence(32, :alphabetic).length).to eq(32) }
      end

      it 'contains only uppercase letters' do
        50.times { expect(described_class.generate_random_sequence(100, :alphabetic)).to match(/\A[A-Z]+\z/) }
      end

      it 'excludes digits' do
        50.times { expect(described_class.generate_random_sequence(100, :alphabetic)).not_to match(/\d/) }
      end
    end

    context 'when generating an alphanumeric sequence' do
      it 'produces the requested length' do
        20.times { expect(described_class.generate_random_sequence(32, :alphanumeric).length).to eq(32) }
      end

      it 'contains only digits and uppercase letters' do
        50.times { expect(described_class.generate_random_sequence(100, :alphanumeric)).to match(/\A[0-9A-Z]+\z/) }
      end

      it 'excludes lowercase letters' do
        50.times { expect(described_class.generate_random_sequence(100, :alphanumeric)).not_to match(/[a-z]/) }
      end
    end

    context 'when no type is given' do
      it 'defaults to alphanumeric' do
        expect(described_class.generate_random_sequence(8)).to match(/\A[0-9A-Z]+\z/)
      end

      it 'honors the requested size' do
        expect(described_class.generate_random_sequence(8).length).to eq(8)
      end
    end

    context 'when size is zero' do
      it 'returns an empty string' do
        expect(described_class.generate_random_sequence(0, :numeric)).to eq('')
      end
    end

    context 'when size is negative' do
      it 'raises ArgumentError' do
        expect { described_class.generate_random_sequence(-1, :numeric) }.to raise_error(ArgumentError)
      end
    end

    context 'when type is unknown' do
      it 'raises ArgumentError' do
        expect { described_class.generate_random_sequence(4, :unknown) }.to raise_error(ArgumentError)
      end
    end
  end
end
