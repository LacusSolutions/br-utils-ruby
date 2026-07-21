![cpf-gen for Ruby](https://br-utils.vercel.app/img/cover_cpf-gen.jpg)

[![Gem Version](https://img.shields.io/gem/v/cpf-gen)](https://rubygems.org/gems/cpf-gen)
[![Gem Downloads](https://img.shields.io/gem/dt/cpf-gen)](https://rubygems.org/gems/cpf-gen)
[![Ruby Version](https://img.shields.io/gem/rv/cpf-gen)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to generate valid CPF (Brazilian Individual's Taxpayer ID) values.

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Numeric CPF**: Generates 11-digit numeric CPF values with valid check digits
- ✅ **Optional prefix**: Provide 0–9 digits to fix the start of the CPF and generate the rest with valid check digits
- ✅ **Formatting**: Option to return the standard formatted string (`000.000.000-00`)
- ✅ **Reusable generator**: `CpfGen::CpfGenerator` class with default options and per-call overrides
- ✅ **Keyword overrides**: Pass `format:` and `prefix:` on `cpf_gen`, `CpfGenerator#generate`, and constructors
- ✅ **Minimal dependencies**: Only [`cpf-dv`](https://rubygems.org/gems/cpf-dv) and [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: API misuse vs domain errors with a `CpfGen::Error` marker for library-wide rescue

## Installation

Install the gem directly:

```bash
gem install cpf-gen
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cpf-gen'
```

## Require

```ruby
require 'cpf-gen'
```

## Quick Start

```ruby
require 'cpf-gen'

CpfGen.cpf_gen                    # => e.g. "47844241055" (11-digit numeric)

CpfGen.cpf_gen(format: true)      # => e.g. "005.265.352-88"

CpfGen.cpf_gen(prefix: '528250911')           # => e.g. "52825091138"
CpfGen.cpf_gen(                              # => e.g. "528.250.911-38"
  prefix: '528250911',
  format: true
)
```

Options can also be passed as a `Hash`:

```ruby
CpfGen.cpf_gen({ format: true, prefix: '528250911' })
```

## Usage

The main entry points are the module helper `CpfGen.cpf_gen`, the class `CpfGen::CpfGenerator`, and the options class `CpfGen::CpfGeneratorOptions`.

### Generator options

All options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When truthy, return the generated CPF in standard format (`000.000.000-00`). Non-boolean values are coerced (`false`, `''`, and `0` become `false`; other values become truthy). |
| `prefix` | `String` | `''` | Partial start string (0–9 digits). Only digits are kept; missing characters are generated randomly and check digits are computed. Prefixes longer than 9 digits are truncated silently. |

Prefix rules: the base (first 9 digits) cannot be all zeros; 9 repeated digits (e.g. `999999999`) are not allowed. Prefixes shorter than 9 digits are never rejected by these rules (e.g. `"00000000"` and `"11111111"` are allowed).

`nil` is accepted as a keyword argument on `cpf_gen`, `CpfGenerator.new`, `CpfGenerator#generate`, and `CpfGeneratorOptions.new`/`#set` — it simply means "no override for this option". It is **not** accepted by the `CpfGeneratorOptions` property setters (`options.format = value`, `options.prefix = value`): calling a setter with `nil` directly raises `CpfGen::TypeMismatchError`. To reset a property to its default value through a setter, pass the literal constant instead, e.g. `options.format = CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT`.

### `CpfGen.cpf_gen` (helper)

Generates a valid CPF string. With no options, returns an 11-digit numeric CPF. This is a convenience wrapper around `CpfGen::CpfGenerator.new(...).generate`.

- **`options`** (optional): `CpfGen::CpfGeneratorOptions` instance, a `Hash` of option keys, or `nil`. See [Generator options](#generator-options).
- **`format`**, **`prefix`** (keyword arguments): Only used when `options` is omitted (`nil`). Passing `options` **and** any of these keywords at the same time raises `InvalidArgumentCombinationError` — the two ways of passing options are never merged together.

### `CpfGen::CpfGenerator` (class)

For reusable defaults or per-call overrides, use the class:

```ruby
require 'cpf-gen'

generator = CpfGen::CpfGenerator.new(format: true)

generator.generate                    # => e.g. "005.265.352-88"
generator.generate(prefix: '123456')  # override for this call only
generator.options                     # current default options (CpfGen::CpfGeneratorOptions)
```

- **`initialize(options = nil, **keywords)`**: Optional default options. When `options` is given (a `CpfGen::CpfGeneratorOptions` instance or a `Hash`) alone, it determines the default options; a `CpfGen::CpfGeneratorOptions` instance is stored by reference (mutating it later affects future `generate` calls that do not pass per-call options), while a `Hash` builds a new instance. When `options` is omitted (`nil`), the default options are built exclusively from the keyword arguments (`format:`, `prefix:`). Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError` instead of silently ignoring the keywords.
- **`generate(options = nil, **keywords)`**: Returns a valid CPF. `options` and the keyword arguments are never merged: a given `options` argument alone fully overrides the instance defaults for this call; otherwise, any given keyword overrides the instance defaults for this call. When neither is given, the instance defaults are used as-is. The instance defaults are never mutated by a per-call override. Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError`.
- **`options`**: Reader returning the default options used when per-call options are not provided (same instance as used internally; mutating it affects future `generate` calls).

Default options on the instance; per-call overrides:

```ruby
require 'cpf-gen'

generator = CpfGen::CpfGenerator.new(format: true)

generator.generate              # formatted CPF
generator.generate(format: false)  # this call only: unformatted
generator.generate              # formatted again (instance defaults preserved)
```

### `CpfGen::CpfGeneratorOptions` (class)

Holds options (`format`, `prefix`) with validation and merge support:

```ruby
require 'cpf-gen'

options = CpfGen::CpfGeneratorOptions.new(
  prefix: '123456',
  format: true
)
options.prefix   # => "123456"
options.format   # => true
options.set(format: false)  # merge and return self
options.all      # => { format: false, prefix: "123456" }

# Resetting a property to its default value requires the literal constant —
# a bare `nil` on a setter raises TypeMismatchError:
options.format = CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT
```

- **`initialize(*options, **keywords)`**: Every positional `options` argument (each a `Hash` or another `CpfGen::CpfGeneratorOptions` instance) is folded left to right — later arguments win — then the keyword arguments (`format:`, `prefix:`) are applied on top with the highest precedence. At every step, a `nil` value for a given key is ignored in favor of whatever was resolved so far. Any option still unresolved after that is set to its `DEFAULT_*` value.
- **`format`**, **`prefix`**: Accessors with setters; `prefix` is validated (zeroed base ID, repeated digits). The setters **never accept `nil`** — pass the matching `DEFAULT_*` constant (e.g. `CpfGeneratorOptions::DEFAULT_PREFIX`) to reset a property explicitly.
- **`set(*options, **keywords)`**: Updates multiple options at once, using the same fold-then-keywords, ignore-`nil` resolution as `initialize`. Any option left unresolved after merging keeps its **current** value on the instance (a partial update, not a re-initialization). Returns `self`.
- **`all`**: Shallow `Hash` copy of current options (`:format`, `:prefix`).

## API

### Exports

After `require 'cpf-gen'`:

- **`CpfGen.cpf_gen`**: `(options = nil, **keywords) -> String` — convenience helper.
- **`CpfGen::CpfGenerator`**: Class to generate CPF with optional default options and per-call overrides.
- **`CpfGen::CpfGeneratorOptions`**: Class holding options with validation and merge.
- **`CpfGen::CPF_LENGTH`**: `11` (constant).
- **`CpfGen::CPF_PREFIX_MAX_LENGTH`**: `9` (constant).
- **`CpfGen::VERSION`**: gem version string.
- **Errors**: `CpfGen::Error`, `CpfGen::DomainError`, `CpfGen::InvalidArgumentCombinationError`, `CpfGen::TypeMismatchError`, `CpfGen::ValidationError`.

### Error handling

Errors fall into two categories:

| Category | Meaning |
|---|---|
| **API misuse** | The caller invoked the library incorrectly (wrong type for an option, or an invalid argument combination). |
| **Domain error** | The call was structurally correct, but a value violates a business rule (invalid `prefix`). |

Every custom error includes the `CpfGen::Error` marker module. Domain failures (`ValidationError`) inherit from `CpfGen::DomainError` (`RangeError`).

**Important:** passing both an `options` instance/`Hash` and keyword arguments raises `InvalidArgumentCombinationError`.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CpfGen::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Both an `options` instance/`Hash` and keyword arguments are passed at once |
| `CpfGen::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | A generator option has the wrong data type |
| `CpfGen::ValidationError` | `CpfGen::DomainError` | Domain error | `prefix` is ineligible (zeroed base ID or 9 repeated digits) |

#### `CpfGen::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CpfGen::Error
  # everything this library raises
```

#### `CpfGen::DomainError`

- **Inheritance:** `CpfGen::DomainError < RangeError` (includes `CpfGen::Error`)
- **Category:** Domain error — ancestor for all domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CpfGen::ValidationError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CpfGen::DomainError
  # ValidationError and other DomainError subclasses
```

#### `CpfGen::TypeMismatchError`

- **Inheritance:** `CpfGen::TypeMismatchError < TypeError` (includes `CpfGen::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when a generator option (`format` or `prefix`) has the wrong runtime type.
- **Example:**

```ruby
CpfGen.cpf_gen(prefix: 123) # raises CpfGen::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CpfGen::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CpfGen::InvalidArgumentCombinationError`

- **Inheritance:** `CpfGen::InvalidArgumentCombinationError < ArgumentError` (includes `CpfGen::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `CpfGenerator.new`, `#generate`, or `cpf_gen` receives both an `options` argument (instance or `Hash`) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
begin
  CpfGen::CpfGenerator.new({ format: true }, prefix: '123')
rescue CpfGen::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (format:, prefix:), not both.
end
```

- **How to rescue it:**

```ruby
rescue CpfGen::InvalidArgumentCombinationError
  # this library's invalid argument combination

rescue ArgumentError
  # native argument errors, including this library's InvalidArgumentCombinationError
```

#### `CpfGen::ValidationError`

- **Inheritance:** `CpfGen::ValidationError < CpfGen::DomainError < RangeError` (includes `CpfGen::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when `prefix` is ineligible (zeroed base ID `"000000000"`, or 9 repeated digits such as `"999999999"`).
- **Example:**

```ruby
CpfGen.cpf_gen(prefix: '000000000') # raises CpfGen::ValidationError
CpfGen.cpf_gen(prefix: '999999999') # raises CpfGen::ValidationError
```

- **How to rescue it:**

```ruby
rescue CpfGen::ValidationError
  # this exact domain validation failure

rescue CpfGen::DomainError
  # RangeError-rooted domain failures from this library
```

#### Rescue granularity

```ruby
# 1) Single native class — catches type misuse from this library (and other TypeErrors).
rescue TypeError
  # CpfGen::TypeMismatchError and any other TypeError (library or not)

# 2) CpfGen::DomainError — catches business-rule violations under DomainError.
rescue CpfGen::DomainError
  # CpfGen::ValidationError and other DomainError subclasses

# 3) CpfGen::Error — catches everything the library raises.
rescue CpfGen::Error
  # every custom error that includes CpfGen::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CpfGen::ValidationError
  # only CpfGen::ValidationError
```

Notable attributes:

- `TypeMismatchError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `reason` (prefix failures); `expected_values` is always `nil` for CPF

Property setters never accept `nil` directly — pass the matching `DEFAULT_*` constant to reset:

```ruby
options = CpfGen::CpfGeneratorOptions.new
begin
  options.prefix = nil
rescue CpfGen::TypeMismatchError => e
  puts e.message
  # CPF generator option "prefix" must be of type string. Got nil.
end

options.prefix = CpfGen::CpfGeneratorOptions::DEFAULT_PREFIX # explicit reset instead
```

Check-digit computation failures from `cpf-dv` are handled internally by retrying generation with the same resolved options; they are not raised to callers under normal operation.

### Other available resources

- **`CpfGen::CpfGeneratorOptions::CPF_LENGTH`**: `11`.
- **`CpfGen::CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH`**: `9`.
- **`CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT`**, **`DEFAULT_PREFIX`**: Class-level default constants.

## Contribution & Support

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md) for details. If you find this project helpful, please consider:

- ⭐ Starring the repository
- 🤝 Contributing to the codebase
- 💡 [Suggesting new features](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reporting bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## License

This project is licensed under the MIT License — see the [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE) file for details.

## Changelog

See [CHANGELOG](./CHANGELOG.md) for a list of changes and version history.

---

Made with ❤️ by [Lacus Solutions](https://github.com/LacusSolutions)
