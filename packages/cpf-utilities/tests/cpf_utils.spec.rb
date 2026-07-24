# frozen_string_literal: true

require 'spec_helper'

# Combined behavioural suite for CpfUtils (JS / PHP / Python reference tests).
#
# Dropped cases (not meaningful in Ruby):
# - js/packages/cpf-utils/tests/output.spec.ts — UMD/CJS/ESM bundles, .d.ts wiring,
#   global variable attachment, and export-string parsing (JS packaging only).
# - JavaScript prototype spies (spyOn(CpfFormatter.prototype, ...)) — replaced with
#   instance doubles that assert the same façade-forwarding premise.
# - PHP getFormatter() / getGenerator() / getValidator() accessor names — Ruby uses
#   #formatter / #generator / #validator (JS/Python parity per AGENTS.md).
# - PHP CpfUtils constructor that always builds a fresh CpfValidator with no
#   injection — Ruby accepts validator instances like JS/Python.
# - PHP prefix longer than 9 digits raises — JS/Python/Ruby truncate silently.
# - PHP permissive repeated-digit validation (00000000000 etc. true) — Ruby/JS/
#   Python reject those as invalid.
# - PHP default onFail returning the original string — Ruby/JS/Python return ''.
# - PHP string-only format/isValid inputs — Ruby accepts String or Array<String>.
# - PHP native TypeError for bool/INF/closures on isValid — Ruby raises
#   CpfVal::TypeMismatchError for non-String / non-Array inputs.
# - Python __slots__ / dynamic-attribute restriction — optional in Ruby; AGENTS.md
#   does not require freezing or slot-like attribute locking.
# - Python None-kwargs forwarding quirk on format (forwarding nil keys when any
#   keyword is present) — match cpf-fmt Ruby merge / XOR semantics instead.
# - Python dual-merge of options mapping + kwargs — Ruby uses options XOR keywords.
# - Deep sibling exception message / constructor smoke from python package.spec.py —
#   those APIs belong to cpf-fmt / cpf-gen / cpf-val; this suite only asserts
#   that requiring cpf-utilities loads those modules and that DEFAULT works.
# - CNPJ-only scenarios: slash_key, generator type, validator options /
#   CpfValidatorOptions, alphanumeric / 14-character fixtures.

def compact_options(**kwargs)
  kwargs.compact
end

def expect_options_containing(actual, expected)
  expected.each do |key, value|
    expect(actual[key]).to eq(value)
  end
end

FORMAT_FACTORIES = {
  constructor_hash: lambda { |cpf, dot_key = nil, dash_key = nil|
    utils = CpfUtils.new(formatter: compact_options(dot_key: dot_key, dash_key: dash_key))
    utils.format(cpf)
  },
  constructor_options: lambda { |cpf, dot_key = nil, dash_key = nil|
    options = CpfFmt::CpfFormatterOptions.new(compact_options(dot_key: dot_key, dash_key: dash_key))
    utils = CpfUtils.new(formatter: options)
    utils.format(cpf)
  },
  method_keywords: lambda { |cpf, dot_key = nil, dash_key = nil|
    CpfUtils.new.format(cpf, dot_key: dot_key, dash_key: dash_key)
  },
  method_options: lambda { |cpf, dot_key = nil, dash_key = nil|
    options = CpfFmt::CpfFormatterOptions.new(compact_options(dot_key: dot_key, dash_key: dash_key))
    CpfUtils.new.format(cpf, options)
  }
}.freeze

GENERATE_FACTORIES = {
  constructor_hash: lambda { |format: nil, prefix: nil|
    utils = CpfUtils.new(generator: compact_options(format: format, prefix: prefix))
    utils.generate
  },
  constructor_options: lambda { |format: nil, prefix: nil|
    options = CpfGen::CpfGeneratorOptions.new(compact_options(format: format, prefix: prefix))
    utils = CpfUtils.new(generator: options)
    utils.generate
  },
  method_keywords: lambda { |format: nil, prefix: nil|
    CpfUtils.new.generate(format: format, prefix: prefix)
  },
  method_options: lambda { |format: nil, prefix: nil|
    options = CpfGen::CpfGeneratorOptions.new(compact_options(format: format, prefix: prefix))
    CpfUtils.new.generate(options)
  }
}.freeze

IS_VALID_FACTORIES = {
  default_instance: lambda { |cpf|
    CpfUtils.new.is_valid(cpf)
  },
  constructor_validator: lambda { |cpf|
    utils = CpfUtils.new(validator: CpfVal::CpfValidator.new)
    utils.is_valid(cpf)
  }
}.freeze

FORMAT_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CpfFormatterOptions', :constructor_options],
  ['when options are passed to #format as keywords', :method_keywords],
  ['when options are passed to #format as CpfFormatterOptions', :method_options]
].freeze

GENERATE_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CpfGeneratorOptions', :constructor_options],
  ['when options are passed to #generate as keywords', :method_keywords],
  ['when options are passed to #generate as CpfGeneratorOptions', :method_options]
].freeze

IS_VALID_FACTORY_CONTEXTS = [
  ['when using a default instance', :default_instance],
  ['when a validator instance is passed to the constructor', :constructor_validator]
].freeze

RSpec.describe CpfUtils do
  def default_formatter_options_snapshot
    CpfFmt::CpfFormatterOptions.new.all
  end

  def default_generator_options_snapshot
    CpfGen::CpfGeneratorOptions.new.all
  end

  describe 'DEFAULT' do
    it 'is an instance of CpfUtils' do
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
        expect(described_class.format('12345678909')).to eq(
          described_class::DEFAULT.format('12345678909')
        )
      end

      it 'generates like DEFAULT' do
        result = described_class.generate(prefix: '123456789')
        expect(result).to match(/\A\d{11}\z/)
        expect(described_class.is_valid(result)).to be(true)
      end

      it 'validates like DEFAULT' do
        aggregate_failures do
          expect(described_class.is_valid('12345678909')).to eq(
            described_class::DEFAULT.is_valid('12345678909')
          )
          expect(described_class.is_valid('12345678900')).to eq(
            described_class::DEFAULT.is_valid('12345678900')
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
        described_class::DEFAULT.formatter = { dash_key: '|' }
        expect(described_class.format('12345678909')).to eq('123.456.789|09')
      end

      it 'does not affect a custom instance' do
        custom = described_class.new
        described_class::DEFAULT.formatter = { dash_key: '|' }
        expect(custom.format('12345678909')).to eq('123.456.789-09')
      end
    end
  end

  describe 'loaded sibling packages' do
    it 'makes cpf-fmt symbols available' do
      aggregate_failures do
        expect(defined?(CpfFmt::CpfFormatter)).to eq('constant')
        expect(defined?(CpfFmt::CpfFormatterOptions)).to eq('constant')
        expect(CpfFmt).to respond_to(:cpf_fmt)
      end
    end

    it 'makes cpf-gen symbols available' do
      aggregate_failures do
        expect(defined?(CpfGen::CpfGenerator)).to eq('constant')
        expect(defined?(CpfGen::CpfGeneratorOptions)).to eq('constant')
        expect(CpfGen).to respond_to(:cpf_gen)
      end
    end

    it 'makes cpf-val symbols available' do
      aggregate_failures do
        expect(defined?(CpfVal::CpfValidator)).to eq('constant')
        expect(CpfVal).to respond_to(:cpf_val)
      end
    end
  end

  describe 'two-tier CpfUtils re-exports' do
    it 'nests sibling modules as the same objects' do
      aggregate_failures do
        expect(described_class::CpfFmt).to equal(CpfFmt)
        expect(described_class::CpfGen).to equal(CpfGen)
        expect(described_class::CpfVal).to equal(CpfVal)
      end
    end

    it 'aliases main cpf-fmt classes at the façade root' do
      aggregate_failures do
        expect(described_class::CpfFormatter).to equal(CpfFmt::CpfFormatter)
        expect(described_class::CpfFormatterOptions).to equal(CpfFmt::CpfFormatterOptions)
        expect(described_class::CpfFormatterError).to equal(CpfFmt::Error)
      end
    end

    it 'aliases main cpf-gen classes at the façade root' do
      aggregate_failures do
        expect(described_class::CpfGenerator).to equal(CpfGen::CpfGenerator)
        expect(described_class::CpfGeneratorOptions).to equal(CpfGen::CpfGeneratorOptions)
        expect(described_class::CpfGeneratorError).to equal(CpfGen::Error)
      end
    end

    it 'aliases main cpf-val classes at the façade root' do
      aggregate_failures do
        expect(described_class::CpfValidator).to equal(CpfVal::CpfValidator)
        expect(described_class::CpfValidatorError).to equal(CpfVal::Error)
      end
    end

    it 'does not expose CpfValidatorOptions' do
      expect(described_class.const_defined?(:CpfValidatorOptions)).to be(false)
    end

    context 'with nested surface smoke' do
      it 'exposes Options through the nest' do
        options = described_class::CpfFmt::CpfFormatterOptions.new(hidden: true)

        expect(options.hidden).to be(true)
      end

      it 'exposes helpers through the nest' do
        expect(described_class::CpfFmt.cpf_fmt('12345678909')).to eq('123.456.789-09')
      end

      it 'exposes an error class through the nest' do
        expect(described_class::CpfFmt::OutOfRangeError).to equal(CpfFmt::OutOfRangeError)
      end
    end
  end

  describe '#initialize' do
    context 'when called with no arguments' do
      subject(:utils) { described_class.new }

      it 'creates default component instances' do
        aggregate_failures do
          expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
          expect(utils.generator).to be_a(CpfGen::CpfGenerator)
          expect(utils.validator).to be_a(CpfVal::CpfValidator)
        end
      end

      it 'uses default component options' do
        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, default_formatter_options_snapshot)
          expect_options_containing(utils.generator.options.all, default_generator_options_snapshot)
        end
      end
    end

    context 'when called with component instances' do
      it 'uses the passed formatter directly' do
        formatter = CpfFmt::CpfFormatter.new
        utils = described_class.new(formatter: formatter)

        aggregate_failures do
          expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
          expect(utils.formatter).to equal(formatter)
        end
      end

      it 'uses the passed generator directly' do
        generator = CpfGen::CpfGenerator.new
        utils = described_class.new(generator: generator)

        aggregate_failures do
          expect(utils.generator).to be_a(CpfGen::CpfGenerator)
          expect(utils.generator).to equal(generator)
        end
      end

      it 'uses the passed validator directly' do
        validator = CpfVal::CpfValidator.new
        utils = described_class.new(validator: validator)

        aggregate_failures do
          expect(utils.validator).to be_a(CpfVal::CpfValidator)
          expect(utils.validator).to equal(validator)
        end
      end

      it 'uses all passed components directly' do
        formatter = CpfFmt::CpfFormatter.new
        generator = CpfGen::CpfGenerator.new
        validator = CpfVal::CpfValidator.new
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
        formatter_options = CpfFmt::CpfFormatterOptions.new
        utils = described_class.new(formatter: formatter_options)

        aggregate_failures do
          expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
          expect(utils.formatter.options).to equal(formatter_options)
        end
      end

      it 'builds a generator that keeps the options reference' do
        generator_options = CpfGen::CpfGeneratorOptions.new
        utils = described_class.new(generator: generator_options)

        aggregate_failures do
          expect(utils.generator).to be_a(CpfGen::CpfGenerator)
          expect(utils.generator.options).to equal(generator_options)
        end
      end

      it 'builds formatter and generator from the passed options' do
        formatter_options = CpfFmt::CpfFormatterOptions.new
        generator_options = CpfGen::CpfGeneratorOptions.new
        utils = described_class.new(
          formatter: formatter_options,
          generator: generator_options
        )

        aggregate_failures do
          expect(utils.formatter.options).to equal(formatter_options)
          expect(utils.generator.options).to equal(generator_options)
          expect(utils.validator).to be_a(CpfVal::CpfValidator)
        end
      end

      it 'reflects later mutations on shared options' do
        generator_options = CpfGen::CpfGeneratorOptions.new(format: false)
        utils = described_class.new(generator: generator_options)

        generator_options.format = true
        generator_options.prefix = '12345678'

        aggregate_failures do
          expect(utils.generator.options.all[:format]).to be(true)
          expect(utils.generator.options.all[:prefix]).to eq('12345678')
        end
      end
    end

    context 'when called with partial option hashes' do
      let(:formatter_options) do
        {
          hidden: true,
          hidden_key: '#',
          hidden_start: 8,
          hidden_end: 10,
          dot_key: '_',
          dash_key: ' dv '
        }
      end

      let(:generator_options) do
        {
          format: true,
          prefix: '12345678'
        }
      end

      it 'creates a formatter with the passed options' do
        utils = described_class.new(formatter: formatter_options)

        aggregate_failures do
          expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
          expect_options_containing(utils.formatter.options.all, formatter_options)
        end
      end

      it 'creates a generator with the passed options' do
        utils = described_class.new(generator: generator_options)

        aggregate_failures do
          expect(utils.generator).to be_a(CpfGen::CpfGenerator)
          expect_options_containing(utils.generator.options.all, generator_options)
        end
      end

      it 'creates formatter and generator with the passed options' do
        utils = described_class.new(
          formatter: formatter_options,
          generator: generator_options
        )

        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, formatter_options)
          expect_options_containing(utils.generator.options.all, generator_options)
          expect(utils.validator).to be_a(CpfVal::CpfValidator)
        end
      end

      it 'configures components from mixed hashes' do
        formatter_hash = { hidden: true, hidden_key: 'X' }
        generator_hash = { format: true, prefix: '12345' }

        utils = described_class.new(
          formatter: formatter_hash,
          generator: generator_hash
        )

        aggregate_failures do
          expect_options_containing(utils.formatter.options.all, formatter_hash)
          expect_options_containing(utils.generator.options.all, generator_hash)
        end
      end
    end

    context 'when called with a settings Hash' do
      it 'accepts formatter, generator, and validator keys' do
        formatter = CpfFmt::CpfFormatter.new
        generator = CpfGen::CpfGenerator.new
        validator = CpfVal::CpfValidator.new

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
          .to raise_error(CpfUtils::TypeMismatchError, /settings must be a Hash/)
      end

      it 'raises TypeMismatchError for false (non-nil falsy settings)' do
        expect { described_class.new(false) }
          .to raise_error(CpfUtils::TypeMismatchError, /settings must be a Hash/)
      end

      it 'is rescuable via CpfUtils::Error' do
        expect { described_class.new([]) }
          .to raise_error(CpfUtils::Error)
      end
    end

    context 'when called with invalid formatter options' do
      it 'raises OutOfRangeError for a bad hidden_start' do
        expect { described_class.new(formatter: { hidden_start: -1 }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end

      it 'raises ValidationError for a forbidden key character' do
        expect { described_class.new(formatter: { dash_key: "\u00e5" }) }
          .to raise_error(CpfFmt::ValidationError)
      end
    end

    context 'when called with invalid generator options' do
      it 'raises ValidationError for an invalid prefix' do
        expect { described_class.new(generator: { prefix: '000000000' }) }
          .to raise_error(CpfGen::ValidationError)
      end

      it 'raises TypeMismatchError for a non-string prefix' do
        expect { described_class.new(generator: { prefix: 123 }) }
          .to raise_error(CpfGen::TypeMismatchError)
      end
    end

    context 'when called with both a settings Hash and keywords' do
      it 'raises InvalidArgumentCombinationError' do
        expect do
          described_class.new({ formatter: {} }, generator: CpfGen::CpfGenerator.new)
        end.to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for false settings with keywords' do
        expect do
          described_class.new(false, formatter: {})
        end.to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end
    end
  end

  describe 'resource accessors' do
    subject(:utils) { described_class.new }

    it 'returns the formatter used internally' do
      expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
    end

    it 'returns the generator used internally' do
      expect(utils.generator).to be_a(CpfGen::CpfGenerator)
    end

    it 'returns the validator used internally' do
      expect(utils.validator).to be_a(CpfVal::CpfValidator)
    end
  end

  describe '#formatter=' do
    subject(:utils) { described_class.new }

    context 'when called with a CpfFormatter instance' do
      it 'sets the formatter instance' do
        formatter = CpfFmt::CpfFormatter.new

        utils.formatter = formatter

        expect(utils.formatter).to equal(formatter)
      end
    end

    context 'when called with a CpfFormatterOptions instance' do
      it 'sets a formatter that keeps the options' do
        formatter_options = CpfFmt::CpfFormatterOptions.new

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
          hidden_end: 10,
          dot_key: '_',
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

    context 'when called with nil' do
      it 'resets to a new default formatter' do
        original_formatter = utils.formatter

        utils.formatter = nil

        aggregate_failures do
          expect(utils.formatter).to be_a(CpfFmt::CpfFormatter)
          expect(utils.formatter).not_to equal(original_formatter)
        end
      end
    end
  end

  describe '#generator=' do
    subject(:utils) { described_class.new }

    context 'when called with a CpfGenerator instance' do
      it 'sets the generator instance' do
        generator = CpfGen::CpfGenerator.new

        utils.generator = generator

        expect(utils.generator).to equal(generator)
      end
    end

    context 'when called with a CpfGeneratorOptions instance' do
      it 'sets a generator that keeps the options' do
        generator_options = CpfGen::CpfGeneratorOptions.new

        utils.generator = generator_options

        expect(utils.generator.options).to equal(generator_options)
      end
    end

    context 'when called with a partial options Hash' do
      let(:generator_options) do
        {
          format: true,
          prefix: '12345678'
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

    context 'when called with nil' do
      it 'resets to a new default generator' do
        original_generator = utils.generator

        utils.generator = nil

        aggregate_failures do
          expect(utils.generator).to be_a(CpfGen::CpfGenerator)
          expect(utils.generator).not_to equal(original_generator)
        end
      end
    end
  end

  describe '#validator=' do
    subject(:utils) { described_class.new }

    context 'when called with a CpfValidator instance' do
      it 'sets the validator instance' do
        validator = CpfVal::CpfValidator.new

        utils.validator = validator

        expect(utils.validator).to equal(validator)
      end
    end

    context 'when called with nil' do
      it 'resets to a new default validator' do
        original_validator = utils.validator

        utils.validator = nil

        aggregate_failures do
          expect(utils.validator).to be_a(CpfVal::CpfValidator)
          expect(utils.validator).not_to equal(original_validator)
        end
      end
    end
  end

  describe '#format' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned formatter' do
      let(:formatter) { instance_double(CpfFmt::CpfFormatter) }

      before do
        utils.formatter = formatter
      end

      it 'invokes format with the same arguments' do
        cpf = '12345678909'
        options = CpfFmt::CpfFormatterOptions.new
        allow(formatter).to receive(:format).and_return('formatted')

        utils.format(cpf, options)

        expect(formatter).to have_received(:format).with(cpf, options)
      end

      it 'returns the formatted CPF' do
        allow(formatter).to receive(:format).and_return('formatted-cpf')

        expect(utils.format('12345678909')).to eq('formatted-cpf')
      end

      it 'forwards named formatting keywords' do
        allow(formatter).to receive(:format).and_return('123.456.789-09')

        result = utils.format('12345678909', hidden: true, hidden_key: 'X', escape: true)

        aggregate_failures do
          expect(result).to eq('123.456.789-09')
          expect(formatter).to have_received(:format).with(
            '12345678909',
            hidden: true,
            hidden_key: 'X',
            escape: true
          )
        end
      end

      it 'rethrows errors from the formatter' do
        allow(formatter).to receive(:format).and_raise(RuntimeError, 'test error')

        expect { utils.format('12345678909') }.to raise_error(RuntimeError, 'test error')
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

        expect(utils.format('12345678909')).to include('#')
      end
    end

    context 'when options and keywords are both given' do
      it 'raises InvalidArgumentCombinationError for an options instance' do
        options = CpfFmt::CpfFormatterOptions.new(dash_key: '|')

        expect { utils.format('12345678909', options, hidden: true) }
          .to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for an options Hash' do
        expect { utils.format('12345678909', { dash_key: '|' }, hidden: true) }
          .to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end
    end

    context 'with array and encode inputs' do
      it 'formats an array of strings' do
        expect(utils.format(%w[123 456 78909])).to eq('123.456.789-09')
      end

      it 'URL-encodes when encode is true' do
        expect(utils.format('12345678909', encode: true, dash_key: '/'))
          .to eq('123.456.789%2F09')
      end
    end

    FORMAT_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:format_cpf) { FORMAT_FACTORIES.fetch(factory_key) }

        it 'matches CpfFormatter#format behaviour' do
          input = '80976511061'
          formatter = CpfFmt::CpfFormatter.new

          expect(format_cpf.call(input)).to eq(formatter.format(input))
        end

        it 'forwards formatting options' do
          input = '12345678909'
          dot_key = '_'
          dash_key = ' dv '

          expect(format_cpf.call(input, dot_key, dash_key)).to eq('123_456_789 dv 09')
        end
      end
    end

    context 'with PHP formatter fixtures' do
      it 'formats a dotted-dashed CPF unchanged' do
        expect(utils.format('809.765.110-61')).to eq('809.765.110-61')
      end

      it 'formats an unformatted CPF with dots and dash' do
        expect(utils.format('80976511061')).to eq('809.765.110-61')
      end

      it 'formats a dash-separated CPF with dots and dash' do
        expect(utils.format('809-765-110-61')).to eq('809.765.110-61')
      end

      it 'formats a space-separated CPF with dots and dash' do
        expect(utils.format('809 765 110 61')).to eq('809.765.110-61')
      end

      it 'formats a trailing-space CPF with dots and dash' do
        expect(utils.format('80976511061 ')).to eq('809.765.110-61')
      end

      it 'formats a leading-space CPF with dots and dash' do
        expect(utils.format(' 80976511061')).to eq('809.765.110-61')
      end

      it 'formats individually dotted digits with dots and dash' do
        expect(utils.format('8.0.9.7.6.5.1.1.0.6.1')).to eq('809.765.110-61')
      end

      it 'formats individually dashed digits with dots and dash' do
        expect(utils.format('8-0-9-7-6-5-1-1-0-6-1')).to eq('809.765.110-61')
      end

      it 'formats individually spaced digits with dots and dash' do
        expect(utils.format('8 0 9 7 6 5 1 1 0 6 1')).to eq('809.765.110-61')
      end

      it 'strips letters before formatting' do
        expect(utils.format('80976511061abc')).to eq('809.765.110-61')
      end

      it 'strips mixed non-digit characters before formatting' do
        expect(utils.format('809765110 dv 61')).to eq('809.765.110-61')
      end

      it 'formats with empty dot_key' do
        expect(utils.format('80976511061', dot_key: '')).to eq('809765110-61')
      end

      it 'formats with dash_key as a dot' do
        expect(utils.format('80976511061', dash_key: '.')).to eq('809.765.110.61')
      end

      it 'formats with empty delimiters' do
        expect(utils.format('809.765.110-61', dot_key: '', dash_key: '')).to eq('80976511061')
      end

      it 'formats with escape and custom delimiters' do
        expect(utils.format('80976511061', escape: true, dot_key: '<', dash_key: '>'))
          .to eq('809&lt;765&lt;110&gt;61')
      end

      it 'formats with the default hidden mask' do
        expect(utils.format('80976511061', hidden: true)).to eq('809.***.***-**')
      end

      it 'formats with a custom hidden_start' do
        expect(utils.format('80976511061', hidden: true, hidden_start: 6))
          .to eq('809.765.***-**')
      end

      it 'formats with a custom hidden_end' do
        expect(utils.format('80976511061', hidden: true, hidden_end: 8))
          .to eq('809.***.***-61')
      end

      it 'formats with a custom hidden range' do
        expect(utils.format('80976511061', hidden: true, hidden_start: 0, hidden_end: 8))
          .to eq('***.***.***-61')
      end

      it 'formats with a reversed hidden range' do
        expect(utils.format('80976511061', hidden: true, hidden_start: 9, hidden_end: 3))
          .to eq('809.***.***-*1')
      end

      it 'formats with a custom hidden_key' do
        expect(utils.format('80976511061', hidden: true, hidden_key: '#'))
          .to eq('809.###.###-##')
      end

      it 'formats with a custom hidden_key and range' do
        expect(
          utils.format('80976511061', hidden: true, hidden_key: '#', hidden_start: 6)
        ).to eq('809.765.###-##')
      end

      it 'falls back to on_fail for invalid input' do
        expect(
          utils.format('abc', on_fail: ->(value, _error) { value.upcase })
        ).to eq('ABC')
      end

      it 'raises OutOfRangeError for hidden_start out of range' do
        aggregate_failures do
          expect { utils.format('80976511061', hidden: true, hidden_start: -1) }
            .to raise_error(CpfFmt::OutOfRangeError)
          expect { utils.format('80976511061', hidden: true, hidden_start: 11) }
            .to raise_error(CpfFmt::OutOfRangeError)
        end
      end

      it 'raises OutOfRangeError for hidden_end out of range' do
        aggregate_failures do
          expect { utils.format('80976511061', hidden: true, hidden_end: -1) }
            .to raise_error(CpfFmt::OutOfRangeError)
          expect { utils.format('80976511061', hidden: true, hidden_end: 11) }
            .to raise_error(CpfFmt::OutOfRangeError)
        end
      end

      it 'raises TypeMismatchError when on_fail is not callable' do
        expect { utils.format('80976511061', on_fail: 'testing') }
          .to raise_error(CpfFmt::TypeMismatchError)
      end
    end
  end

  describe '#generate' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned generator' do
      let(:generator) { instance_double(CpfGen::CpfGenerator) }

      before do
        utils.generator = generator
      end

      it 'invokes generate with the same arguments' do
        options = CpfGen::CpfGeneratorOptions.new
        allow(generator).to receive(:generate).and_return('generated')

        utils.generate(options)

        expect(generator).to have_received(:generate).with(options)
      end

      it 'returns the generated CPF' do
        allow(generator).to receive(:generate).and_return('generated-cpf')

        expect(utils.generate).to eq('generated-cpf')
      end

      it 'forwards named generation keywords' do
        allow(generator).to receive(:generate).and_return('123.456.789-09')

        result = utils.generate(format: true, prefix: '12345678')

        aggregate_failures do
          expect(result).to eq('123.456.789-09')
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
        options = CpfGen::CpfGeneratorOptions.new(format: true)

        expect { utils.generate(options, prefix: '12345') }
          .to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end

      it 'raises InvalidArgumentCombinationError for an options Hash' do
        expect { utils.generate({ format: true }, prefix: '12345') }
          .to raise_error(CpfUtils::InvalidArgumentCombinationError)
      end
    end

    GENERATE_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:generate) { GENERATE_FACTORIES.fetch(factory_key) }

        it 'matches CpfGenerator#generate shape' do
          validator = CpfVal::CpfValidator.new
          result = generate.call

          aggregate_failures do
            expect(result).to match(/\A\d{11}\z/)
            expect(validator.is_valid(result)).to be(true)
          end
        end

        it 'forwards generation options' do
          result = generate.call(format: true, prefix: '12345678')

          expect(result).to match(/\A123\.456\.78\d-\d{2}\z/)
        end

        it 'returns a deterministic CPF for a full 9-digit prefix' do
          prefix = '123456789'
          results = Array.new(20) { generate.call(prefix: prefix) }

          expect(results.uniq.size).to eq(1)
        end
      end
    end

    context 'with PHP generator fixtures' do
      it 'generates 11-digit strings without formatting' do
        25.times do
          expect(utils.generate.length).to eq(11)
        end
      end

      it 'generates 14-character strings with formatting' do
        25.times do
          expect(utils.generate(format: true).length).to eq(14)
        end
      end

      it 'generates valid unformatted CPFs' do
        25.times do
          expect(utils.is_valid(utils.generate)).to be(true)
        end
      end

      it 'generates valid formatted CPFs' do
        25.times do
          expect(utils.is_valid(utils.generate(format: true))).to be(true)
        end
      end

      it 'generates valid CPFs for each prefix length' do
        prefixes = %w[
          1 12 123 1234 12345 123456 1234567 12345678 123456789 123.456.789
        ]

        prefixes.each do |prefix|
          expect(utils.is_valid(utils.generate(prefix: prefix))).to be(true)
        end
      end

      it 'generates formatted CPFs matching the default pattern' do
        25.times do
          expect(utils.generate(format: true)).to match(/\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/)
        end
      end

      it 'generates a CPF whose body matches a short prefix' do
        expect(utils.generate({ prefix: '12345' })).to match(/\A12345\d{6}\z/)
      end
    end
  end

  describe '#is_valid' do
    subject(:utils) { described_class.new }

    context 'when delegating to the owned validator' do
      let(:validator) { instance_double(CpfVal::CpfValidator) }

      before do
        utils.validator = validator
      end

      it 'invokes is_valid with the same arguments' do
        cpf = '12345678909'
        allow(validator).to receive(:is_valid).and_return(true)

        utils.is_valid(cpf)

        expect(validator).to have_received(:is_valid).with(cpf)
      end

      it 'returns the validation result' do
        allow(validator).to receive(:is_valid).and_return(true)

        expect(utils.is_valid('12345678909')).to be(true)
      end

      it 'returns false when the validator returns false' do
        allow(validator).to receive(:is_valid).and_return(false)

        result = utils.is_valid('12345678900')

        aggregate_failures do
          expect(result).to be(false)
          expect(validator).to have_received(:is_valid).with('12345678900')
        end
      end

      it 'rethrows errors from the validator' do
        allow(validator).to receive(:is_valid).and_raise(RuntimeError, 'test error')

        expect { utils.is_valid('12345678909') }.to raise_error(RuntimeError, 'test error')
      end
    end

    IS_VALID_FACTORY_CONTEXTS.each do |context_description, factory_key|
      context context_description do
        let(:is_valid) { IS_VALID_FACTORIES.fetch(factory_key) }

        it 'matches CpfValidator#is_valid behaviour' do
          input = '86244870050'
          validator = CpfVal::CpfValidator.new

          expect(is_valid.call(input)).to eq(validator.is_valid(input))
        end

        it 'validates formatted and unformatted CPF strings' do
          aggregate_failures do
            expect(is_valid.call('12345678909')).to be(true)
            expect(is_valid.call('123.456.789-09')).to be(true)
            expect(is_valid.call('12345678900')).to be(false)
          end
        end
      end
    end

    context 'with PHP validator fixtures' do
      it 'validates a dotted-dashed CPF' do
        expect(utils.is_valid('499.784.420-90')).to be(true)
      end

      it 'validates a dotted CPF' do
        expect(utils.is_valid('028.062.110.85')).to be(true)
      end

      it 'validates an underscored CPF' do
        expect(utils.is_valid('011_258_960_00')).to be(true)
      end

      it 'validates a dashed CPF' do
        expect(utils.is_valid('779953010-30')).to be(true)
      end

      it 'validates an unformatted CPF' do
        expect(utils.is_valid('86244870050')).to be(true)
      end

      it 'validates known valid samples' do
        %w[22312659077 96215666068 67107095072 48039958008 20954431014].each do |cpf|
          expect(utils.is_valid(cpf)).to be(true)
        end
      end

      it 'rejects 090.871.219-71' do
        expect(utils.is_valid('090.871.219-71')).to be(false)
      end

      it 'rejects 081.465.729.10' do
        expect(utils.is_valid('081.465.729.10')).to be(false)
      end

      it 'rejects 011_258_960_99' do
        expect(utils.is_valid('011_258_960_99')).to be(false)
      end

      it 'rejects 499784420-75' do
        expect(utils.is_valid('499784420-75')).to be(false)
      end

      it 'rejects 86244870011' do
        expect(utils.is_valid('86244870011')).to be(false)
      end

      it 'rejects abc' do
        expect(utils.is_valid('abc')).to be(false)
      end

      it 'rejects abc123' do
        expect(utils.is_valid('abc123')).to be(false)
      end

      it 'rejects repeated-digit CPFs' do
        aggregate_failures do
          expect(utils.is_valid('00000000000')).to be(false)
          expect(utils.is_valid('11111111111')).to be(false)
        end
      end

      it 'validates an array of strings' do
        expect(utils.is_valid(%w[123 456 78909])).to be(true)
      end

      it 'raises TypeMismatchError for a non-string input' do
        expect { utils.is_valid(123) }.to raise_error(CpfVal::TypeMismatchError)
      end

      it 'raises TypeMismatchError for a boolean input' do
        expect { utils.is_valid(true) }.to raise_error(CpfVal::TypeMismatchError)
      end

      it 'raises TypeMismatchError for a nil input' do
        expect { utils.is_valid(nil) }.to raise_error(CpfVal::TypeMismatchError)
      end

      it 'raises TypeMismatchError for a non-string array' do
        expect { utils.is_valid([1, 2, 3]) }.to raise_error(CpfVal::TypeMismatchError)
      end

      it 'raises TypeMismatchError for a Hash input' do
        expect { utils.is_valid({ a: 1 }) }.to raise_error(CpfVal::TypeMismatchError)
      end
    end
  end

  describe 'integration' do
    it 'uses the owned component instances for all methods' do
      utils = described_class.new
      formatter = instance_double(CpfFmt::CpfFormatter)
      generator = instance_double(CpfGen::CpfGenerator)
      validator = instance_double(CpfVal::CpfValidator)

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
    it 'formats through DEFAULT with custom delimiters' do
      result = described_class::DEFAULT.format('12345678909', dot_key: '_', dash_key: ' dv ')

      expect(result).to eq('123_456_789 dv 09')
    end

    it 'formats through CpfFmt.cpf_fmt' do
      result = CpfFmt.cpf_fmt('12345678909', dot_key: '_', dash_key: ' dv ')

      expect(result).to eq('123_456_789 dv 09')
    end

    it 'formats through an owned CpfFormatter' do
      formatter = CpfFmt::CpfFormatter.new(hidden: true)

      expect(formatter.format('12345678909')).to eq('123.***.***-**')
    end

    it 'generates a CPF through DEFAULT' do
      result = described_class::DEFAULT.generate

      aggregate_failures do
        expect(result.length).to eq(11)
        expect(result).to match(/\A\d{11}\z/)
      end
    end

    it 'generates through CpfGen.cpf_gen' do
      result = CpfGen.cpf_gen

      aggregate_failures do
        expect(result.length).to eq(11)
        expect(result).to match(/\A\d{11}\z/)
      end
    end

    it 'validates through DEFAULT' do
      aggregate_failures do
        expect(described_class::DEFAULT.is_valid('12345678909')).to be(true)
        expect(described_class::DEFAULT.is_valid('12345678900')).to be(false)
      end
    end

    it 'validates through CpfVal.cpf_val' do
      aggregate_failures do
        expect(CpfVal.cpf_val('12345678909')).to be(true)
        expect(CpfVal.cpf_val('12345678900')).to be(false)
      end
    end
  end
end
