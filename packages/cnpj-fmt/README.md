![cnpj-fmt for Ruby](https://br-utils.vercel.app/img/cover_cnpj-fmt.jpg)

[![Gem Version](https://img.shields.io/gem/v/cnpj-fmt)](https://rubygems.org/gems/cnpj-fmt)
[![Gem Downloads](https://img.shields.io/gem/dt/cnpj-fmt)](https://rubygems.org/gems/cnpj-fmt)
[![Ruby Version](https://img.shields.io/gem/rv/cnpj-fmt)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to format CNPJ (Brazilian Business Tax ID).

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

## Features

- ✅ **Alphanumeric CNPJ**: Supports 14-character alphanumeric CNPJ (digits and letters, e.g. `RK0CMT3W000100`)
- ✅ **Flexible input**: Accepts `String` or `Array` of strings; array elements are concatenated in order
- ✅ **Format agnostic**: Strips non-alphanumeric characters and uppercases letters before formatting
- ✅ **Custom delimiters**: `dot_key`, `slash_key`, and `dash_key` may be empty, single-, or multi-character strings
- ✅ **Masking**: Optional hiding of a character range with a configurable replacement string (`hidden`, `hidden_key`, `hidden_start`, `hidden_end`)
- ✅ **HTML & URL output**: Optional `escape` (HTML entities) and `encode` (URI component encoding, similar to JavaScript `encodeURIComponent`)
- ✅ **Length errors without throwing**: Invalid length after sanitization is handled via `on_fail` (default returns an empty string)
- ✅ **Minimal dependencies**: Only [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: API misuse vs domain errors with a `CnpjFmt::Error` marker for library-wide rescue

## Installation

Install the gem directly:

```bash
gem install cnpj-fmt
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cnpj-fmt'
```

## Require

```ruby
require 'cnpj-fmt'
```

## Quick Start

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new

formatter.format('03603568000195')   # => "03.603.568/0001-95"
formatter.format('12ABC34500DE99')   # => "12.ABC.345/00DE-99"
formatter.format('RK0CMT3W000100')   # => "RK.0CM.T3W/0001-00"
```

Basic helper usage:

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(cnpj)                    # => "03.603.568/0001-95"
CnpjFmt.cnpj_fmt(cnpj, hidden: true)      # => "03.603.***/****-**"
CnpjFmt.cnpj_fmt(                         # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)
```

## Usage

The main entry points are the class `CnpjFmt::CnpjFormatter`, the options class `CnpjFmt::CnpjFormatterOptions`, and the helper `CnpjFmt.cnpj_fmt`.

### `CnpjFmt::CnpjFormatter`

- **`initialize(options = nil, **keywords)`**: Optional default formatting options. When `options` is given (a `CnpjFmt::CnpjFormatterOptions` instance or a `Hash`) alone, it determines the default options; a `CnpjFmt::CnpjFormatterOptions` instance is stored by reference (mutating it later affects future `format` calls that do not pass per-call options), while a `Hash` builds a new instance. When `options` is omitted (`nil`), the default options are built exclusively from the keyword arguments (`hidden:`, `hidden_key:`, `dot_key:`, …). Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError` instead of silently ignoring the keywords. Example: `CnpjFmt::CnpjFormatter.new(hidden: true, slash_key: '|')`.
- **`options`**: Returns the instance’s `CnpjFmt::CnpjFormatterOptions` (same object used internally).
- **`format(cnpj_input, options = nil, **keywords)`**: Formats a CNPJ value.

  Input is normalized by removing non-alphanumeric characters and uppercasing. If the sanitized length is not exactly **14**, the **`on_fail`** callback is invoked with the original input and a `CnpjFmt::DomainError` (`InvalidLengthError`); its return value is the result (nothing is thrown for length).

  If the input is not a `String` or an `Array` of strings, **`CnpjFmt::TypeMismatchError`** is raised.

  Per-call `options` and keyword arguments are never merged: a given `options` argument alone fully overrides the instance defaults for this call; otherwise, any given keyword overrides the instance defaults for this call. When neither is given, the instance defaults are used as-is. The instance defaults are never mutated by a per-call override. Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError`.

### `CnpjFmt::CnpjFormatterOptions`

Holds all formatter settings, with validation and merge support. Exposes properties: `hidden`, `hidden_key`, `hidden_start`, `hidden_end`, `dot_key`, `slash_key`, `dash_key`, `escape`, `encode`, `on_fail`.

- **`initialize(options = nil, *extra_overrides, **keywords)`**: Optional default options (plain `Hash`, `CnpjFmt::CnpjFormatterOptions` instance, or keyword arguments), plus extra override objects merged in order (later overrides win).
- **`all`**: Returns a shallow `Hash` copy of all current options.
- **`copy`**: Returns a shallow copy of this options instance.
- **`set(options)`**: Updates multiple fields at once; returns `self`. Accepts a `Hash` or another `CnpjFmt::CnpjFormatterOptions` instance. Explicit `nil` values in the update keep the current value.
- **`set_hidden_range(hidden_start, hidden_end)`**: Validates indices in **`[0, 13]`** (inclusive); if `hidden_start > hidden_end`, values are swapped. `nil` arguments fall back to defaults (`DEFAULT_HIDDEN_START` / `DEFAULT_HIDDEN_END`).

**`hidden_start` / `hidden_end`**: Indices refer to the **14-character normalized CNPJ string** (before inserting punctuation). The inclusive range is replaced internally by placeholders, then `hidden_key` is substituted (supports multi-character keys and empty string).

**Key options** (`hidden_key`, `dot_key`, `slash_key`, `dash_key`): Must be strings and must not contain any character in `CnpjFmt::CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS` (reserved for internal formatting).

### Functional helper

`CnpjFmt.cnpj_fmt` builds a new `CnpjFmt::CnpjFormatter` from the same constructor parameters and calls `format(cnpj_input)` once. Pass either keyword arguments **or** a `Hash`/`CnpjFmt::CnpjFormatterOptions` instance for options — not both (passing both raises `InvalidArgumentCombinationError`):

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(cnpj)                # => "03.603.568/0001-95"
CnpjFmt.cnpj_fmt(cnpj, hidden: true)  # masked with defaults
CnpjFmt.cnpj_fmt(                     # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)
CnpjFmt.cnpj_fmt(cnpj, {              # Hash form
  hidden: true,
  hidden_key: '#'
})
```

### Object-oriented examples

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new
cnpj = '03603568000195'

formatter.format(cnpj)   # => "03.603.568/0001-95"
formatter.format(        # => "03.603.###/####-##"
  cnpj,
  hidden: true,
  hidden_key: '#',
  hidden_start: 5,
  hidden_end: 13
)
```

Default options on the instance; per-call overrides:

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new(hidden: true)
cnpj = '03603568000195'

formatter.format(cnpj)                 # uses instance masking
formatter.format(cnpj, hidden: false)  # this call only: unmasked
formatter.format(cnpj)                 # back to instance defaults
```

Alphanumeric input and array input:

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new

formatter.format('RK0CMT3W000100')   # => "RK.0CM.T3W/0001-00"
formatter.format([                   # => "RK.0CM.T3W/0001-00"
  'RK',
  '0CM',
  'T3W',
  '0001',
  '00'
])
```

### Input formats

**String:** Raw digits and/or letters, or already formatted CNPJ (e.g. `12.345.678/0009-10`, `12.ABC.345/00DE-99`). Non-alphanumeric characters are removed; lowercase letters are uppercased.

**Array of strings:** Each element must be a `String`; values are concatenated (e.g. per digit, grouped segments, or mixed with punctuation — all are stripped during normalization). Non-string elements are not allowed.

### Formatting options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `hidden` | `Boolean`, `nil` | `false` | When truthy, replaces the inclusive index range `[hidden_start, hidden_end]` on the normalized 14-character string before punctuation is applied |
| `hidden_key` | `String`, `nil` | `'*'` | Replacement for each hidden position (may be multi-character or empty); must not use disallowed key characters |
| `hidden_start` | `Integer`, `nil` | `5` | Start index `0`–`13` (inclusive) |
| `hidden_end` | `Integer`, `nil` | `13` | End index `0`–`13` (inclusive); if `hidden_start > hidden_end`, they are swapped |
| `dot_key` | `String`, `nil` | `'.'` | Separator between groups `XX` / `XXX` / `XXX` |
| `slash_key` | `String`, `nil` | `'/'` | Separator before the branch block |
| `dash_key` | `String`, `nil` | `'-'` | Separator before the last two characters |
| `escape` | `Boolean`, `nil` | `false` | When truthy, HTML-escapes the final string |
| `encode` | `Boolean`, `nil` | `false` | When truthy, URL-encodes the final string (similar to `encodeURIComponent`) |
| `on_fail` | `Proc`, `nil` | see below | `(value, error) -> String` — used when sanitized length ≠ 14 |

Default **`on_fail`** returns an empty string. Signature: `(original_input, error) -> String`, where `error` is a **`CnpjFmt::DomainError`** (currently an `InvalidLengthError` with `actual_input`, `evaluated_input`, `expected_length`). The callback return value must be a `String`; otherwise **`CnpjFmt::TypeMismatchError`** is raised.

Example with all options:

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(
  cnpj,
  hidden: true,
  hidden_key: '#',
  hidden_start: 5,
  hidden_end: 11,
  dot_key: ' ',
  slash_key: '|',
  dash_key: '_-_',
  escape: true,
  encode: true,
  on_fail: ->(value, _error) { value.to_s }
)
```

### Error handling

Errors fall into two categories:

| Category | Meaning |
|---|---|
| **API misuse** | The caller invoked the library incorrectly (wrong type for input or options, or an invalid argument combination). |
| **Domain error** | The call was structurally correct, but a value violates a business rule (length, range, forbidden characters). |

Every custom error includes the `CnpjFmt::Error` marker module. Domain failures (`InvalidLengthError`, `OutOfRangeError`, `ValidationError`) inherit from `CnpjFmt::DomainError` (`RangeError`).

**Important:** length failures are **constructed as `InvalidLengthError` and passed to `on_fail` as a `DomainError`**, not raised from `format` / `cnpj_fmt`. Passing both an `options` instance/`Hash` and keyword arguments raises `InvalidArgumentCombinationError`.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CnpjFmt::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Both an `options` instance/`Hash` and keyword arguments are passed at once |
| `CnpjFmt::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | CNPJ input or option has the wrong data type |
| `CnpjFmt::InvalidLengthError` | `CnpjFmt::DomainError` | Domain error | Sanitized length is not exactly 14 (passed to `on_fail` as `DomainError`) |
| `CnpjFmt::OutOfRangeError` | `CnpjFmt::DomainError` | Domain error | `hidden_start` / `hidden_end` outside `0`–`13` |
| `CnpjFmt::ValidationError` | `CnpjFmt::DomainError` | Domain error | Key option contains a disallowed character |

#### `CnpjFmt::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises or constructs for `on_fail`.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CnpjFmt::Error
  # everything this library raises
```

#### `CnpjFmt::DomainError`

- **Inheritance:** `CnpjFmt::DomainError < RangeError` (includes `CnpjFmt::Error`)
- **Category:** Domain error — ancestor for numeric/length domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CnpjFmt::OutOfRangeError` / construct `InvalidLengthError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CnpjFmt::DomainError
  # OutOfRangeError, InvalidLengthError, ValidationError, and other DomainError subclasses
```

#### `CnpjFmt::TypeMismatchError`

- **Inheritance:** `CnpjFmt::TypeMismatchError < TypeError` (includes `CnpjFmt::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when the CNPJ input is not a `String` or an `Array` of strings, when an option has the wrong type, or when `on_fail` does not return a `String`.
- **Example:**

```ruby
CnpjFmt::CnpjFormatter.new.format(12_345) # raises CnpjFmt::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CnpjFmt::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CnpjFmt::InvalidLengthError`

- **Inheritance:** `CnpjFmt::InvalidLengthError < CnpjFmt::DomainError < RangeError` (includes `CnpjFmt::Error`)
- **Category:** Domain error — a collection or string length violates a business rule.
- **When it is raised:** Not raised from `format`; constructed and passed as the `DomainError` second argument to `on_fail` when the sanitized CNPJ does not contain exactly 14 alphanumeric characters.
- **Example:**

```ruby
CnpjFmt::CnpjFormatter.new.format(
  'short',
  on_fail: ->(_value, error) {
    error # => #<CnpjFmt::InvalidLengthError ...> (a DomainError)
    'invalid'
  }
) # => "invalid"

```

- **How to rescue it:** Handle inside `on_fail` (typical), or rescue if you re-raise:

```ruby
rescue CnpjFmt::InvalidLengthError
  # this exact length violation

rescue CnpjFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### `CnpjFmt::InvalidArgumentCombinationError`

- **Inheritance:** `CnpjFmt::InvalidArgumentCombinationError < ArgumentError` (includes `CnpjFmt::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `CnpjFormatter.new`, `#format`, or `cnpj_fmt` receives both an `options` argument (instance or `Hash`) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
begin
  CnpjFmt::CnpjFormatter.new({ slash_key: '|' }, hidden: true)
rescue CnpjFmt::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (hidden:, ...), not both.
end
```

- **How to rescue it:**

```ruby
rescue CnpjFmt::InvalidArgumentCombinationError
  # this library's invalid argument combination

rescue ArgumentError
  # native argument errors, including this library's InvalidArgumentCombinationError
```

#### `CnpjFmt::OutOfRangeError`

- **Inheritance:** `CnpjFmt::OutOfRangeError < CnpjFmt::DomainError < RangeError` (includes `CnpjFmt::Error`)
- **Category:** Domain error — a numeric value violates a business range rule.
- **When it is raised:** Raised when `hidden_start` or `hidden_end` is outside the inclusive range `0`–`13`.
- **Example:**

```ruby
CnpjFmt::CnpjFormatterOptions.new(hidden_start: 14) # raises CnpjFmt::OutOfRangeError
```

- **How to rescue it:**

```ruby
rescue CnpjFmt::OutOfRangeError
  # this exact range violation

rescue CnpjFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### `CnpjFmt::ValidationError`

- **Inheritance:** `CnpjFmt::ValidationError < CnpjFmt::DomainError < RangeError` (includes `CnpjFmt::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when a key option (`hidden_key`, `dot_key`, `slash_key`, `dash_key`) contains a disallowed character.
- **Example:**

```ruby
CnpjFmt::CnpjFormatterOptions.new(dot_key: 'å') # raises CnpjFmt::ValidationError
```

- **How to rescue it:**

```ruby
rescue CnpjFmt::ValidationError
  # this exact domain validation failure

rescue CnpjFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### Rescue granularity

```ruby
# 1) Single native class — catches type misuse from this library (and other TypeErrors).
rescue TypeError
  # CnpjFmt::TypeMismatchError and any other TypeError (library or not)

# 2) CnpjFmt::DomainError — catches business-rule violations under DomainError.
rescue CnpjFmt::DomainError
  # CnpjFmt::OutOfRangeError, CnpjFmt::InvalidLengthError, CnpjFmt::ValidationError,
  # and other DomainError subclasses

# 3) CnpjFmt::Error — catches everything the library raises.
rescue CnpjFmt::Error
  # every custom error that includes CnpjFmt::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CnpjFmt::OutOfRangeError
  # only CnpjFmt::OutOfRangeError
```

Notable attributes:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`, `option_name` (nil for CNPJ input)
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `expected_length`
- `OutOfRangeError`: `option_name`, `actual_input`, `min_expected_value`, `max_expected_value`
- `ValidationError`: `option_name`, `actual_input`, `forbidden_characters`

## API

### Exports

After `require 'cnpj-fmt'`:

- **`CnpjFmt.cnpj_fmt`**: `(cnpj_input, options = nil, **keywords) -> String` — convenience helper.
- **`CnpjFmt::CnpjFormatter`**: Class to format CNPJ with optional default options; accepts `String` or `Array<String>` in `format`.
- **`CnpjFmt::CnpjFormatterOptions`**: Class holding options; supports merge via constructor, `set`, and keyword arguments.
- **`CnpjFmt::CNPJ_LENGTH`**: `14` (constant).
- **`CnpjFmt::VERSION`**: gem version string.
- **Type predicate**: `CnpjFmt::CnpjInput` — `CnpjFmt::CnpjInput.accept?(value)` / `CnpjFmt::CnpjInput === value` is true only for `String` or `Array<String>`.
- **Errors**: `CnpjFmt::Error`, `CnpjFmt::DomainError`, `CnpjFmt::InvalidArgumentCombinationError`, `CnpjFmt::TypeMismatchError`, `CnpjFmt::InvalidLengthError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError`.

### Other available resources

- **`CnpjFmt::CnpjFormatterOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjFmt::CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS`**: Characters forbidden in `hidden_key`, `dot_key`, `slash_key`, `dash_key`.
- **`CnpjFmt::CnpjFormatterOptions::DEFAULT_*`**: Default values for each option.
- **`CnpjFmt::CnpjFormatterOptions.default_on_fail`**: Shared default failure callback.

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
