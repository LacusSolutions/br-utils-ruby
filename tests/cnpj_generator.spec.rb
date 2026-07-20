# frozen_string_literal: true

require 'spec_helper'

CNPJ_GENERATOR_PREFIX_CASES = %w[
  1 12 123 1234 12345 123456 1234567 12345678 123456789 1234567890 12345678910
  123456780009 A AB ABC ABCD ABCDE ABCDEF ABCDEFG ABCDEFGH ABCDEFGHI ABCDEFGHIJ
  ABCDEFGHIJK ABCDEFGHIJKL AB123CDE0001
].freeze

CNPJ_GENERATOR_TRUNCATION_PREFIXES = %w[
  123456780009
  ABCDEFGHIJKL
  AB123CDE0001
].freeze

CNPJ_GENERATOR_TYPE_CONTEXTS = [
  ['numeric', '\d'],
  ['alphabetic', '[A-Z]'],
  ['alphanumeric', '[0-9A-Z]']
].freeze

CNPJ_GENERATOR_FACTORIES = {
  constructor_literal: lambda { |options|
    generator = CnpjGen::CnpjGenerator.new(options)
    ->(override = nil) { generator.generate(override) }
  },
  constructor_options: lambda { |options|
    generator_options = CnpjGen::CnpjGeneratorOptions.new(options)
    generator = CnpjGen::CnpjGenerator.new(generator_options)
    ->(override = nil) { generator.generate(override) }
  },
  method_literal: lambda { |options|
    generator = CnpjGen::CnpjGenerator.new
    lambda do |override = nil|
      if override.nil?
        generator.generate(options)
      elsif override.is_a?(CnpjGen::CnpjGeneratorOptions)
        generator.generate(CnpjGen::CnpjGeneratorOptions.new(options, override))
      else
        generator.generate(options.merge(override))
      end
    end
  },
  method_options: lambda { |options|
    generator = CnpjGen::CnpjGenerator.new
    lambda do |override = nil|
      generator_options = CnpjGen::CnpjGeneratorOptions.new(options, override || {})
      generator.generate(generator_options)
    end
  }
}.freeze

class CnpjGeneratorCallsSpy < CnpjGen::CnpjGenerator
  attr_reader :calls_count, :calls_arguments

  def initialize(*args, **kwargs)
    super
    @calls_count = 0
    @calls_arguments = []
  end

  def generate(options = nil, **kwargs)
    @calls_count += 1
    @calls_arguments << [options, kwargs]
    super
  end
end

RSpec.describe CnpjGen::CnpjGenerator do
  def default_options_snapshot
    CnpjGen::CnpjGeneratorOptions.new.all
  end

  def unique_result_count(generate, count: 100, **kwargs)
    Array.new(count) { generate.call(**kwargs) }.uniq.size
  end

  describe '#initialize' do
    context 'when called with no arguments' do
      it 'creates an instance with default options' do
        generator = described_class.new

        expect(generator.options.all).to eq(default_options_snapshot)
      end
    end

    context 'when called with an empty hash' do
      it 'creates an instance with default options' do
        generator = described_class.new({})

        expect(generator.options.all).to eq(default_options_snapshot)
      end
    end

    context 'when called with a CnpjGeneratorOptions instance' do
      let(:options) do
        CnpjGen::CnpjGeneratorOptions.new(format: true, prefix: '12345678', type: 'numeric')
      end

      it 'uses that instance directly without copying' do
        generator = described_class.new(options)

        aggregate_failures do
          expect(generator.options).to equal(options)
          expect(generator.options.all).to eq(options.all)
        end
      end

      it 'reflects mutations on future generate calls' do
        generator = described_class.new(CnpjGen::CnpjGeneratorOptions.new(format: false, type: 'numeric'))

        generator.options.format = true
        generator.options.type = 'alphabetic'

        aggregate_failures do
          expect(generator.options.format).to be(true)
          expect(generator.options.type).to eq('alphabetic')
        end
      end
    end

    context 'when called with a literal options hash' do
      it 'creates a new CnpjGeneratorOptions instance' do
        input = { format: true, prefix: '12345678', type: 'numeric' }
        generator = described_class.new(input)

        aggregate_failures do
          expect(generator.options).to be_a(CnpjGen::CnpjGeneratorOptions)
          expect(generator.options.format).to be(true)
          expect(generator.options.prefix).to eq('12345678')
          expect(generator.options.type).to eq('numeric')
        end
      end
    end

    context 'when called with invalid options' do
      it 'raises ValidationError' do
        expect { described_class.new(prefix: '00000000') }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises ValidationError' do
        expect { described_class.new(type: 'invalid') }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises TypeMismatchError' do
        expect { described_class.new(prefix: 123) }
          .to raise_error(CnpjGen::TypeMismatchError)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        options = CnpjGen::CnpjGeneratorOptions.new(format: true, prefix: '12345678', type: 'numeric')

        expect { described_class.new(options, format: false) }
          .to raise_error(CnpjGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        expect { described_class.new({ format: true }, prefix: 'AB') }
          .to raise_error(CnpjGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  describe '#generate' do
    {
      'constructor literal' => :constructor_literal,
      'constructor CnpjGeneratorOptions' => :constructor_options,
      'method literal' => :method_literal,
      'method CnpjGeneratorOptions' => :method_options
    }.each do |label, factory_key|
      context "when options are passed via #{label}" do
        let(:factory) { CNPJ_GENERATOR_FACTORIES.fetch(factory_key) }

        context 'when no options are passed' do
          let(:generate) { factory.call({}) }

          it 'returns a 14-character alphanumeric string' do
            100.times do
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(14)
                expect(result).not_to match(/[a-z]/)
                expect(result).not_to match(%r{[./-]})
                expect(result).to match(/\A[0-9A-Z]+\z/)
              end
            end
          end

          it 'ends with numeric check digits' do
            100.times do
              expect(generate.call).to match(/\d{2}\z/)
            end
          end

          it 'returns mostly unique values' do
            expect(unique_result_count(generate)).to be >= 99
          end
        end

        context 'when format is true' do
          let(:generate) { factory.call(format: true) }

          it 'returns an 18-character formatted string' do
            100.times do
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(18)
                expect(result).not_to match(/[a-z]/)
                expect(result).to match(%r{[./-]})
                expect(result).to match(/[0-9A-Z]{2,4}/)
              end
            end
          end

          it 'ends with numeric check digits' do
            100.times do
              expect(generate.call).to match(/\d{2}\z/)
            end
          end

          it 'matches the standard CNPJ mask' do
            100.times do
              expect(generate.call).to match(
                %r{\A[0-9A-Z]{2}\.[0-9A-Z]{3}\.[0-9A-Z]{3}/[0-9A-Z]{4}-[0-9A-Z]{2}\z}i
              )
            end
          end

          it 'returns mostly unique values' do
            expect(unique_result_count(generate)).to be >= 99
          end
        end

        context 'when prefix is passed' do
          CNPJ_GENERATOR_PREFIX_CASES.each do |prefix|
            it "returns a 14-character string starting with #{prefix}" do
              generate = factory.call(prefix: prefix)

              100.times do
                result = generate.call

                aggregate_failures do
                  expect(result.length).to eq(14)
                  expect(result).to match(/\A[0-9A-Z]+\z/)
                  expect(result).to start_with(prefix)
                end
              end
            end
          end

          CNPJ_GENERATOR_TRUNCATION_PREFIXES.each do |prefix|
            it "drops characters after the 12th position for #{prefix}" do
              generate = factory.call(prefix: "#{prefix}XY")
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(14)
                expect(result).not_to end_with('XY')
                expect(result).to match(/\A#{Regexp.escape(prefix)}\d{2}\z/)
              end
            end

            it "returns a deterministic CNPJ for 12-char prefix #{prefix}" do
              generate = factory.call(prefix: prefix)
              results = Array.new(100) { generate.call({ prefix: prefix }) }.uniq

              expect(results.size).to eq(1)
            end
          end

          it 'strips non-alphanumeric characters from prefix' do
            generate = factory.call(prefix: 'AB.12.CDE/0001', format: false)

            expect(generate.call).to start_with('AB12CDE0001')
          end
        end

        CNPJ_GENERATOR_TYPE_CONTEXTS.each do |type_name, pattern|
          context "when type is #{type_name}" do
            let(:generate) { factory.call(type: type_name) }

            it 'returns a 14-character string matching the type' do
              100.times do
                result = generate.call

                aggregate_failures do
                  expect(result.length).to eq(14)
                  expect(result).not_to match(/[a-z]/)
                  expect(result).not_to match(%r{[./-]})
                  expect(result).to match(/\A#{pattern}{12}\d{2}\z/)
                end
              end
            end

            it 'returns mostly unique values' do
              expect(unique_result_count(generate)).to be >= 98
            end
          end
        end

        context 'when different options are combined' do
          it 'returns an 18-character CNPJ with format and prefix' do
            generate = factory.call(format: true, prefix: 'AB123CDE000')
            result = generate.call

            aggregate_failures do
              expect(result.length).to eq(18)
              expect(result).not_to match(/[a-z]/)
              expect(result).to match(%r{\AAB\.123\.CDE/000[0-9A-Z]-\d{2}\z})
            end
          end

          CNPJ_GENERATOR_TYPE_CONTEXTS.each do |type_name, pattern|
            it "returns an 18-character CNPJ with format and #{type_name} type" do
              generate = factory.call(format: true, type: type_name)
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(18)
                expect(result).not_to match(/[a-z]/)
                expect(result).to match(
                  %r{\A#{pattern}{2}\.#{pattern}{3}\.#{pattern}{3}/#{pattern}{4}-\d{2}\z}
                )
              end
            end

            it "returns a 14-character CNPJ with prefix and #{type_name} type" do
              generate = factory.call(prefix: 'AB123CDE', type: type_name)
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(14)
                expect(result).not_to match(/[a-z]/)
                expect(result).not_to match(%r{[./-]})
                expect(result).to match(/\AAB123CDE#{pattern}{4}\d{2}\z/)
              end
            end

            it "returns an 18-character CNPJ with format, prefix, and #{type_name}" do
              generate = factory.call(format: true, prefix: 'AB123CDE', type: type_name)
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(18)
                expect(result).not_to match(/[a-z]/)
                expect(result).to match(%r{\AAB\.123\.CDE/#{pattern}{4}-\d{2}\z})
              end
            end
          end
        end
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        generator = described_class.new(format: false, prefix: 'AB', type: 'alphabetic')
        per_call_options = CnpjGen::CnpjGeneratorOptions.new(format: true, prefix: '12345678', type: 'numeric')

        expect { generator.generate(per_call_options, format: false) }
          .to raise_error(CnpjGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        generator = described_class.new

        expect { generator.generate({ format: true }, prefix: 'AB') }
          .to raise_error(CnpjGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when CnpjCheckDigits raises a DomainError' do
      before do
        allow(LacusUtils).to receive(:generate_random_sequence)
          .and_return('111111111111', '123456780001')
      end

      it 'retries generation and returns a valid CNPJ' do
        result = described_class.new.generate

        aggregate_failures do
          expect(result.length).to eq(14)
          expect(result).to start_with('123456780001')
          expect(LacusUtils).to have_received(:generate_random_sequence).twice
        end
      end

      it 'uses the same options on retry' do
        allow(LacusUtils).to receive(:generate_random_sequence).and_return('0000', '0001')

        result = described_class.new(prefix: '12345678').generate

        aggregate_failures do
          expect(result.length).to eq(14)
          expect(result).to start_with('12345678')
          expect(LacusUtils).to have_received(:generate_random_sequence).with(4, :alphanumeric).twice
        end
      end

      it 'retries with the same per-call options' do
        allow(LacusUtils).to receive(:generate_random_sequence).and_return('0000000000', 'ABC1230001')

        generator = CnpjGeneratorCallsSpy.new
        result = generator.generate(format: false, prefix: '00', type: 'alphanumeric')

        aggregate_failures do
          expect(result.length).to eq(14)
          expect(result).to start_with('00ABC1230001')
          expect(generator.calls_count).to eq(2)
          expect(generator.calls_arguments).to eq(
            [
              [nil, { format: false, prefix: '00', type: 'alphanumeric' }],
              [nil, { format: false, prefix: '00', type: 'alphanumeric' }]
            ]
          )
        end
      end
    end
  end
end
