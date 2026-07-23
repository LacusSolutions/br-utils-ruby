![cnpj-utilities for Ruby](https://br-utils.vercel.app/img/cover_cnpj-utils.jpg)

[![Gem Version](https://img.shields.io/gem/v/cnpj-utilities)](https://rubygems.org/gems/cnpj-utilities)
[![Gem Downloads](https://img.shields.io/gem/dt/cnpj-utilities)](https://rubygems.org/gems/cnpj-utilities)
[![Ruby Version](https://img.shields.io/gem/rv/cnpj-utilities)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby toolkit to format, generate, and validate CNPJ (Brazilian Business Tax ID). It wraps [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt), [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen), and [`cnpj-val`](https://rubygems.org/gems/cnpj-val) in a single façade class (`CnpjUtils`).

## Ruby Support

| ![Ruby 3.1](https://img.shields.io/badge/Ruby-3.1-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) | ![Ruby 4.0](https://img.shields.io/badge/Ruby-4.0-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Unified API**: Class helpers `CnpjUtils.format` / `.generate` / `.is_valid`
- ✅ **Two-tier access**: Prefer `CnpjUtils::CnpjFormatter` / `CnpjGenerator` / `CnpjValidator` for the main classes; Options, helpers, and errors live under `CnpjUtils::CnpjFmt` / `CnpjGen` / `CnpjVal` (root siblings `CnpjFmt` / `CnpjGen` / `CnpjVal` still work)
- ✅ **Alphanumeric CNPJ**: Format, generate, and validate 14-character numeric or alphanumeric CNPJ
- ✅ **Reusable instance**: `CnpjUtils` class with optional default settings (formatter, generator, validator options or instances)
- ✅ **Flexible input**: `#format` and `#is_valid` accept a `String` or an `Array` of strings (elements concatenated in order)
- ✅ **Per-call overrides**: Instance defaults plus a per-call options `Hash`/`*Options` instance **or** keyword overrides (not both)
- ✅ **Error handling**: Component errors propagate unchanged; this gem defines `CnpjUtils::TypeMismatchError` and `CnpjUtils::InvalidArgumentCombinationError` for API misuse

## Installation

Install the gem directly:

```bash
gem install cnpj-utilities
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cnpj-utilities'
```

This installs **`cnpj-utilities`** together with [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt), [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen), and [`cnpj-val`](https://rubygems.org/gems/cnpj-val). You do **not** need separate `gem install` / `gem` lines for the component packages when using **`cnpj-utilities`**.

## Require

```ruby
require 'cnpj-utilities'
```

## Quick Start

Basic usage with class helpers (aliases of `CnpjUtils::DEFAULT`):

```ruby
require 'cnpj-utilities'

cnpj = '03603568000195'

CnpjUtils.format(cnpj)                # => "03.603.568/0001-95"
CnpjUtils.format(cnpj, hidden: true)  # => "03.603.***/****-**"
CnpjUtils.format(                     # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)

CnpjUtils.generate                       # => e.g. "AB123CDE000155" (14-char alphanumeric)
CnpjUtils.generate(format: true)         # => e.g. "AB.123.CDE/0001-55"
CnpjUtils.generate(prefix: '45623767')   # => e.g. "45623767000296"
CnpjUtils.generate(type: 'numeric')      # => e.g. "65453043000178" (digits only)

CnpjUtils.is_valid('98765432000198')       # => true
CnpjUtils.is_valid('98.765.432/0001-98')   # => true
CnpjUtils.is_valid('1QB5UKALPYFP59')       # => true (alphanumeric)
CnpjUtils.is_valid('98765432000199')       # => false
```

## Usage

You can work in these equivalent ways:

1. **`CnpjUtils.format` / `.generate` / `.is_valid`** — class helpers for quick one-off calls (forward to `DEFAULT`).
2. **`CnpjUtils::DEFAULT`** — mutable shared singleton (same object the class helpers use).
3. **`CnpjUtils.new`** — configurable instance with shared defaults across format, generate, and validate.
4. **Main classes under `CnpjUtils`** — `CnpjUtils::CnpjFormatter`, `CnpjUtils::CnpjGenerator`, `CnpjUtils::CnpjValidator`.
5. **Nested package modules** — Options, helpers, errors, and types via `CnpjUtils::CnpjFmt` / `CnpjGen` / `CnpjVal` (e.g. `CnpjUtils::CnpjFmt::CnpjFormatterOptions`, `CnpjUtils::CnpjFmt.cnpj_fmt`).
6. **Root sibling modules** (still supported) — `CnpjFmt`, `CnpjGen`, `CnpjVal` unchanged.

All approaches expose the same options and behavior. For exhaustive option tables and component-specific details, see the README of each [bundled package](#bundled-packages).

### Formatter options

When calling `#format(cnpj_input, options = nil, **keywords)`, all options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | When `true`, mask characters in `hidden_start`–`hidden_end` with `hidden_key` |
| `hidden_key` | `String` | `'*'` | Character(s) used to replace masked characters |
| `hidden_start` | `Integer` | `5` | Start index (0–13, inclusive) of the range to hide |
| `hidden_end` | `Integer` | `13` | End index (0–13, inclusive) of the range to hide |
| `dot_key` | `String` | `'.'` | Dot delimiter (e.g. in `12.345.678`) |
| `slash_key` | `String` | `'/'` | Slash delimiter (e.g. before branch `…/0001-90`) |
| `dash_key` | `String` | `'-'` | Dash delimiter (e.g. before check digits `…-90`) |
| `escape` | `Boolean` | `false` | When `true`, escape HTML special characters in the result |
| `encode` | `Boolean` | `false` | When `true`, URL-encode the result (similar to JavaScript `encodeURIComponent`) |
| `on_fail` | `Proc` / callable | returns `''` | Callback when sanitized input length ≠ 14; return value is used as result |

### Generator options

When calling `#generate(options = nil, **keywords)`, all options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When `true`, return the generated CNPJ in standard format (`00.000.000/0000-00`) |
| `prefix` | `String` | `''` | Partial start string (0–12 alphanumeric chars). Missing characters are generated and check digits computed. |
| `type` | `String` | `'alphanumeric'` | Character set for the randomly generated part: `'numeric'`, `'alphabetic'`, or `'alphanumeric'`. **Check digits are always numeric.** |

Prefix rules: base ID (first 8 chars) and branch ID (chars 9–12) cannot be all zeros; 12 repeated digits (e.g. `111111111111`) are also not allowed.

### Validator options

When calling `#is_valid(cnpj_input, options = nil, **keywords)`, all options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `case_sensitive` | `Boolean` | `true` | When `false`, lowercase letters are accepted for alphanumeric CNPJ (input is uppercased before validation). |
| `type` | `String` | `'alphanumeric'` | `'numeric'`: only digits (0–9); `'alphanumeric'`: digits and letters (0–9, A–Z). |

### Class helpers (`CnpjUtils.format` / `.generate` / `.is_valid`)

These class methods are aliases of the same methods on `CnpjUtils::DEFAULT`. Prefer them for one-off calls:

```ruby
CnpjUtils.format('03603568000195')
CnpjUtils.generate(type: 'numeric')
CnpjUtils.is_valid('98765432000198')
```

### `CnpjUtils::DEFAULT` (default instance)

`CnpjUtils::DEFAULT` is the pre-built, **mutable** singleton behind the class helpers (parity with the JS default export / Python `cnpj_utils`). Mutating it affects subsequent `CnpjUtils.format` / `.generate` / `.is_valid` calls; custom `CnpjUtils.new` instances stay independent:

```ruby
CnpjUtils::DEFAULT.formatter = { slash_key: '|' }
CnpjUtils.format('01ABC234000X56')   # => "01.ABC.234|000X-56"

custom = CnpjUtils.new
custom.format('01ABC234000X56')      # => "01.ABC.234/000X-56" (unaffected)
```

Instance methods on `DEFAULT` (and any `CnpjUtils` instance):

- **`#format(cnpj_input, options = nil, **keywords)`**: Formats a CNPJ string or array of strings. Delegates to the internal formatter. Input must be 14 alphanumeric characters (after sanitization); otherwise `on_fail` is used.
- **`#generate(options = nil, **keywords)`**: Generates a valid CNPJ. Delegates to the internal generator.
- **`#is_valid(cnpj_input, options = nil, **keywords)`**: Returns `true` if the CNPJ is valid. Delegates to the internal validator.

### `CnpjUtils` (class)

For custom default formatter, generator, or validator, create your own instance:

```ruby
require 'cnpj-utilities'

utils = CnpjUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { type: 'numeric', format: true },
  validator: { type: 'numeric', case_sensitive: false }
)

utils.format('RK0CMT3W000100')        # => "RK.0CM.###/####-##"
utils.generate                        # => e.g. "73.008.535/0005-06"
utils.is_valid('98.765.432/0001-98')  # => true

# Access or replace internal instances
utils.formatter  # => CnpjFmt::CnpjFormatter
utils.generator  # => CnpjGen::CnpjGenerator
utils.validator  # => CnpjVal::CnpjValidator
```

- **`CnpjUtils.new(settings = nil, **keywords)`**: Optional settings. Pass either a settings `Hash` with `:formatter`, `:generator`, and/or `:validator` keys, **or** the same keys as keyword arguments — not both (passing both raises `CnpjUtils::InvalidArgumentCombinationError`). Each value may be a component instance, a `*Options` instance (stored by reference — mutating it later affects subsequent calls with no per-call override), a plain options `Hash`, or omitted/`nil` for defaults.
- **`#format(cnpj_input, options = nil, **keywords)`**: Same as the default instance; per-call options override the formatter’s defaults for that call only. Pass either an options `Hash`/`CnpjFmt::CnpjFormatterOptions` **or** keyword overrides — not both.
- **`#generate(options = nil, **keywords)`**: Same as the default instance; per-call options override the generator’s defaults. Pass either an options `Hash`/`CnpjGen::CnpjGeneratorOptions` **or** keyword overrides — not both.
- **`#is_valid(cnpj_input, options = nil, **keywords)`**: Same as the default instance; per-call options override the validator’s defaults. Pass either an options `Hash`/`CnpjVal::CnpjValidatorOptions` **or** keyword overrides — not both.
- **`#formatter`**, **`#generator`**, **`#validator`**: Accessors (getters and setters) for the internal components. Setters accept the same shapes as the constructor. To change a single option without replacing the instance, mutate the component’s options (e.g. `utils.formatter.options.hidden = true`).

Instance defaults and per-call overrides:

```ruby
require 'cnpj-utilities'

utils = CnpjUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true },
  validator: { type: 'numeric' }
)

cnpj = '03603568000195'

utils.format(cnpj)                 # masked (instance formatter defaults)
utils.format(cnpj, hidden: false)  # this call only: unmasked
utils.generate(format: false)      # this call only: compact output
utils.is_valid('1QB5UKALPYFP59')   # => false (instance validator is numeric-only)
utils.is_valid(                    # => true for this call
  '1QB5UKALPYFP59',
  type: 'alphanumeric'
)
```

Options can also be passed as a `Hash` (or options instance) on each method — without keyword overrides:

```ruby
utils.format(cnpj, { slash_key: '|' })
utils.generate({ prefix: '12345', type: 'numeric' })
utils.is_valid('1QB5UKALPYFP59', { case_sensitive: false })
```

### Using component classes and nested modules

Preferred paths after `require 'cnpj-utilities'`:

```ruby
require 'cnpj-utilities'

# Main classes at the façade root
formatter = CnpjUtils::CnpjFormatter.new(hidden: true)
generator = CnpjUtils::CnpjGenerator.new(type: 'numeric')
validator = CnpjUtils::CnpjValidator.new

formatter.format('AB123XYZ000123')  # => "AB.123.***/****-**"

# Options, helpers, and errors under nested package modules
options = CnpjUtils::CnpjFmt::CnpjFormatterOptions.new(slash_key: '|')
CnpjUtils::CnpjFmt.cnpj_fmt('03603568000195')  # => "03.603.568/0001-95"

begin
  CnpjUtils::CnpjFmt.cnpj_fmt(12_345)
rescue CnpjUtils::CnpjFmt::TypeMismatchError
  # wrong input type
end
```

Root siblings remain supported (same objects as the nests):

```ruby
CnpjFmt.cnpj_fmt('01ABC234000X56', slash_key: '|')  # => "01.ABC.234|000X-56"
CnpjGen.cnpj_gen(type: 'numeric')                   # => e.g. "65453043000178"
CnpjVal.cnpj_val('9JN7MGLJZXIO50')                  # => true
CnpjFmt::CnpjFormatter.new(hidden: true)
```

See [`cnpj-fmt`](../cnpj-fmt/README.md), [`cnpj-gen`](../cnpj-gen/README.md), and [`cnpj-val`](../cnpj-val/README.md) for full option and error details.

## API

### Exports

After `require 'cnpj-utilities'`:

- **`CnpjUtils`**: Façade class to create a utils instance with optional default formatter, generator, and validator settings.
- **`CnpjUtils.format` / `.generate` / `.is_valid`**: Class helpers that forward to `CnpjUtils::DEFAULT`.
- **`CnpjUtils::DEFAULT`**: Mutable pre-built `CnpjUtils` instance (same object the class helpers use).
- **`CnpjUtils::VERSION`**: Gem version string.
- **Main-class shortcuts**: `CnpjUtils::CnpjFormatter`, `CnpjUtils::CnpjGenerator`, `CnpjUtils::CnpjValidator` (same objects as the sibling classes).
- **Nested package modules**: `CnpjUtils::CnpjFmt`, `CnpjUtils::CnpjGen`, `CnpjUtils::CnpjVal` — full sibling surface (Options, helpers, errors, types). Options/helpers/errors are **not** aliased at the `CnpjUtils` root.
- **Root sibling modules** (still supported): `CnpjFmt`, `CnpjGen`, `CnpjVal` — same objects as the nests.

### Errors & Exceptions

`CnpjUtils` defines only API-misuse errors for this gem’s argument rules. Component errors are raised by the bundled packages and propagate unchanged.

#### Defined by `cnpj-utilities`

| Error | Parent | Category | When |
|-------|--------|----------|------|
| `CnpjUtils::Error` | marker module | N/A | Included by every custom error this gem raises |
| `CnpjUtils::TypeMismatchError` | `TypeError` | API misuse | `settings` argument to `CnpjUtils.new` is not a `Hash` |
| `CnpjUtils::InvalidArgumentCombinationError` | `ArgumentError` | API misuse | Settings/options `Hash` (or options instance) passed together with any non-`nil` keyword argument |

```ruby
require 'cnpj-utilities'

begin
  CnpjUtils.new({ formatter: { hidden: true } }, generator: { format: true })
rescue CnpjUtils::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either a settings Hash to `settings`, or keyword arguments
  # (formatter:, generator:, validator:), not both.
end

begin
  CnpjUtils.format('03603568000195', { hidden: true }, slash_key: '|')
rescue CnpjUtils::InvalidArgumentCombinationError
  # options Hash/instance and keyword overrides are mutually exclusive
end
```

Rescue everything this gem raises with:

```ruby
rescue CnpjUtils::Error
  # TypeMismatchError, InvalidArgumentCombinationError, and any future custom errors
```

#### Propagated from bundled packages

- **Formatting** (`CnpjFmt`): `CnpjFmt::TypeMismatchError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError`, `CnpjFmt::InvalidLengthError` (passed to `on_fail`, not raised by `#format`), and related classes.
- **Generation** (`CnpjGen`): `CnpjGen::TypeMismatchError`, `CnpjGen::ValidationError`, and related classes.
- **Validation** (`CnpjVal`): `CnpjVal::TypeMismatchError`, `CnpjVal::ValidationError`, and related classes.

Invalid option types are typically **`TypeError`** subclasses (`*::TypeMismatchError`); invalid option values are domain errors under each package’s `DomainError` hierarchy. Validation failure returns `false`; formatting length failure is handled by **`on_fail`** (default returns an empty string).

```ruby
require 'cnpj-utilities'

begin
  CnpjUtils.new.format(12_345)
rescue CnpjFmt::TypeMismatchError => e
  puts e.message
end

begin
  CnpjUtils.new.is_valid(12_345_678_000_198)
rescue CnpjVal::TypeMismatchError => e
  puts e.message
end

# Custom on_fail for invalid length
custom_fail = ->(value, _exception) { "Invalid CNPJ: #{value}" }

CnpjFmt.cnpj_fmt('123', on_fail: custom_fail)  # => "Invalid CNPJ: 123"
CnpjFmt.cnpj_fmt('123')                        # => "" (default on_fail)
```

### Bundled packages

| Package | Main resources | README |
|---------|----------------|--------|
| [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt) | `CnpjFmt::CnpjFormatter`, `CnpjFmt::CnpjFormatterOptions`, `CnpjFmt.cnpj_fmt` | [docs](../cnpj-fmt/README.md) |
| [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen) | `CnpjGen::CnpjGenerator`, `CnpjGen::CnpjGeneratorOptions`, `CnpjGen.cnpj_gen` | [docs](../cnpj-gen/README.md) |
| [`cnpj-val`](https://rubygems.org/gems/cnpj-val) | `CnpjVal::CnpjValidator`, `CnpjVal::CnpjValidatorOptions`, `CnpjVal.cnpj_val` | [docs](../cnpj-val/README.md) |

All of the above are pulled in as dependencies of **`cnpj-utilities`**. For exhaustive option tables, exception lists, and edge-case behavior, see each package README.

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
