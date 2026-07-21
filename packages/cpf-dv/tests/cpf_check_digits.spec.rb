# frozen_string_literal: true

require 'spec_helper'

# Shared conformance fixtures: [9-digit base, expected 11-digit CPF].
CPF_DV_TEST_CASES = [
  %w[054496519 05449651910],
  %w[965376562 96537656206],
  %w[339670768 33967076806],
  %w[623855638 62385563827],
  %w[582286009 58228600950],
  %w[935218534 93521853403],
  %w[132115335 13211533508],
  %w[492602225 49260222575],
  %w[341428925 34142892533],
  %w[727598627 72759862720],
  %w[478880583 47888058396],
  %w[336636977 33663697797],
  %w[859249430 85924943038],
  %w[306829569 30682956961],
  %w[443539643 44353964321],
  %w[439709507 43970950783],
  %w[557601402 55760140221],
  %w[951159579 95115957922],
  %w[671669104 67166910496],
  %w[627571100 62757110004],
  %w[515930555 51593055560],
  %w[303472731 30347273130],
  %w[728843365 72884336508],
  %w[523667424 52366742479],
  %w[513362164 51336216476],
  %w[427546407 42754640797],
  %w[880696512 88069651237],
  %w[571430852 57143085227],
  %w[561416205 56141620540],
  %w[769627950 76962795050],
  %w[416603400 41660340063],
  %w[853803696 85380369634],
  %w[484667676 48466767657],
  %w[058588388 05858838820],
  %w[862778820 86277882007],
  %w[047126827 04712682752],
  %w[881801816 88180181677],
  %w[932053118 93205311884],
  %w[029783613 02978361379],
  %w[950189877 95018987766],
  %w[842528992 84252899206],
  %w[216901618 21690161809],
  %w[110478730 11047873001],
  %w[032967591 03296759158],
  %w[700386565 70038656531],
  %w[929036812 92903681287],
  %w[750529972 75052997272],
  %w[481063058 48106305872],
  %w[307721932 30772193282],
  %w[994799423 99479942364]
].freeze

CPF_DV_REPEATED_DIGIT_INPUTS = [
  '111111111',
  '222222222',
  '333333333',
  '444444444',
  '555555555',
  '666666666',
  '777777777',
  '888888888',
  '999999999',
  '000000000',
  %w[111 111 111],
  %w[222 222 222],
  %w[333 333 333],
  %w[444 444 444],
  %w[555 555 555],
  %w[666 666 666],
  %w[777 777 777],
  %w[888 888 888],
  %w[999 999 999],
  %w[000 000 000],
  %w[1 1 1 1 1 1 1 1 1],
  %w[2 2 2 2 2 2 2 2 2],
  %w[3 3 3 3 3 3 3 3 3],
  %w[4 4 4 4 4 4 4 4 4],
  %w[5 5 5 5 5 5 5 5 5],
  %w[6 6 6 6 6 6 6 6 6],
  %w[7 7 7 7 7 7 7 7 7],
  %w[8 8 8 8 8 8 8 8 8],
  %w[9 9 9 9 9 9 9 9 9],
  %w[0 0 0 0 0 0 0 0 0]
].freeze

CPF_DV_INVALID_LENGTH_INPUTS = [
  '',
  [],
  'abcdefghij',
  '12345678',
  '123456789100',
  %w[1 2 3 4 5 6 7 8],
  %w[0 5 4 4 9 6 5 1 9 1 0 0]
].freeze

CPF_DV_INVALID_TYPE_INPUTS = [
  12_345_678_901,
  nil,
  { cpf: '12345678901' },
  [1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, '2', 3, '4', 5]
].freeze

# Spy subclass that counts modulo-11 calculator invocations (caching assertions).
class CpfCheckDigitsWithCalculateSpy < CpfDV::CpfCheckDigits
  attr_reader :calculate_call_count

  def initialize(cpf_input)
    @calculate_call_count = 0
    super
  end

  def _calculate(cpf_sequence)
    @calculate_call_count += 1
    super
  end
end

RSpec.describe CpfDV::CpfCheckDigits do
  describe '#initialize' do
    context 'when given invalid input type' do
      CPF_DV_INVALID_TYPE_INPUTS.each do |cpf_input|
        it 'raises TypeMismatchError' do
          expect { described_class.new(cpf_input) }
            .to raise_error(CpfDV::TypeMismatchError)
        end
      end

      it 'is rescuable as CpfDV::Error' do
        expect { described_class.new(12_345) }
          .to raise_error(CpfDV::Error)
      end
    end

    context 'when given invalid input length' do
      CPF_DV_INVALID_LENGTH_INPUTS.each do |cpf_input|
        it 'raises InvalidLengthError' do
          expect { described_class.new(cpf_input) }
            .to raise_error(CpfDV::InvalidLengthError)
        end
      end

      it 'is rescuable as CpfDV::DomainError and CpfDV::Error' do
        expect { described_class.new('12345678') }
          .to raise_error(CpfDV::DomainError)
        expect { described_class.new('12345678') }
          .to raise_error(CpfDV::Error)
      end
    end

    context 'when given repeated digits' do
      CPF_DV_REPEATED_DIGIT_INPUTS.each do |cpf_input|
        it 'raises ValidationError' do
          expect { described_class.new(cpf_input) }
            .to raise_error(CpfDV::ValidationError, /repeated digits/i)
        end
      end

      it 'is rescuable as CpfDV::DomainError and CpfDV::Error' do
        expect { described_class.new('111111111') }
          .to raise_error(CpfDV::ValidationError) { |error|
            expect(error).to be_a(CpfDV::DomainError)
            expect(error).to be_a(CpfDV::Error)
          }
      end
    end
  end

  describe '#first' do
    context 'when input is a string' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns first digit for #{base}" do
          expect(described_class.new(base).first).to eq(full[-2])
        end
      end
    end

    context 'when input is an array of strings' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns first digit for #{base}" do
          expect(described_class.new(base.chars).first).to eq(full[-2])
        end
      end
    end

    context 'when accessing digits multiple times' do
      subject(:check_digits) { CpfCheckDigitsWithCalculateSpy.new('123456789') }

      it 'caches the calculator result' do
        3.times { check_digits.first }

        expect(check_digits.calculate_call_count).to eq(1)
      end
    end
  end

  describe '#second' do
    context 'when input is a string' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns second digit for #{base}" do
          expect(described_class.new(base).second).to eq(full[-1])
        end
      end
    end

    context 'when input is an array of strings' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns second digit for #{base}" do
          expect(described_class.new(base.chars).second).to eq(full[-1])
        end
      end
    end

    context 'when accessing digits multiple times' do
      subject(:check_digits) { CpfCheckDigitsWithCalculateSpy.new('123456789') }

      it 'caches both digit calculations' do
        3.times { check_digits.second }

        expect(check_digits.calculate_call_count).to eq(2)
      end
    end
  end

  describe '#both' do
    context 'when input is a string' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns both digits for #{base}" do
          expect(described_class.new(base).both).to eq(full[-2, 2])
        end
      end
    end

    context 'when input is an array of strings' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns both digits for #{base}" do
          expect(described_class.new(base.chars).both).to eq(full[-2, 2])
        end
      end
    end
  end

  describe '#cpf' do
    context 'when input is a string' do
      it 'returns the 11-character CPF' do
        expect(described_class.new('123456789').cpf).to eq('12345678909')
      end
    end

    context 'when input is an array of grouped digits' do
      it 'returns the 11-character CPF' do
        expect(described_class.new(%w[123 456 789]).cpf).to eq('12345678909')
      end
    end

    context 'when input is an array of individual digits' do
      it 'returns the 11-character CPF' do
        expect(described_class.new(%w[1 2 3 4 5 6 7 8 9]).cpf)
          .to eq('12345678909')
      end
    end

    context 'when validating all test cases' do
      CPF_DV_TEST_CASES.each do |base, full|
        it "returns #{full} for #{base}" do
          expect(described_class.new(base).cpf).to eq(full)
        end
      end
    end
  end

  describe 'edge cases' do
    context 'when input is a formatted CPF string' do
      it 'parses and calculates digits' do
        expect(described_class.new('123.456.789').cpf).to eq('12345678909')
      end
    end

    context 'when input already contains check digits' do
      subject(:check_digits) { described_class.new('12345678910') }

      it 'ignores provided digits and recomputes' do
        aggregate_failures do
          expect(check_digits.first).to eq('0')
          expect(check_digits.second).to eq('9')
          expect(check_digits.cpf).to eq('12345678909')
        end
      end
    end
  end
end
