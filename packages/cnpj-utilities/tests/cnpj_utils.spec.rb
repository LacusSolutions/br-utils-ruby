# frozen_string_literal: true

require 'spec_helper'

# Combined behavioural suite for CnpjUtils (JS / PHP / Python reference tests).
#
# Dropped cases (not meaningful in Ruby):
# - js/packages/cnpj-utils/tests/output.spec.ts — UMD/CJS/ESM bundles, .d.ts wiring,
#   global variable attachment, and export-string parsing (JS packaging only).
# - JavaScript prototype spies (spyOn(CnpjFormatter.prototype, ...)) — replaced with
#   instance doubles that assert the same façade-forwarding premise.
# - PHP getFormatter() / getGenerator() / getValidator() accessor names — Ruby uses
#   #formatter / #generator / #validator (JS/Python parity per AGENTS.md).
# - PHP CnpjType / CnpjValidationType enums — Ruby uses string type values.
# - Python __slots__ / dynamic-attribute restriction — optional in Ruby; AGENTS.md
#   does not require freezing or slot-like attribute locking.
# - Python None-kwargs forwarding quirk on format (forwarding nil keys when any
#   keyword is present) — match cnpj-fmt Ruby merge semantics instead.
# - Deep sibling exception message / constructor smoke from python package.spec.py —
#   those APIs belong to cnpj-fmt / cnpj-gen / cnpj-val; this suite only asserts
#   that requiring cnpj-utilities loads those modules and that DEFAULT works.

def compact_options(**kwargs)
  kwargs.compact
end

def expect_options_containing(actual, expected)
  expected.each do |key, value|
    expect(actual[key]).to eq(value)
  end
end

FORMAT_FACTORIES = {
  constructor_hash: lambda { |cnpj, slash_key = nil|
    utils = CnpjUtils.new(formatter: compact_options(slash_key: slash_key))
    utils.format(cnpj)
  },
  constructor_options: lambda { |cnpj, slash_key = nil|
    options = CnpjFmt::CnpjFormatterOptions.new(compact_options(slash_key: slash_key))
    utils = CnpjUtils.new(formatter: options)
    utils.format(cnpj)
  },
  method_keywords: lambda { |cnpj, slash_key = nil|
    CnpjUtils.new.format(cnpj, slash_key: slash_key)
  },
  method_options: lambda { |cnpj, slash_key = nil|
    options = CnpjFmt::CnpjFormatterOptions.new(compact_options(slash_key: slash_key))
    CnpjUtils.new.format(cnpj, options)
  }
}.freeze

GENERATE_FACTORIES = {
  constructor_hash: lambda { |format: nil, prefix: nil, type: nil|
    utils = CnpjUtils.new(generator: compact_options(format: format, prefix: prefix, type: type))
    utils.generate
  },
  constructor_options: lambda { |format: nil, prefix: nil, type: nil|
    options = CnpjGen::CnpjGeneratorOptions.new(
      compact_options(format: format, prefix: prefix, type: type)
    )
    utils = CnpjUtils.new(generator: options)
    utils.generate
  },
  method_keywords: lambda { |format: nil, prefix: nil, type: nil|
    CnpjUtils.new.generate(format: format, prefix: prefix, type: type)
  },
  method_options: lambda { |format: nil, prefix: nil, type: nil|
    options = CnpjGen::CnpjGeneratorOptions.new(
      compact_options(format: format, prefix: prefix, type: type)
    )
    CnpjUtils.new.generate(options)
  }
}.freeze

IS_VALID_FACTORIES = {
  constructor_hash: lambda { |cnpj, type: nil, case_sensitive: nil|
    utils = CnpjUtils.new(
      validator: compact_options(type: type, case_sensitive: case_sensitive)
    )
    utils.is_valid(cnpj)
  },
  constructor_options: lambda { |cnpj, type: nil, case_sensitive: nil|
    options = CnpjVal::CnpjValidatorOptions.new(
      compact_options(type: type, case_sensitive: case_sensitive)
    )
    utils = CnpjUtils.new(validator: options)
    utils.is_valid(cnpj)
  },
  method_keywords: lambda { |cnpj, type: nil, case_sensitive: nil|
    CnpjUtils.new.is_valid(cnpj, type: type, case_sensitive: case_sensitive)
  },
  method_options: lambda { |cnpj, type: nil, case_sensitive: nil|
    options = CnpjVal::CnpjValidatorOptions.new(
      compact_options(type: type, case_sensitive: case_sensitive)
    )
    CnpjUtils.new.is_valid(cnpj, options)
  }
}.freeze

FORMAT_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjFormatterOptions', :constructor_options],
  ['when options are passed to #format as keywords', :method_keywords],
  ['when options are passed to #format as CnpjFormatterOptions', :method_options]
].freeze

GENERATE_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjGeneratorOptions', :constructor_options],
  ['when options are passed to #generate as keywords', :method_keywords],
  ['when options are passed to #generate as CnpjGeneratorOptions', :method_options]
].freeze

IS_VALID_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjValidatorOptions', :constructor_options],
  ['when options are passed to #is_valid as keywords', :method_keywords],
  ['when options are passed to #is_valid as CnpjValidatorOptions', :method_options]
].freeze

RSpec.describe CnpjUtils do
  def default_formatter_options_snapshot
    CnpjFmt::CnpjFormatterOptions.new.all
  end

  def default_generator_options_snapshot
    CnpjGen::CnpjGeneratorOptions.new.all
  end

  def default_validator_options_snapshot
    CnpjVal::CnpjValidatorOptions.new.all
  end

  describe 'DEFAULT' do
    it 'is an instance of CnpjUtils' do
      expect(described_class::DEFAULT).to be_a(described_class)
    end

    it 'exposes format, generate, and is_valid' do
      aggregate_failures do
        expect(described_class::DEFAULT).to respond_to(:format)
        expect(described_class::DEFAULT).to respond_to(:generate)
        expect(described_class::DEFAULT).to respond_to(:is_valid)
      end
    end
  end

  describe 'class helpers' do
    it 'exposes format, generate, and is_valid' do
      aggregate_failures do
        expect(described_class).to respond_to(:format)
        expect(described_class).to respond_to(:generate)
        expect(described_class).to respond_to(:is_valid)
      end
    end

    context 'when calling through the class' do
      it 'formats like DEFAULT' do
        expect(described_class.format('03603568000195')).to eq(
          described_class::DEFAULT.format('03603568000195')
        )
      end

      it 'generates like DEFAULT' do
        result = described_class.generate(type: 'numeric', prefix: '123456780001')
        expect(result).to match(/\A\d{14}\z/)
        expect(described_class.is_valid(result, type: 'numeric')).to be(true)
      end

      it 'validates like DEFAULT' do
        aggregate_failures do
          expect(described_class.is_valid('9JN7MGLJZXIO50')).to eq(
            described_class::DEFAULT.is_valid('9JN7MGLJZXIO50')
          )
          expect(described_class.is_valid('9JN7MGLJZXIO51')).to eq(
            described_class::DEFAULT.is_valid('9JN7MGLJZXIO51')
          )
        end
      end
    end

    context 'when DEFAULT is mutated' do
      around do |example|
        original_formatter = described_class::DEFAULT.formatter
        example.run
        described_class::DEFAULT.formatter = original_formatter
      end

      it 'affects subsequent class helper calls' do
        described_class::DEFAULT.formatter = { slash_key: '|' }
        expect(described_class.format('01ABC234000X56')).to eq('01.ABC.234|000X-56')
      end

      it 'does not affect a custom instance' do
        custom = described_class.new
        described_class::DEFAULT.formatter = { slash_key: '|' }
        expect(custom.format('01ABC234000X56')).to eq('01.ABC.234/000X-56')
      end
    end
  end

  describe 'loaded sibling packages' do
    it 'makes cnpj-fmt symbols available' do
      aggregate_failures do
        expect(defined?(CnpjFmt::CnpjFormatter)).to eq('constant')
        expect(defined?(CnpjFmt::CnpjFormatterOptions)).to eq('constant')
        expect(CnpjFmt).to respond_to(:cnpj_fmt)
      end
    end

    it 'makes cnpj-gen symbols available' do
      aggregate_failures do
        expect(defined?(CnpjGen::CnpjGenerator)).to eq('constant')
        expect(defined?(CnpjGen::CnpjGeneratorOptions)).to eq('constant')
        expect(CnpjGen).to respond_to(:cnpj_gen)
      end
    end

    it 'makes cnpj-val symbols available' do
      aggregate_failures do
        expect(defined?(CnpjVal::CnpjValidator)).to eq('constant')
        expect(defined?(CnpjVal::CnpjValidatorOptions)).to eq('constant')
        expect(CnpjVal).to respond_to(:cnpj_val)
      end
    end
  end

  describe 'two-tier CnpjUtils re-exports' do
    it 'nests sibling modules as the same objects' do
      aggregate_failures do
        expect(described_class::CnpjFmt).to equal(CnpjFmt)
        expect(described_class::CnpjGen).to equal(CnpjGen)
        expect(described_class::CnpjVal).to equal(CnpjVal)
      end
    end

    it 'aliases main cnpj-fmt classes at the façade root' do
      aggregate_failures do
        expect(described_class::CnpjFormatter).to equal(CnpjFmt::CnpjFormatter)
        expect(described_class::CnpjFormatterOptions).to equal(CnpjFmt::CnpjFormatterOptions)
        expect(described_class::CnpjFormatterError).to equal(CnpjFmt::Error)
      end
    end

    it 'aliases main cnpj-gen classes at the façade root' do
      aggregate_failures do
        expect(described_class::CnpjGenerator).to equal(CnpjGen::CnpjGenerator)
        expect(described_class::CnpjGeneratorOptions).to equal(CnpjGen::CnpjGeneratorOptions)
        expect(described_class::CnpjGeneratorError).to equal(CnpjGen::Error)
      end
    end

    it 'aliases main cnpj-val classes at the façade root' do
      aggregate_failures do
        expect(described_class::CnpjValidator).to equal(CnpjVal::CnpjValidator)
        expect(described_class::CnpjValidatorOptions).to equal(CnpjVal::CnpjValidatorOptions)
        expect(described_class::CnpjValidatorError).to equal(CnpjVal::Error)
      end
    end
  end

  describe '#initialize' do
    context 'when called with no arguments' do
      subject(:utils) { described_class.new }

      it 'creates default component instances' do
        aggregate_failures do
          expect(utils.formatter).to be_a(CnpjFmt::CnpjFormatter)
          expect(utils.generator).to be_a(CnpjGen::CnpjGenerator)
          expect(utils.validator).to be_a(CnpjVal::CnpjValidator)
        end
      end

      it 'uses default component options' do
        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, default_formatter_options_snapshot)
          expect_options_containing(utils.generator.options.all, default_generator_options_snapshot)
          expect_options_containing(utils.validator.options.all, default_validator_options_snapshot)
        end
      end
    end

    context 'when called with component instances' do
      it 'uses the passed formatter directly' do
        formatter = CnpjFmt::CnpjFormatter.new
        utils = described_class.new(formatter: formatter)

        aggregate_failures do
          expect(utils.formatter).to be_a(CnpjFmt::CnpjFormatter)
          expect(utils.formatter).to equal(formatter)
        end
      end

      it 'uses the passed generator directly' do
        generator = CnpjGen::CnpjGenerator.new
        utils = described_class.new(generator: generator)

        aggregate_failures do
          expect(utils.generator).to be_a(CnpjGen::CnpjGenerator)
          expect(utils.generator).to equal(generator)
        end
      end

      it 'uses the passed validator directly' do
        validator = CnpjVal::CnpjValidator.new
        utils = described_class.new(validator: validator)

        aggregate_failures do
          expect(utils.validator).to be_a(CnpjVal::CnpjValidator)
          expect(utils.validator).to equal(validator)
        end
      end

      it 'uses all passed components directly' do
        formatter = CnpjFmt::CnpjFormatter.new
        generator = CnpjGen::CnpjGenerator.new
        validator = CnpjVal::CnpjValidator.new
        utils = described_class.new(
          formatter: formatter,
          generator: generator,
          validator: validator
        )

        aggregate_failures do
          expect(utils.formatter).to equal(formatter)
          expect(utils.generator).to equal(generator)
          expect(utils.validator).to equal(validator)
        end
      end
    end

    context 'when called with options instances' do
      it 'builds a formatter that keeps the options reference' do
        formatter_options = CnpjFmt::CnpjFormatterOptions.new
        utils = described_class.new(formatter: formatter_options)

        aggregate_failures do
          expect(utils.formatter).to be_a(CnpjFmt::CnpjFormatter)
          expect(utils.formatter.options).to equal(formatter_options)
        end
      end

      it 'builds a generator that keeps the options reference' do
        generator_options = CnpjGen::CnpjGeneratorOptions.new
        utils = described_class.new(generator: generator_options)

        aggregate_failures do
          expect(utils.generator).to be_a(CnpjGen::CnpjGenerator)
          expect(utils.generator.options).to equal(generator_options)
        end
      end

      it 'builds a validator that keeps the options reference' do
        validator_options = CnpjVal::CnpjValidatorOptions.new
        utils = described_class.new(validator: validator_options)

        aggregate_failures do
          expect(utils.validator).to be_a(CnpjVal::CnpjValidator)
          expect(utils.validator.options).to equal(validator_options)
        end
      end

      it 'builds all components from the passed options' do
        formatter_options = CnpjFmt::CnpjFormatterOptions.new
        generator_options = CnpjGen::CnpjGeneratorOptions.new
        validator_options = CnpjVal::CnpjValidatorOptions.new
        utils = described_class.new(
          formatter: formatter_options,
          generator: generator_options,
          validator: validator_options
        )

        aggregate_failures do
          expect(utils.formatter.options).to equal(formatter_options)
          expect(utils.generator.options).to equal(generator_options)
          expect(utils.validator.options).to equal(validator_options)
        end
      end

      it 'reflects later mutations on shared options' do
        generator_options = CnpjGen::CnpjGeneratorOptions.new(format: false, type: 'numeric')
        utils = described_class.new(generator: generator_options)

        generator_options.format = true
        generator_options.type = 'alphabetic'

        aggregate_failures do
          expect(utils.generator.options.all[:format]).to be(true)
          expect(utils.generator.options.all[:type]).to eq('alphabetic')
        end
      end
    end

    context 'when called with partial option hashes' do
      let(:formatter_options) do
        {
          hidden: true,
          hidden_key: '#',
          hidden_start: 8,
          hidden_end: 11,
          dot_key: '_',
          slash_key: '|',
          dash_key: ' dv '
        }
      end

      let(:generator_options) do
        {
          format: true,
          prefix: '12345678',
          type: 'numeric'
        }
      end

      let(:validator_options) do
        {
          case_sensitive: true,
          type: 'numeric'
        }
      end

      it 'creates a formatter with the passed options' do
        utils = described_class.new(formatter: formatter_options)

        aggregate_failures do
          expect(utils.formatter).to be_a(CnpjFmt::CnpjFormatter)
          expect_options_containing(utils.formatter.options.all, formatter_options)
        end
      end

      it 'creates a generator with the passed options' do
        utils = described_class.new(generator: generator_options)

        aggregate_failures do
          expect(utils.generator).to be_a(CnpjGen::CnpjGenerator)
          expect_options_containing(utils.generator.options.all, generator_options)
        end
      end

      it 'creates a validator with the passed options' do
        utils = described_class.new(validator: validator_options)

        aggregate_failures do
          expect(utils.validator).to be_a(CnpjVal::CnpjValidator)
          expect_options_containing(utils.validator.options.all, validator_options)
        end
      end

      it 'creates all components with the passed options' do
        utils = described_class.new(
          formatter: formatter_options,
          generator: generator_options,
          validator: validator_options
        )

        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, formatter_options)
          expect_options_containing(utils.generator.options.all, generator_options)
          expect_options_containing(utils.validator.options.all, validator_options)
        end
      end

      it 'configures components from mixed hashes' do
        formatter_hash = { slash_key: '|' }
        generator_hash = { format: true, prefix: '12345' }
        validator_hash = { type: 'numeric', case_sensitive: false }

        utils = described_class.new(
          formatter: formatter_hash,
          generator: generator_hash,
          validator: validator_hash
        )

        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, formatter_hash)
          expect_options_containing(utils.generator.options.all, generator_hash)
          expect_options_containing(utils.validator.options.all, validator_hash)
        end
      end
    end

    context 'when called with a settings Hash' do
      it 'accepts formatter, generator, and validator keys' do
        formatter = CnpjFmt::CnpjFormatter.new
        generator = CnpjGen::CnpjGenerator.new
        validator = CnpjVal::CnpjValidator.new

        utils = described_class.new(
          {
            formatter: formatter,
            generator: generator,
            validator: validator
          }
        )

        aggregate_failures do
          expect(utils.formatter).to equal(formatter)
          expect(utils.generator).to equal(generator)
          expect(utils.validator).to equal(validator)
        end
      end
    end

    context 'when called with a non-Hash settings value' do
      it 'raises TypeMismatchError' do
        expect { described_class.new('not-a-hash') }
          .to raise_error(CnpjUtils::TypeMismatchError, /settings must be a Hash/)
      end

      it 'is rescuable via CnpjUtils::Error' do
        expect { described_class.new([]) }
          .to raise_error(CnpjUtils::Error)
      end
    end

    context 'when called with invalid formatter options' do
      it 'raises OutOfRangeError for a bad hidden_start' do
        expect { described_class.new(formatter: { hidden_start: -1 }) }
          .to raise_error(CnpjFmt::OutOfRangeError)
      end

      it 'raises ValidationError for a forbidden key character' do
        expect { described_class.new(formatter: { dash_key: "\u00e5" }) }
          .to raise_error(CnpjFmt::ValidationError)
      end
    end

    context 'when called with invalid generator options' do
      it 'raises ValidationError for an invalid prefix' do
        expect { described_class.new(generator: { prefix: '00000000' }) }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises ValidationError for an invalid type' do
        expect { described_class.new(generator: { type: 'invalid' }) }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises TypeMismatchError for a non-string prefix' do
        expect { described_class.new(generator: { prefix: 123 }) }
          .to raise_error(CnpjGen::TypeMismatchError)
      end
    end

    context 'when called with invalid validator options' do
      it 'raises ValidationError for an invalid type' do
        expect { described_class.new(validator: { type: 'invalid' }) }
          .to raise_error(CnpjVal::ValidationError)
      end
    end

    context 'when called with both a settings Hash and keywords' do
      it 'raises InvalidArgumentCombinationError' do
        expect do
          described_class.new({ formatter: {} }, generator: CnpjGen::CnpjGenerator.new)
        end.to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end
    end
  end

  describe 'resource accessors' do
    subject(:utils) { described_class.new }

    it 'returns the formatter used internally' do
      expect(utils.formatter).to be_a(CnpjFmt::CnpjFormatter)
    end

    it 'returns the generator used internally' do
      expect(utils.generator).to be_a(CnpjGen::CnpjGenerator)
    end

    it 'returns the validator used internally' do
      expect(utils.validator).to be_a(CnpjVal::CnpjValidator)
    end
  end

  describe '#formatter=' do
    subject(:utils) { described_class.new }

    context 'when called with a CnpjFormatter instance' do
      it 'sets the formatter instance' do
        formatter = CnpjFmt::CnpjFormatter.new

        utils.formatter = formatter

        expect(utils.formatter).to equal(formatter)
      end
    end

    context 'when called with a CnpjFormatterOptions instance' do
      it 'sets a formatter that keeps the options' do
        formatter_options = CnpjFmt::CnpjFormatterOptions.new

        utils.formatter = formatter_options

        expect(utils.formatter.options).to equal(formatter_options)
      end
    end

    context 'when called with a partial options Hash' do
      let(:formatter_options) do
        {
          hidden: true,
          hidden_key: '#',
          hidden_start: 8,
          hidden_end: 11,
          dot_key: '_',
          slash_key: '|',
          dash_key: ' dv '
        }
      end

      it 'sets a formatter with the given options' do
        utils.formatter = formatter_options

        expect_options_containing(utils.formatter.options.all, formatter_options)
      end

      it 'replaces the formatter when given an empty Hash' do
        original_formatter = utils.formatter
        original_options = original_formatter.options.all

        utils.formatter = {}

        aggregate_failures do
          expect(utils.formatter).not_to equal(original_formatter)
          expect_options_containing(utils.formatter.options.all, original_options)
        end
      end
    end
  end

  describe '#generator=' do
    subject(:utils) { described_class.new }

    context 'when called with a CnpjGenerator instance' do
      it 'sets the generator instance' do
        generator = CnpjGen::CnpjGenerator.new

        utils.generator = generator

        expect(utils.generator).to equal(generator)
      end
    end

    context 'when called with a CnpjGeneratorOptions instance' do
      it 'sets a generator that keeps the options' do
        generator_options = CnpjGen::CnpjGeneratorOptions.new

        utils.generator = generator_options

        expect(utils.generator.options).to equal(generator_options)
      end
    end

    context 'when called with a partial options Hash' do
      let(:generator_options) do
        {
          format: true,
          prefix: '12345678',
          type: 'numeric'
        }
      end

      it 'sets a generator with the given options' do
        utils.generator = generator_options

        expect_options_containing(utils.generator.options.all, generator_options)
      end

      it 'replaces the generator when given an empty Hash' do
        original_generator = utils.generator
        original_options = original_generator.options.all

        utils.generator = {}

        aggregate_failures do
          expect(utils.generator).not_to equal(original_generator)
          expect_options_containing(utils.generator.options.all, original_options)
        end
      end
    end
  end

  describe '#validator=' do
    subject(:utils) { described_class.new }

    context 'when called with a CnpjValidator instance' do
      it 'sets the validator instance' do
        validator = CnpjVal::CnpjValidator.new

        utils.validator = validator

        expect(utils.validator).to equal(validator)
      end
    end

    context 'when called with a CnpjValidatorOptions instance' do
      it 'sets a validator that keeps the options' do
        validator_options = CnpjVal::CnpjValidatorOptions.new

        utils.validator = validator_options

        expect(utils.validator.options).to equal(validator_options)
      end
    end

    context 'when called with a partial options Hash' do
      let(:validator_options) do
        {
          case_sensitive: true,
          type: 'numeric'
        }
      end

      it 'sets a validator with the given options' do
        utils.validator = validator_options

        expect_options_containing(utils.validator.options.all, validator_options)
      end

      it 'replaces the validator when given an empty Hash' do
        original_validator = utils.validator
        original_options = original_validator.options.all

        utils.validator = {}

        aggregate_failures do
          expect(utils.validator).not_to equal(original_validator)
          expect_options_containing(utils.validator.options.all, original_options)
        end
      end
    end
  end

  describe '#format' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned formatter' do
      let(:formatter) { instance_double(CnpjFmt::CnpjFormatter) }

      before do
        utils.formatter = formatter
      end

      it 'invokes format with the same arguments' do
        cnpj = 'AB123CDE000145'
        options = CnpjFmt::CnpjFormatterOptions.new
        allow(formatter).to receive(:format).and_return('formatted')

        utils.format(cnpj, options)

        expect(formatter).to have_received(:format).with(cnpj, options)
      end

      it 'returns the formatted CNPJ' do
        allow(formatter).to receive(:format).and_return('formatted-cnpj')

        expect(utils.format('12345678000190')).to eq('formatted-cnpj')
      end

      it 'forwards named formatting keywords' do
        allow(formatter).to receive(:format).and_return('12.345.678/0001-90')

        result = utils.format('12345678000190', hidden: true, hidden_key: 'X', escape: true)

        aggregate_failures do
          expect(result).to eq('12.345.678/0001-90')
          expect(formatter).to have_received(:format).with(
            '12345678000190',
            hidden: true,
            hidden_key: 'X',
            escape: true
          )
        end
      end

      it 'rethrows errors from the formatter' do
        allow(formatter).to receive(:format).and_raise(RuntimeError, 'test error')

        expect { utils.format('12345678000190') }.to raise_error(RuntimeError, 'test error')
      end
    end

    context 'when constructor formatter defaults are set' do
      it 'applies them when method options are omitted' do
        utils = described_class.new(
          formatter: {
            hidden: true,
            hidden_key: '#'
          }
        )

        expect(utils.format('12ABC34500DE99')).to include('#')
      end
    end

    context 'when options and keywords are both given' do
      it 'raises InvalidArgumentCombinationError for an options instance' do
        options = CnpjFmt::CnpjFormatterOptions.new(slash_key: '|')

        expect { utils.format('91415732000793', options, hidden: true) }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for an options Hash' do
        expect { utils.format('91415732000793', { slash_key: '|' }, hidden: true) }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end
    end

    FORMAT_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:format_cnpj) { FORMAT_FACTORIES.fetch(factory_key) }

        it 'matches CnpjFormatter#format behaviour' do
          input = '91415732000793'
          formatter = CnpjFmt::CnpjFormatter.new

          expect(format_cnpj.call(input)).to eq(formatter.format(input))
        end

        it 'forwards formatting options' do
          input = '01ABC234000X56'
          slash_key = '|'

          expect(format_cnpj.call(input, slash_key)).to eq("01.ABC.234#{slash_key}000X-56")
        end
      end
    end
  end

  describe '#generate' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned generator' do
      let(:generator) { instance_double(CnpjGen::CnpjGenerator) }

      before do
        utils.generator = generator
      end

      it 'invokes generate with the same arguments' do
        options = CnpjGen::CnpjGeneratorOptions.new
        allow(generator).to receive(:generate).and_return('generated')

        utils.generate(options)

        expect(generator).to have_received(:generate).with(options)
      end

      it 'returns the generated CNPJ' do
        allow(generator).to receive(:generate).and_return('generated-cnpj')

        expect(utils.generate).to eq('generated-cnpj')
      end

      it 'forwards named generation keywords' do
        allow(generator).to receive(:generate).and_return('12.345.678/0001-90')

        result = utils.generate(format: true, prefix: '12345678')

        aggregate_failures do
          expect(result).to eq('12.345.678/0001-90')
          expect(generator).to have_received(:generate).with(format: true, prefix: '12345678')
        end
      end

      it 'rethrows errors from the generator' do
        allow(generator).to receive(:generate).and_raise(RuntimeError, 'test error')

        expect { utils.generate }.to raise_error(RuntimeError, 'test error')
      end
    end

    context 'when options and keywords are both given' do
      it 'raises InvalidArgumentCombinationError for an options instance' do
        options = CnpjGen::CnpjGeneratorOptions.new(format: true)

        expect { utils.generate(options, prefix: '12345') }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for an options Hash' do
        expect { utils.generate({ format: true }, prefix: '12345') }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end
    end

    GENERATE_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:generate) { GENERATE_FACTORIES.fetch(factory_key) }

        it 'matches CnpjGenerator#generate shape' do
          generator = CnpjGen::CnpjGenerator.new
          result = generate.call

          aggregate_failures do
            expect(result).to match(/\A[0-9A-Z]{14}\z/)
            expect(result.length).to eq(generator.generate.length)
          end
        end

        it 'forwards generation options' do
          result = generate.call(format: true, prefix: '12345', type: 'numeric')

          expect(result).to match(%r{\A12\.345\.\d{3}/\d{4}-\d{2}\z})
        end

        it 'returns a deterministic CNPJ for a full prefix' do
          prefix = '123456780009'
          results = Array.new(20) { generate.call(prefix: prefix) }

          expect(results.uniq.size).to eq(1)
        end
      end
    end
  end

  describe '#is_valid' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned validator' do
      let(:validator) { instance_double(CnpjVal::CnpjValidator) }

      before do
        utils.validator = validator
      end

      it 'invokes is_valid with the same arguments' do
        cnpj = 'AB123CDE000145'
        options = CnpjVal::CnpjValidatorOptions.new
        allow(validator).to receive(:is_valid).and_return(true)

        utils.is_valid(cnpj, options)

        expect(validator).to have_received(:is_valid).with(cnpj, options)
      end

      it 'returns the validation result' do
        allow(validator).to receive(:is_valid).and_return(true)

        expect(utils.is_valid('AB123CDE000145')).to be(true)
      end

      it 'returns false when the validator returns false' do
        allow(validator).to receive(:is_valid).and_return(false)

        result = utils.is_valid('12345678000199')

        aggregate_failures do
          expect(result).to be(false)
          expect(validator).to have_received(:is_valid).with('12345678000199')
        end
      end

      it 'rethrows errors from the validator' do
        allow(validator).to receive(:is_valid).and_raise(RuntimeError, 'test error')

        expect { utils.is_valid('AB123CDE000145') }.to raise_error(RuntimeError, 'test error')
      end
    end

    context 'when options and keywords are both given' do
      it 'raises InvalidArgumentCombinationError for an options instance' do
        options = CnpjVal::CnpjValidatorOptions.new(type: 'numeric')

        expect { utils.is_valid('1QB5UKALPYFP59', options, case_sensitive: false) }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for an options Hash' do
        expect { utils.is_valid('1QB5UKALPYFP59', { type: 'numeric' }, case_sensitive: false) }
          .to raise_error(CnpjUtils::InvalidArgumentCombinationError)
      end
    end

    IS_VALID_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:is_valid) { IS_VALID_FACTORIES.fetch(factory_key) }

        it 'matches CnpjValidator#is_valid behaviour' do
          input = '91415732000793'
          validator = CnpjVal::CnpjValidator.new

          expect(is_valid.call(input)).to eq(validator.is_valid(input))
        end

        it 'forwards validation options' do
          input = '1QB5UKALPYFP59'

          aggregate_failures do
            expect(is_valid.call(input, type: 'numeric')).to be(false)
            expect(is_valid.call(input, type: 'alphanumeric')).to be(true)
          end
        end

        it 'validates formatted and unformatted CNPJs' do
          aggregate_failures do
            expect(is_valid.call('1QB5UKALPYFP59')).to be(true)
            expect(is_valid.call('1QB5.UKAL.PYF/P59')).to be(true)
            expect(is_valid.call('AB123CDE0001555')).to be(false)
          end
        end
      end
    end
  end

  describe 'integration' do
    it 'uses the owned component instances for all methods' do
      utils = described_class.new
      formatter = instance_double(CnpjFmt::CnpjFormatter)
      generator = instance_double(CnpjGen::CnpjGenerator)
      validator = instance_double(CnpjVal::CnpjValidator)

      allow(formatter).to receive(:format).and_return('formatted')
      allow(generator).to receive(:generate).and_return('generated')
      allow(validator).to receive(:is_valid).and_return(true)

      utils.formatter = formatter
      utils.generator = generator
      utils.validator = validator

      aggregate_failures do
        expect(utils.format('123')).to eq('formatted')
        expect(utils.generate).to eq('generated')
        expect(utils.is_valid('123')).to be(true)
        expect(formatter).to have_received(:format).once
        expect(generator).to have_received(:generate).once
        expect(validator).to have_received(:is_valid).once
      end
    end
  end

  describe 'package smoke' do
    it 'formats through DEFAULT with a custom slash_key' do
      result = described_class::DEFAULT.format('01ABC234000X56', slash_key: '|')

      expect(result).to eq('01.ABC.234|000X-56')
    end

    it 'formats through CnpjFmt.cnpj_fmt' do
      result = CnpjFmt.cnpj_fmt('01ABC234000X56', slash_key: '|')

      expect(result).to eq('01.ABC.234|000X-56')
    end

    it 'formats through an owned CnpjFormatter' do
      formatter = CnpjFmt::CnpjFormatter.new(hidden: true)

      expect(formatter.format('AB123XYZ000123')).to eq('AB.123.***/****-**')
    end

    it 'generates a numeric CNPJ through DEFAULT' do
      result = described_class::DEFAULT.generate(type: 'numeric')

      aggregate_failures do
        expect(result.length).to eq(14)
        expect(result).to match(/\A\d{14}\z/)
      end
    end

    it 'generates through CnpjGen.cnpj_gen' do
      result = CnpjGen.cnpj_gen(type: 'numeric')

      aggregate_failures do
        expect(result.length).to eq(14)
        expect(result).to match(/\A\d{14}\z/)
      end
    end

    it 'validates through DEFAULT' do
      aggregate_failures do
        expect(described_class::DEFAULT.is_valid('9JN7MGLJZXIO50')).to be(true)
        expect(described_class::DEFAULT.is_valid('9JN7MGLJZXIO51')).to be(false)
      end
    end

    it 'validates through CnpjVal.cnpj_val' do
      aggregate_failures do
        expect(CnpjVal.cnpj_val('9JN7MGLJZXIO50')).to be(true)
        expect(CnpjVal.cnpj_val('9JN7MGLJZXIO51')).to be(false)
      end
    end
  end
end
