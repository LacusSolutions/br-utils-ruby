# frozen_string_literal: true

require 'spec_helper'

CPF_GENERATOR_PREFIX_CASES = %w[
  1 12 123 1234 12345 123456 1234567 12345678 123456789
].freeze

CPF_GENERATOR_FACTORIES = {
  constructor_literal: lambda { |options|
    generator = CpfGen::CpfGenerator.new(options)
    ->(override = nil) { generator.generate(override) }
  },
  constructor_options: lambda { |options|
    generator_options = CpfGen::CpfGeneratorOptions.new(options)
    generator = CpfGen::CpfGenerator.new(generator_options)
    ->(override = nil) { generator.generate(override) }
  },
  method_literal: lambda { |options|
    generator = CpfGen::CpfGenerator.new
    lambda do |override = nil|
      if override.nil?
        generator.generate(options)
      elsif override.is_a?(CpfGen::CpfGeneratorOptions)
        generator.generate(CpfGen::CpfGeneratorOptions.new(options, override))
      else
        generator.generate(options.merge(override))
      end
    end
  },
  method_options: lambda { |options|
    generator = CpfGen::CpfGenerator.new
    lambda do |override = nil|
      generator_options = CpfGen::CpfGeneratorOptions.new(options, override || {})
      generator.generate(generator_options)
    end
  }
}.freeze

class CpfGeneratorCallsSpy < CpfGen::CpfGenerator
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

RSpec.describe CpfGen::CpfGenerator do
  def default_options_snapshot
    CpfGen::CpfGeneratorOptions.new.all
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

    context 'when called with a CpfGeneratorOptions instance' do
      let(:options) do
        CpfGen::CpfGeneratorOptions.new(format: true, prefix: '123456')
      end

      it 'uses that instance directly without copying' do
        generator = described_class.new(options)

        aggregate_failures do
          expect(generator.options).to equal(options)
          expect(generator.options.all).to eq(options.all)
        end
      end

      it 'reflects mutations on future generate calls' do
        generator = described_class.new(
          CpfGen::CpfGeneratorOptions.new(prefix: '123456', format: true)
        )

        generator.options.prefix = '112233'
        generator.options.format = false

        result = generator.generate

        aggregate_failures do
          expect(result.length).to eq(11)
          expect(result).to match(/\A112233\d{5}\z/)
        end
      end
    end

    context 'when called with a literal options hash' do
      it 'creates a new CpfGeneratorOptions instance' do
        input = { format: true, prefix: '123456' }
        generator = described_class.new(input)

        aggregate_failures do
          expect(generator.options).to be_a(CpfGen::CpfGeneratorOptions)
          expect(generator.options.format).to be(true)
          expect(generator.options.prefix).to eq('123456')
        end
      end
    end

    context 'when called with invalid options' do
      it 'raises ValidationError' do
        expect { described_class.new(prefix: '000000000') }
          .to raise_error(CpfGen::ValidationError)
      end

      it 'raises TypeMismatchError' do
        expect { described_class.new(prefix: 123) }
          .to raise_error(CpfGen::TypeMismatchError)
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        options = CpfGen::CpfGeneratorOptions.new(format: true, prefix: '123456')

        expect { described_class.new(options, format: false) }
          .to raise_error(CpfGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        expect { described_class.new({ format: true }, prefix: '12') }
          .to raise_error(CpfGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end
  end

  describe '#generate' do
    {
      'constructor literal' => :constructor_literal,
      'constructor CpfGeneratorOptions' => :constructor_options,
      'method literal' => :method_literal,
      'method CpfGeneratorOptions' => :method_options
    }.each do |label, factory_key|
      context "when options are passed via #{label}" do
        let(:factory) { CPF_GENERATOR_FACTORIES.fetch(factory_key) }

        context 'when no options are passed' do
          let(:generate) { factory.call({}) }

          it 'returns an 11-digit numeric string' do
            100.times do
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(11)
                expect(result).not_to match(/[a-z]/i)
                expect(result).not_to match(%r{[./-]})
                expect(result).to match(/\A\d+\z/)
              end
            end
          end

          it 'returns mostly unique values' do
            expect(unique_result_count(generate)).to be >= 99
          end
        end

        context 'when format is true' do
          let(:generate) { factory.call(format: true) }

          it 'returns a 14-character formatted string' do
            100.times do
              result = generate.call

              aggregate_failures do
                expect(result.length).to eq(14)
                expect(result).not_to match(/[a-z]/i)
                expect(result).to match(%r{[./-]})
                expect(result).to match(/\d{2,3}/)
              end
            end
          end

          it 'matches the standard CPF mask' do
            100.times do
              expect(generate.call).to match(/\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/)
            end
          end

          it 'returns mostly unique values' do
            expect(unique_result_count(generate)).to be >= 99
          end
        end

        context 'when prefix is passed' do
          CPF_GENERATOR_PREFIX_CASES.each do |prefix|
            it "returns an 11-digit string starting with #{prefix}" do
              generate = factory.call(prefix: prefix)

              100.times do
                result = generate.call

                aggregate_failures do
                  expect(result.length).to eq(11)
                  expect(result).to match(/\A\d+\z/)
                  expect(result).to start_with(prefix)
                end
              end
            end
          end

          it 'drops characters after the 9th position' do
            generate = factory.call(prefix: '12345678910')
            result = generate.call

            aggregate_failures do
              expect(result.length).to eq(11)
              expect(result).not_to end_with('10')
              expect(result).to match(/\A123456789\d{2}\z/)
            end
          end

          it 'returns a deterministic CPF for a 9-digit prefix' do
            generate = factory.call(prefix: '987654321')
            results = Array.new(100) { generate.call }.uniq

            expect(results.size).to eq(1)
          end

          it 'strips non-digit characters from prefix' do
            generate = factory.call(prefix: 'ABC.123.DEF.456.GHI.789', format: false)

            expect(generate.call).to start_with('123456789')
          end
        end

        context 'when different options are combined' do
          it 'returns a 14-character CPF with format and prefix' do
            generate = factory.call(format: true, prefix: '12345678')
            result = generate.call

            aggregate_failures do
              expect(result.length).to eq(14)
              expect(result).not_to match(/[a-z]/i)
              expect(result).to match(/\A123\.456\.78\d-\d{2}\z/)
            end
          end
        end
      end
    end

    context 'when called with both an options instance and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        generator = described_class.new(format: false, prefix: '12')
        per_call_options = CpfGen::CpfGeneratorOptions.new(format: true, prefix: '123456')

        expect { generator.generate(per_call_options, format: false) }
          .to raise_error(CpfGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when called with both an options Hash and keyword arguments' do
      it 'raises InvalidArgumentCombinationError' do
        generator = described_class.new

        expect { generator.generate({ format: true }, prefix: '12') }
          .to raise_error(CpfGen::InvalidArgumentCombinationError, /options.*keyword arguments.*not both/)
      end
    end

    context 'when CpfCheckDigits raises a DomainError' do
      before do
        allow(LacusUtils).to receive(:generate_random_sequence)
          .and_return('111111111', '123456789')
      end

      it 'retries generation and returns a valid CPF' do
        result = described_class.new.generate

        aggregate_failures do
          expect(result.length).to eq(11)
          expect(result).to start_with('123456789')
          expect(LacusUtils).to have_received(:generate_random_sequence).twice
        end
      end

      it 'uses the same options on retry' do
        allow(LacusUtils).to receive(:generate_random_sequence).and_return('111111', '222333')

        result = described_class.new(prefix: '111', format: true).generate

        aggregate_failures do
          expect(result.length).to eq(14)
          expect(result).to start_with('111.222.333-')
          expect(LacusUtils).to have_received(:generate_random_sequence).with(6, :numeric).twice
        end
      end

      it 'retries with the same per-call options' do
        allow(LacusUtils).to receive(:generate_random_sequence).and_return('111111', '222333')

        generator = CpfGeneratorCallsSpy.new
        result = generator.generate(format: true, prefix: '111')

        aggregate_failures do
          expect(result.length).to eq(14)
          expect(result).to start_with('111.222.333-')
          expect(generator.calls_count).to eq(2)
          expect(generator.calls_arguments).to eq(
            [
              [nil, { format: true, prefix: '111' }],
              [nil, { format: true, prefix: '111' }]
            ]
          )
        end
      end
    end
  end
end
