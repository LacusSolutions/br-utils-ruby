![cpf-utilities for Ruby](https://br-utils.vercel.app/img/cover_cpf-utils.jpg)

[![Gem Version](https://img.shields.io/gem/v/cpf-utilities)](https://rubygems.org/gems/cpf-utilities)
[![Gem Downloads](https://img.shields.io/gem/dt/cpf-utilities)](https://rubygems.org/gems/cpf-utilities)
[![Ruby Version](https://img.shields.io/gem/rv/cpf-utilities)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby toolkit to format, generate, and validate CPF (Brazilian Individual's Taxpayer ID). It wraps [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt), [`cpf-gen`](https://rubygems.org/gems/cpf-gen), and [`cpf-val`](https://rubygems.org/gems/cpf-val) in a single façade class (`CpfUtils`).

## Ruby Support

| ![Ruby 3.1](https://img.shields.io/badge/Ruby-3.1-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) | ![Ruby 4.0](https://img.shields.io/badge/Ruby-4.0-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Unified API**: Class helpers `CpfUtils.format` / `.generate` / `.is_valid`
- ✅ **Two-tier access**: Prefer `CpfUtils::CpfFormatter` / `CpfGenerator` / `CpfValidator` for the main classes; Options, helpers, and errors live under `CpfUtils::CpfFmt` / `CpfGen` / `CpfVal` (root siblings `CpfFmt` / `CpfGen` / `CpfVal` still work)
- ✅ **Numeric CPF**: Format, generate, and validate 11-digit numeric CPF (`XXX.XXX.XXX-XX`)
- ✅ **Reusable instance**: `CpfUtils` class with optional default settings (formatter/generator options or instances; validator instance)
- ✅ **Flexible input**: `#format` and `#is_valid` accept a `String` or an `Array` of strings (elements concatenated in order)
- ✅ **Per-call overrides**: Instance defaults plus a per-call options `Hash`/`*Options` instance **or** keyword overrides on `#format` / `#generate` (not both); `#is_valid` takes input only
- ✅ **Error handling**: Component errors propagate unchanged; this gem defines `CpfUtils::TypeMismatchError` and `CpfUtils::InvalidArgumentCombinationError` for API misuse

## Installation

Install the gem directly:

```bash
gem install cpf-utilities
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cpf-utilities'
```

This installs **`cpf-utilities`** together with [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt), [`cpf-gen`](https://rubygems.org/gems/cpf-gen), and [`cpf-val`](https://rubygems.org/gems/cpf-val). You do **not** need separate `gem install` / `gem` lines for the component packages when using **`cpf-utilities`**.

## Require

```ruby
require 'cpf-utilities'
```

## Quick Start

Basic usage with class helpers (aliases of `CpfUtils::DEFAULT`):

```ruby
require 'cpf-utilities'

cpf = '12345678909'

CpfUtils.format(cpf)                 # => "123.456.789-09"
CpfUtils.format(cpf, hidden: true)   # => "123.***.***-**"
CpfUtils.format(                     # => "123456789_09"
  cpf,
  dot_key: '',
  dash_key: '_'
)

CpfUtils.generate                       # => e.g. "47844241055" (11-digit numeric)
CpfUtils.generate(format: true)         # => e.g. "478.442.410-55"
CpfUtils.generate(prefix: '528250911')  # => e.g. "52825091138"

CpfUtils.is_valid('12345678909')      # => true
CpfUtils.is_valid('123.456.789-09')   # => true
CpfUtils.is_valid('12345678900')      # => false
```

## Usage

You can work in these equivalent ways:

1. **`CpfUtils.format` / `.generate` / `.is_valid`** — class helpers for quick one-off calls (forward to `DEFAULT`).
2. **`CpfUtils::DEFAULT`** — mutable shared singleton (same object the class helpers use).
3. **`CpfUtils.new`** — configurable instance with shared defaults across format, generate, and validate.
4. **Main classes under `CpfUtils`** — `CpfUtils::CpfFormatter`, `CpfUtils::CpfGenerator`, `CpfUtils::CpfValidator`.
5. **Nested package modules** — Options, helpers, errors, and types via `CpfUtils::CpfFmt` / `CpfGen` / `CpfVal` (e.g. `CpfUtils::CpfFmt::CpfFormatterOptions`, `CpfUtils::CpfFmt.cpf_fmt`).
6. **Root sibling modules** (still supported) — `CpfFmt`, `CpfGen`, `CpfVal` unchanged.

All approaches expose the same options and behavior. For exhaustive option tables and component-specific details, see the README of each [bundled package](#bundled-packages).

### Formatter options

When calling `#format(cpf_input, options = nil, **keywords)`, all options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | When `true`, mask digits in `hidden_start`–`hidden_end` with `hidden_key` |
| `hidden_key` | `String` | `'*'` | Character(s) used to replace masked digits |
| `hidden_start` | `Integer` | `3` | Start index (0–10, inclusive) of the range to hide |
| `hidden_end` | `Integer` | `10` | End index (0–10, inclusive) of the range to hide |
| `dot_key` | `String` | `'.'` | Dot delimiter (e.g. in `123.456.789`) |
| `dash_key` | `String` | `'-'` | Dash delimiter (e.g. before check digits `…-09`) |
| `escape` | `Boolean` | `false` | When `true`, escape HTML special characters in the result |
| `encode` | `Boolean` | `false` | When `true`, URL-encode the result (similar to JavaScript `encodeURIComponent`) |
| `on_fail` | `Proc` / callable | returns `''` | Callback when sanitized input length ≠ 11; return value is used as result |

### Generator options

When calling `#generate(options = nil, **keywords)`, all options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When `true`, return the generated CPF in standard format (`000.000.000-00`) |
| `prefix` | `String` | `''` | Partial start string (0–9 digits). Non-digits are stripped; missing characters are generated and check digits computed. Prefixes longer than 9 digits are truncated silently. |

Prefix rules: the base (first 9 digits) cannot be all zeros; 9 repeated digits (e.g. `999999999`) are not allowed.

### Class helpers (`CpfUtils.format` / `.generate` / `.is_valid`)

These class methods are aliases of the same methods on `CpfUtils::DEFAULT`. Prefer them for one-off calls:

```ruby
CpfUtils.format('12345678909')
CpfUtils.generate(format: true)
CpfUtils.is_valid('12345678909')
```

### `CpfUtils::DEFAULT` (default instance)

`CpfUtils::DEFAULT` is the pre-built, **mutable** singleton behind the class helpers (parity with the JS default export / Python `cpf_utils`). Mutating it affects subsequent `CpfUtils.format` / `.generate` / `.is_valid` calls; custom `CpfUtils.new` instances stay independent:

```ruby
CpfUtils::DEFAULT.formatter = { dash_key: '|' }
CpfUtils.format('12345678909')   # => "123.456.789|09"

custom = CpfUtils.new
custom.format('12345678909')     # => "123.456.789-09" (unaffected)
```

Instance methods on `DEFAULT` (and any `CpfUtils` instance):

- **`#format(cpf_input, options = nil, **keywords)`**: Formats a CPF string or array of strings. Delegates to the internal formatter. Input must be 11 digits (after sanitization); otherwise `on_fail` is used.
- **`#generate(options = nil, **keywords)`**: Generates a valid CPF. Delegates to the internal generator.
- **`#is_valid(cpf_input)`**: Returns `true` if the CPF is valid. Delegates to the internal validator. No per-call options — the CPF validator has none.

### `CpfUtils` (class)

For custom default formatter, generator, or validator, create your own instance:

```ruby
require 'cpf-utilities'

utils = CpfUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true, prefix: '123' }
)

utils.format('47844241055')        # => "478.###.###-##"
utils.generate                     # => e.g. "123.456.789-09"
utils.is_valid('123.456.789-09')   # => true

# Access or replace internal instances
utils.formatter   # => CpfFmt::CpfFormatter
utils.generator   # => CpfGen::CpfGenerator
utils.validator   # => CpfVal::CpfValidator
```

- **`CpfUtils.new(settings = nil, **keywords)`**: Optional settings. Pass either a settings `Hash` with `:formatter`, `:generator`, and/or `:validator` keys, **or** the same keys as keyword arguments — not both (passing both raises `CpfUtils::InvalidArgumentCombinationError`). For `:formatter` / `:generator`, each value may be a component instance, a `*Options` instance (stored by reference — mutating it later affects subsequent calls with no per-call override), a plain options `Hash`, or omitted/`nil` for defaults. For `:validator`, pass a `CpfVal::CpfValidator` instance, `nil`, or a duck-typed object — **not** an options `Hash` (there is no `CpfValidatorOptions`).
- **`#format(cpf_input, options = nil, **keywords)`**: Same as the default instance; per-call options override the formatter’s defaults for that call only. Pass either an options `Hash`/`CpfFmt::CpfFormatterOptions` **or** keyword overrides — not both.
- **`#generate(options = nil, **keywords)`**: Same as the default instance; per-call options override the generator’s defaults. Pass either an options `Hash`/`CpfGen::CpfGeneratorOptions` **or** keyword overrides — not both.
- **`#is_valid(cpf_input)`**: Same as the default instance. No per-call options.
- **`#formatter`**, **`#generator`**, **`#validator`**: Accessors (getters and setters) for the internal components. Setters accept the same shapes as the constructor. To change a single formatter/generator option without replacing the instance, mutate the component’s options (e.g. `utils.formatter.options.hidden = true`).

Instance defaults and per-call overrides:

```ruby
require 'cpf-utilities'

utils = CpfUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true }
)

cpf = '12345678909'

utils.format(cpf)                  # masked (instance formatter defaults)
utils.format(cpf, hidden: false)   # this call only: unmasked
utils.generate(format: false)      # this call only: compact output
utils.is_valid(cpf)                # => true
```

Options can also be passed as a `Hash` (or options instance) on `#format` / `#generate` — without keyword overrides:

```ruby
utils.format(cpf, { dash_key: '|' })
utils.generate({ prefix: '12345', format: true })
```

### Using component classes and nested modules

Preferred paths after `require 'cpf-utilities'`:

```ruby
require 'cpf-utilities'

# Main classes at the façade root
formatter = CpfUtils::CpfFormatter.new(hidden: true)
generator = CpfUtils::CpfGenerator.new(format: true)
validator = CpfUtils::CpfValidator.new

formatter.format('47844241055')   # => "478.***.***-**"

# Options, helpers, and errors under nested package modules
options = CpfUtils::CpfFmt::CpfFormatterOptions.new(dash_key: '|')
CpfUtils::CpfFmt.cpf_fmt('12345678909')   # => "123.456.789-09"

begin
  CpfUtils::CpfFmt.cpf_fmt(12_345)
rescue CpfUtils::CpfFmt::TypeMismatchError
  # wrong input type
end
```

Root siblings remain supported (same objects as the nests):

```ruby
CpfFmt.cpf_fmt('12345678909', dash_key: '|')   # => "123.456.789|09"
CpfGen.cpf_gen(format: true)                   # => e.g. "478.442.410-55"
CpfVal.cpf_val('12345678909')                  # => true
CpfFmt::CpfFormatter.new(hidden: true)
```

See [`cpf-fmt`](../cpf-fmt/README.md), [`cpf-gen`](../cpf-gen/README.md), and [`cpf-val`](../cpf-val/README.md) for full option and error details.

## API

### Exports

After `require 'cpf-utilities'`:

- **`CpfUtils`**: Façade class to create a utils instance with optional default formatter, generator, and validator settings.
- **`CpfUtils.format` / `.generate` / `.is_valid`**: Class helpers that forward to `CpfUtils::DEFAULT`.
- **`CpfUtils::DEFAULT`**: Mutable pre-built `CpfUtils` instance (same object the class helpers use).
- **`CpfUtils::VERSION`**: Gem version string.
- **Main-class shortcuts**: `CpfUtils::CpfFormatter`, `CpfUtils::CpfGenerator`, `CpfUtils::CpfValidator` (same objects as the sibling classes).
- **Nested package modules**: `CpfUtils::CpfFmt`, `CpfUtils::CpfGen`, `CpfUtils::CpfVal` — full sibling surface (Options, helpers, errors, types). Options/helpers/errors are **not** aliased at the `CpfUtils` root.
- **Root sibling modules** (still supported): `CpfFmt`, `CpfGen`, `CpfVal` — same objects as the nests.

### Errors & Exceptions

`CpfUtils` defines only API-misuse errors for this gem’s argument rules. Component errors are raised by the bundled packages and propagate unchanged.

#### Defined by `cpf-utilities`

Errors defined by this gem are **API misuse** only (wrong type or invalid argument combination). Every custom error includes the `CpfUtils::Error` marker module. This gem defines **no** `CpfUtils::DomainError` and no domain leaves — domain failures come only from the [bundled packages](#propagated-from-bundled-packages) and keep those packages’ namespaces (`CpfFmt::…`, `CpfGen::…`, `CpfVal::…`).

`rescue CpfUtils::Error` catches **only** errors this gem raises. It does **not** catch component errors that propagate unchanged.

##### Summary

| Class | Inherits from | Category | Trigger condition |
|-------|---------------|----------|-------------------|
| `CpfUtils::TypeMismatchError` | `CpfUtils::TypeMismatchError < TypeError < StandardError` (+ `include CpfUtils::Error`) | API misuse | Non-`nil` `settings` argument to `CpfUtils.new` is not a `Hash` |
| `CpfUtils::InvalidArgumentCombinationError` | `CpfUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (+ `include CpfUtils::Error`) | API misuse | Non-`nil` settings/options `Hash` (or options instance) passed together with any non-`nil` keyword argument |

##### `CpfUtils::Error` (marker module)

- **Inheritance:** module marker mixed into every custom error this gem raises via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error this gem raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CpfUtils::Error
  # TypeMismatchError, InvalidArgumentCombinationError from this gem only
  # (not CpfFmt::*, CpfGen::*, or CpfVal::* errors)
```

##### `CpfUtils::TypeMismatchError`

- **Inheritance:** `CpfUtils::TypeMismatchError < TypeError < StandardError` (includes `CpfUtils::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when `CpfUtils.new` receives a non-`nil` `settings` argument that is not a `Hash`.
- **Example:**

```ruby
CpfUtils.new('not-a-hash')   # raises CpfUtils::TypeMismatchError
CpfUtils.new(false)          # raises CpfUtils::TypeMismatchError (false is non-nil)
```

- **How to rescue it:**

```ruby
rescue CpfUtils::TypeMismatchError
  # this gem's type-contract violation

rescue TypeError
  # native type errors, including this gem's TypeMismatchError
```

##### `CpfUtils::InvalidArgumentCombinationError`

- **Inheritance:** `CpfUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (includes `CpfUtils::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `CpfUtils.new`, `#format`, `#generate`, or the class helpers receive both a non-`nil` settings/options `Hash` (or options instance) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
CpfUtils.new({ formatter: { hidden: true } }, generator: { format: true })
# raises CpfUtils::InvalidArgumentCombinationError

CpfUtils.format('12345678909', { hidden: true }, dash_key: '|')
# raises CpfUtils::InvalidArgumentCombinationError
```

- **How to rescue it:**

```ruby
rescue CpfUtils::InvalidArgumentCombinationError
  # this gem's invalid signature combination

rescue ArgumentError
  # native argument errors, including this gem's InvalidArgumentCombinationError
```

##### Rescue granularity

Each level is shown as its own standalone example (do not merge them into one `rescue` ladder — a broad native handler would make narrower clauses unreachable).

```ruby
require 'cpf-utilities'

# 1) Single native class — catches misuse errors of that kind,
#    including non-library ones already handled elsewhere in the consumer's code.
begin
  CpfUtils.new('not-a-hash')
rescue TypeError
  # CpfUtils::TypeMismatchError and any other TypeError (library or not)
end

begin
  CpfUtils.new({ formatter: { hidden: true } }, generator: { format: true })
rescue ArgumentError
  # CpfUtils::InvalidArgumentCombinationError and any other ArgumentError (library or not)
end
```

```ruby
require 'cpf-utilities'

# 2) CpfUtils::DomainError — not applicable: this gem defines no DomainError
#    (and no domain leaves). Domain failures come from bundled packages only.
# begin
#   CpfUtils.new.format(12_345)
# rescue CpfUtils::DomainError  # NameError — constant is not defined
# end
```

```ruby
require 'cpf-utilities'

# 3) CpfUtils::Error — catches everything this gem raises, regardless of native ancestry.
#    Does not catch CpfFmt::*, CpfGen::*, or CpfVal::* errors.
begin
  CpfUtils.new('not-a-hash')
rescue CpfUtils::Error
  # every custom error that includes CpfUtils::Error
end
```

```ruby
require 'cpf-utilities'

# 4) Specific leaf class — catches only that exact failure mode.
begin
  CpfUtils.new('not-a-hash')
rescue CpfUtils::TypeMismatchError
  # only CpfUtils::TypeMismatchError
end
```

#### Propagated from bundled packages

- **Formatting** (`CpfFmt`): `CpfFmt::TypeMismatchError`, `CpfFmt::OutOfRangeError`, `CpfFmt::ValidationError`, `CpfFmt::InvalidLengthError` (passed to `on_fail`, not raised by `#format`), and related classes.
- **Generation** (`CpfGen`): `CpfGen::TypeMismatchError`, `CpfGen::ValidationError`, and related classes.
- **Validation** (`CpfVal`): `CpfVal::TypeMismatchError` and related classes.

Invalid option types are typically **`TypeError`** subclasses (`*::TypeMismatchError`); invalid option values are domain errors under each package’s `DomainError` hierarchy (where defined). Validation failure returns `false`; formatting length failure is handled by **`on_fail`** (default returns an empty string).

```ruby
require 'cpf-utilities'

begin
  CpfUtils.new.format(12_345)
rescue CpfFmt::TypeMismatchError => e
  puts e.message
end

begin
  CpfUtils.new.is_valid(12_345_678_909)
rescue CpfVal::TypeMismatchError => e
  puts e.message
end

# Custom on_fail for invalid length
custom_fail = ->(value, _exception) { "Invalid CPF: #{value}" }

CpfFmt.cpf_fmt('123', on_fail: custom_fail)   # => "Invalid CPF: 123"
CpfFmt.cpf_fmt('123')                         # => "" (default on_fail)
```

### Bundled packages

| Package | Main resources | README |
|---------|----------------|--------|
| [`cpf-fmt`](https://rubygems.org/gems/cpf-fmt) | `CpfFmt::CpfFormatter`, `CpfFmt::CpfFormatterOptions`, `CpfFmt.cpf_fmt` | [docs](../cpf-fmt/README.md) |
| [`cpf-gen`](https://rubygems.org/gems/cpf-gen) | `CpfGen::CpfGenerator`, `CpfGen::CpfGeneratorOptions`, `CpfGen.cpf_gen` | [docs](../cpf-gen/README.md) |
| [`cpf-val`](https://rubygems.org/gems/cpf-val) | `CpfVal::CpfValidator`, `CpfVal.cpf_val` | [docs](../cpf-val/README.md) |

All of the above are pulled in as dependencies of **`cpf-utilities`**. For exhaustive option tables, exception lists, and edge-case behavior, see each package README.

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
