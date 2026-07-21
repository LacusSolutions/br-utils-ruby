# frozen_string_literal: true

require 'spec_helper'

REPEATED_DIGIT_PREFIXES = %w[
  000000000
  111111111
  222222222
  333333333
  444444444
  555555555
  666666666
  777777777
  888888888
  999999999
].freeze

VALID_CPF_SAMPLES = %w[
  82911017366
  33528612690
  86244870050
  22312659077
  96215666068
  67107095072
  48039958008
  20954431014
  11144477735
  12345678909
  97705597411
  71699299960
  35449963599
  43571251113
  43603425197
  61100255346
  86845729395
  03000443991
  74849560822
  59980231700
  90248115707
  82056229145
  68988687647
  59657429161
  04396907656
  89702485444
  49334640499
  89843515200
  26627637286
  96517650466
  81941692249
  20838028888
  00413864855
  79471093112
  06897074950
  70180285661
  51808354451
  57541651702
  07180937045
  01848900392
  28917222056
  34438615399
  46655439680
  05928803621
  88153164007
  92518925988
  00377949655
  60967893402
  37909039140
  88407302066
  74646326213
  07149896065
  42752317085
  58129750864
  17717087600
].freeze

FORMATTED_VALID_CPFS = [
  ['dots and dash', '499.784.420-90'],
  ['dots only', '028.062.110.85'],
  ['underscores', '011_258_960_00'],
  ['dash only', '779953010-30']
].freeze

INVALID_CPF_SAMPLES = %w[
  86244870011
  33528612691
  12345678901
  12345678910
  499784420-75
  090.871.219-71
  081.465.729.10
  011_258_960_99
].freeze

NON_DIGIT_STRINGS = [
  '',
  'abc',
  'abc123',
  'true',
  'false',
  'null'
].freeze

SHORT_OR_LONG_NUMERIC_STRINGS = %w[
  1
  12
  123
  1234
  12345
  123456
  1234567
  12345678
  123456789
  1234567890
].freeze

INVALID_INPUT_CASES = [
  [nil, 'nil'],
  [42, 'integer number'],
  [3.14, 'float number'],
  [true, 'boolean'],
  [{}, 'hash'],
  [[1, 2, 3], 'number[]']
].freeze

def create_inputs_set(cpf)
  formatted = cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d+)/, '\1.\2.\3-\4')

  [
    ['string', cpf],
    ['formatted string', formatted],
    ['array', cpf.chars],
    ['formatted array', formatted.chars],
    ['grouped array', formatted.split(/[.-]/)]
  ]
end

RSpec.describe CpfVal::CpfValidator do
  describe '#initialize' do
    context 'when called' do
      it 'creates an instance of CpfValidator' do
        expect(described_class.new).to be_a(described_class)
      end
    end
  end

  describe '#is_valid' do
    subject(:validator) { described_class.new }

    context 'when given a valid cpf' do
      create_inputs_set('82911017366').each do |input_type, input_value|
        it "returns true for a valid CPF #{input_type}" do
          expect(validator.is_valid(input_value)).to be(true)
        end
      end

      VALID_CPF_SAMPLES.each do |cpf|
        it "returns true for valid sample #{cpf}" do
          expect(validator.is_valid(cpf)).to be(true)
        end
      end

      FORMATTED_VALID_CPFS.each do |format_label, cpf|
        it "returns true for a formatted valid CPF (#{format_label})" do
          expect(validator.is_valid(cpf)).to be(true)
        end
      end
    end

    context 'when the length is wrong' do
      create_inputs_set('8291101736').each do |input_type, input_value|
        it "returns false for a CPF #{input_type} with less than 11 digits" do
          expect(validator.is_valid(input_value)).to be(false)
        end
      end

      create_inputs_set('829110173666').each do |input_type, input_value|
        it "returns false for a CPF #{input_type} with more than 11 digits" do
          expect(validator.is_valid(input_value)).to be(false)
        end
      end

      SHORT_OR_LONG_NUMERIC_STRINGS.each do |cpf|
        it "returns false for numeric string of wrong length #{cpf}" do
          expect(validator.is_valid(cpf)).to be(false)
        end
      end

      it 'returns false for an empty array' do
        expect(validator.is_valid([])).to be(false)
      end
    end

    context 'when the check digits are wrong' do
      INVALID_CPF_SAMPLES.each do |cpf|
        it "returns false for invalid CPF #{cpf}" do
          expect(validator.is_valid(cpf)).to be(false)
        end
      end

      it 'returns false for every wrong check digit of a known base' do
        base = '177170876'
        valid_check_digits = '00'

        100.times do |index|
          check_digits = format('%02d', index)
          input_value = "#{base}#{check_digits}"
          expected = check_digits == valid_check_digits

          expect(validator.is_valid(input_value)).to be(expected)
        end
      end
    end

    context 'when the cpf has all digits the same' do
      REPEATED_DIGIT_PREFIXES.each do |prefix|
        it "returns false for repeated-digit prefix #{prefix}" do
          100.times do |index|
            input_value = format('%<prefix>s%<index>02d', prefix: prefix, index: index)

            expect(validator.is_valid(input_value)).to be(false)
          end
        end
      end
    end

    context 'when given a non-digit string' do
      NON_DIGIT_STRINGS.each do |cpf|
        it "returns false for non-digit string #{cpf.inspect}" do
          expect(validator.is_valid(cpf)).to be(false)
        end
      end
    end

    context 'when called with invalid arguments' do
      it 'does not raise with string input' do
        expect(validator.is_valid('12345678901')).to be(false)
      end

      it 'does not raise with array of strings input' do
        expect(validator.is_valid(['12345678901'])).to be(false)
      end

      INVALID_INPUT_CASES.each do |input_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          expect { validator.is_valid(input_value) }
            .to raise_error(CpfVal::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.expected_type).to eq('string or string[]')
                expect(error.actual_input).to equal(input_value)
                expect(error.actual_type).to eq(actual_type)
                expect(error.message)
                  .to eq("CPF input must be of type string or string[]. Got #{actual_type}.")
              end
            end
        end
      end

      it 'raises TypeMismatchError for a mixed array' do
        input_value = ['1', 2]

        expect { validator.is_valid(input_value) }
          .to raise_error(CpfVal::TypeMismatchError) do |error|
            aggregate_failures do
              expect(error.expected_type).to eq('string or string[]')
              expect(error.actual_input).to equal(input_value)
              expect(error.message).to match(/CPF input must be of type string or string\[\]/)
            end
          end
      end
    end
  end
end
