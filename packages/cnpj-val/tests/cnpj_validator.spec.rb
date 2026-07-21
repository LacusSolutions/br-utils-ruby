# frozen_string_literal: true

require 'spec_helper'

REPEATED_DIGIT_PREFIXES = %w[
  111111111111
  222222222222
  333333333333
  444444444444
  555555555555
  666666666666
  777777777777
  888888888888
  999999999999
].freeze

INVALID_INPUT_CASES = [
  [nil, 'nil'],
  [42, 'integer number'],
  [3.14, 'float number'],
  [true, 'boolean'],
  [{}, 'hash'],
  [[1, 2, 3], 'number[]']
].freeze

CNPJ_VALIDATOR_FACTORIES = {
  constructor_literal: lambda { |options|
    validator = CnpjVal::CnpjValidator.new(options)
    ->(cnpj_input, options_override = nil) { validator.is_valid(cnpj_input, options_override) }
  },
  constructor_options: lambda { |options|
    validator_options = CnpjVal::CnpjValidatorOptions.new(options)
    validator = CnpjVal::CnpjValidator.new(validator_options)
    ->(cnpj_input, options_override = nil) { validator.is_valid(cnpj_input, options_override) }
  },
  method_literal: lambda { |options|
    validator = CnpjVal::CnpjValidator.new
    lambda do |cnpj_input, options_override = nil|
      if options_override.nil?
        validator.is_valid(cnpj_input, options)
      elsif options_override.is_a?(CnpjVal::CnpjValidatorOptions)
        validator.is_valid(cnpj_input, CnpjVal::CnpjValidatorOptions.new(options, options_override))
      else
        validator.is_valid(cnpj_input, options.merge(options_override))
      end
    end
  },
  method_options: lambda { |options|
    validator = CnpjVal::CnpjValidator.new
    lambda do |cnpj_input, options_override = nil|
      validator_options = CnpjVal::CnpjValidatorOptions.new(options, options_override || {})
      validator.is_valid(cnpj_input, validator_options)
    end
  }
}.freeze

CNPJ_VALIDATOR_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a literal hash', :constructor_literal],
  ['when options are passed to the constructor as a CnpjValidatorOptions instance', :constructor_options],
  ['when options are passed to #is_valid as a literal hash', :method_literal],
  ['when options are passed to #is_valid as a CnpjValidatorOptions instance', :method_options]
].freeze

def create_inputs_set(cnpj)
  formatted = cnpj.gsub(/([0-9A-Z]{2})([0-9A-Z]{3})([0-9A-Z]{3})([0-9A-Z]{4})(\d+)/i, '\1.\2.\3/\4-\5')
  [['string', cnpj], ['formatted string', formatted], ['array', cnpj.chars],
   ['formatted array', formatted.chars], ['grouped array', formatted.split(%r{[./-]})]]
end

RSpec.describe CnpjVal::CnpjValidator do
  def default_options_snapshot
    CnpjVal::CnpjValidatorOptions.new.all
  end

  describe '#initialize' do
    context 'when called with no arguments' do
      it 'creates an instance with default options' do
        expect(described_class.new.options.all).to eq(default_options_snapshot)
      end
    end

    context 'when called with an empty hash' do
      it 'creates an instance with default options' do
        expect(described_class.new({}).options.all).to eq(default_options_snapshot)
      end
    end

    context 'when called with a CnpjValidatorOptions instance' do
      let(:options) do
        CnpjVal::CnpjValidatorOptions.new(case_sensitive: false, type: 'numeric')
      end

      it 'uses that instance directly without copying' do
        validator = described_class.new(options)

        aggregate_failures do
          expect(validator.options).to be(options)
          expect(validator.options.all).to eq(options.all)
        end
      end

      it 'reflects mutations to the shared options instance' do
        validator = described_class.new(options)

        options.case_sensitive = true
        options.type = 'alphanumeric'

        aggregate_failures do
          expect(validator.options.case_sensitive).to be(true)
          expect(validator.options.type).to eq('alphanumeric')
        end
      end
    end

    context 'when called with a literal options hash' do
      it 'creates a new CnpjValidatorOptions instance from the provided values' do
        input_options = {
          case_sensitive: false,
          type: 'numeric'
        }
        validator = described_class.new(input_options)

        aggregate_failures do
          expect(validator.options).to be_a(CnpjVal::CnpjValidatorOptions)
          expect(validator.options.case_sensitive).to be(false)
          expect(validator.options.type).to eq('numeric')
        end
      end
    end

    context 'when called with invalid options' do
      it 'raises ValidationError for invalid type' do
        expect { described_class.new(type: 'invalid') }
          .to raise_error(CnpjVal::ValidationError)
      end

      it 'raises TypeMismatchError for non-string type' do
        expect { described_class.new(type: 123) }
          .to raise_error(CnpjVal::TypeMismatchError)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        options = CnpjVal::CnpjValidatorOptions.new(case_sensitive: false, type: 'numeric')

        expect { described_class.new(options, type: 'alphanumeric') }
          .to raise_error(CnpjVal::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        expect { described_class.new({ type: 'numeric' }, case_sensitive: false) }
          .to raise_error(CnpjVal::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  describe '#is_valid' do
    CNPJ_VALIDATOR_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:is_valid) { CNPJ_VALIDATOR_FACTORIES[factory_key].call({}) }

        context 'when no options are passed' do
          create_inputs_set('1QB5UKALPYFP59').each do |input_type, input_value|
            it "returns true for valid uppercase alphanumeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(true)
            end
          end

          create_inputs_set('96206256120884').each do |input_type, input_value|
            it "returns true for valid numeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(true)
            end
          end

          create_inputs_set('1QB5UKALpyfp59').each do |input_type, input_value|
            it "returns false for lowercase alphanumeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(false)
            end
          end

          create_inputs_set('AB123CDE00015').each do |input_type, input_value|
            it "returns false for fewer than 14 chars in #{input_type}" do
              expect(is_valid.call(input_value)).to be(false)
            end
          end

          create_inputs_set('AB123CDE0001555').each do |input_type, input_value|
            it "returns false for more than 14 chars in #{input_type}" do
              expect(is_valid.call(input_value)).to be(false)
            end
          end

          it 'returns false for a CNPJ with base ID all zeros' do
            100.times do |index|
              input_value = format('00000000A001%02d', index)

              expect(is_valid.call(input_value)).to be(false)
            end
          end

          it 'returns false for a CNPJ with branch ID all zeros' do
            100.times do |index|
              input_value = format('AB123CDE0000%02d', index)

              expect(is_valid.call(input_value)).to be(false)
            end
          end

          REPEATED_DIGIT_PREFIXES.each do |prefix|
            it "returns false for repeated-digit prefix #{prefix}" do
              100.times do |index|
                input_value = format('%<prefix>s%<index>02d', prefix: prefix, index: index)

                expect(is_valid.call(input_value)).to be(false)
              end
            end
          end
        end

        context 'when case_sensitive is false' do
          let(:is_valid) { CNPJ_VALIDATOR_FACTORIES[factory_key].call(case_sensitive: false) }

          create_inputs_set('1QB5UKALpyfp59').each do |input_type, input_value|
            it "returns true for lowercase alphanumeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(true)
            end
          end
        end

        context 'when type is numeric' do
          let(:is_valid) { CNPJ_VALIDATOR_FACTORIES[factory_key].call(type: 'numeric') }

          create_inputs_set('96206256120884').each do |input_type, input_value|
            it "returns true for valid numeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(true)
            end
          end

          create_inputs_set('1QB5UKALPYFP59').each do |input_type, input_value|
            it "returns false for alphanumeric #{input_type}" do
              expect(is_valid.call(input_value)).to be(false)
            end
          end
        end
      end
    end

    context 'when called with invalid arguments' do
      subject(:validator) { described_class.new }

      INVALID_INPUT_CASES.each do |input_value, actual_type|
        it "raises TypeMismatchError for #{actual_type}" do
          expect { validator.is_valid(input_value) }
            .to raise_error(CnpjVal::TypeMismatchError) do |error|
              aggregate_failures do
                expect(error.expected_type).to eq('string or string[]')
                expect(error.actual_input).to equal(input_value)
                expect(error.actual_type).to eq(actual_type)
                expect(error.option_name).to be_nil
                expect(error.message)
                  .to eq("CNPJ input must be of type string or string[]. Got #{actual_type}.")
              end
            end
        end
      end
    end

    context 'when type is numeric via keyword' do
      it 'returns true for a valid numeric CNPJ' do
        validator = described_class.new(type: 'numeric')

        expect(validator.is_valid('12651319934215')).to be(true)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        validator = described_class.new
        options = CnpjVal::CnpjValidatorOptions.new(type: 'numeric')

        expect { validator.is_valid('12651319934215', options, case_sensitive: false) }
          .to raise_error(CnpjVal::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        validator = described_class.new

        expect { validator.is_valid('12651319934215', { type: 'numeric' }, case_sensitive: false) }
          .to raise_error(CnpjVal::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when using per-call keyword overrides' do
      it 'overrides instance defaults for one call only' do
        validator = described_class.new(case_sensitive: true)

        expect(validator.is_valid('9jn7mgljzxio50', case_sensitive: false)).to be(true)
        expect(validator.is_valid('9jn7mgljzxio50')).to be(false)
        expect(validator.options.case_sensitive).to be(true)
      end
    end
  end
end
