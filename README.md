![cpf-fmt for Ruby](https://br-utils.vercel.app/img/cover_cpf-fmt.jpg)

[![Gem Version](https://img.shields.io/gem/v/cpf-fmt)](https://rubygems.org/gems/cpf-fmt)
[![Gem Downloads](https://img.shields.io/gem/dt/cpf-fmt)](https://rubygems.org/gems/cpf-fmt)
[![Ruby Version](https://img.shields.io/gem/rv/cpf-fmt)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to format CPF (Brazilian Individual's Taxpayer ID).

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

## Features

- ✅ **Flexible input**: Accepts `String` or `Array` of strings; array elements are concatenated in order
- ✅ **Format agnostic**: Strips non-digit characters before formatting (letters and punctuation are discarded)
- ✅ **Custom delimiters**: `dot_key` and `dash_key` may be empty, single-, or multi-character strings
- ✅ **Masking**: Optional hiding of a digit range with a configurable replacement string (`hidden`, `hidden_key`, `hidden_start`, `hidden_end`)
- ✅ **HTML & URL output**: Optional `escape` (HTML entities) and `encode` (URI component encoding, similar to JavaScript `encodeURIComponent`)
- ✅ **Length errors without throwing**: Invalid length after sanitization is handled via `on_fail` (default returns an empty string)
- ✅ **Minimal dependencies**: Only [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: API misuse vs domain errors with a `CpfFmt::Error` marker for library-wide rescue

## Installation

Install the gem directly:

```bash
gem install cpf-fmt
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cpf-fmt'
```

## Require

```ruby
require 'cpf-fmt'
```

## Quick Start

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new

formatter.format('03603568195')      # => "036.035.681-95"
formatter.format('123.456.789-10')   # => "123.456.789-10"
formatter.format('12345678910')      # => "123.456.789-10"
```

Basic helper usage:

```ruby
require 'cpf-fmt'

cpf = '03603568195'

CpfFmt.cpf_fmt(cpf)                    # => "036.035.681-95"
CpfFmt.cpf_fmt(cpf, hidden: true)      # => "036.***.***-**"
CpfFmt.cpf_fmt(                        # => "036035681_95"
  cpf,
  dot_key: '',
  dash_key: '_'
)
```

## Usage

The main entry points are the class `CpfFmt::CpfFormatter`, the options class `CpfFmt::CpfFormatterOptions`, and the helper `CpfFmt.cpf_fmt`.

### `CpfFmt::CpfFormatter`

- **`initialize(options = nil, **keywords)`**: Optional default formatting options. When `options` is given (a `CpfFmt::CpfFormatterOptions` instance or a `Hash`) alone, it determines the default options; a `CpfFmt::CpfFormatterOptions` instance is stored by reference (mutating it later affects future `format` calls that do not pass per-call options), while a `Hash` builds a new instance. When `options` is omitted (`nil`), the default options are built exclusively from the keyword arguments (`hidden:`, `hidden_key:`, `dot_key:`, …). Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError` instead of silently ignoring the keywords. Example: `CpfFmt::CpfFormatter.new(hidden: true, dash_key: '_')`.
- **`options`**: Returns the instance’s `CpfFmt::CpfFormatterOptions` (same object used internally).
- **`format(cpf_input, options = nil, **keywords)`**: Formats a CPF value.

  Input is normalized by removing non-digit characters. If the sanitized length is not exactly **11**, the **`on_fail`** callback is invoked with the original input and a `CpfFmt::DomainError` (`InvalidLengthError`); its return value is the result (nothing is thrown for length).

  If the input is not a `String` or an `Array` of strings, **`CpfFmt::TypeMismatchError`** is raised.

  Per-call `options` and keyword arguments are never merged: a given `options` argument alone fully overrides the instance defaults for this call; otherwise, any given keyword overrides the instance defaults for this call. When neither is given, the instance defaults are used as-is. The instance defaults are never mutated by a per-call override. Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError`.

### `CpfFmt::CpfFormatterOptions`

Holds all formatter settings, with validation and merge support. Exposes properties: `hidden`, `hidden_key`, `hidden_start`, `hidden_end`, `dot_key`, `dash_key`, `escape`, `encode`, `on_fail`.

- **`initialize(options = nil, *extra_overrides, **keywords)`**: Optional default options (plain `Hash`, `CpfFmt::CpfFormatterOptions` instance, or keyword arguments), plus extra override objects merged in order (later overrides win).
- **`all`**: Returns a shallow `Hash` copy of all current options.
- **`copy`**: Returns a shallow copy of this options instance.
- **`set(options)`**: Updates multiple fields at once; returns `self`. Accepts a `Hash` or another `CpfFmt::CpfFormatterOptions` instance. Explicit `nil` values in the update keep the current value.
- **`set_hidden_range(hidden_start, hidden_end)`**: Validates indices in **`[0, 10]`** (inclusive); if `hidden_start > hidden_end`, values are swapped. `nil` arguments fall back to defaults (`DEFAULT_HIDDEN_START` / `DEFAULT_HIDDEN_END`).

**`hidden_start` / `hidden_end`**: Indices refer to the **11-digit normalized CPF string** (before inserting punctuation). The inclusive range is replaced internally by placeholders, then `hidden_key` is substituted (supports multi-character keys and empty string).

**Key options** (`hidden_key`, `dot_key`, `dash_key`): Must be strings and must not contain any character in `CpfFmt::CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS` (reserved for internal formatting).

### Functional helper

`CpfFmt.cpf_fmt` builds a new `CpfFmt::CpfFormatter` from the same constructor parameters and calls `format(cpf_input)` once. Pass either keyword arguments **or** a `Hash`/`CpfFmt::CpfFormatterOptions` instance for options — not both (passing `options` with any non-`nil` keyword raises `InvalidArgumentCombinationError`):

```ruby
require 'cpf-fmt'

cpf = '03603568195'

CpfFmt.cpf_fmt(cpf)                # => "036.035.681-95"
CpfFmt.cpf_fmt(cpf, hidden: true)  # masked with defaults
CpfFmt.cpf_fmt(                    # => "036035681_95"
  cpf,
  dot_key: '',
  dash_key: '_'
)
CpfFmt.cpf_fmt(cpf, {              # Hash form
  hidden: true,
  hidden_key: '#'
})
```

### Object-oriented examples

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new
cpf = '12345678910'

formatter.format(cpf)   # => "123.456.789-10"
formatter.format(        # => "123.###.###-##"
  cpf,
  hidden: true,
  hidden_key: '#',
  hidden_start: 3,
  hidden_end: 10
)
```

Default options on the instance; per-call overrides:

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new(hidden: true)
cpf = '12345678910'

formatter.format(cpf)                 # uses instance masking
formatter.format(cpf, hidden: false)  # this call only: unmasked
formatter.format(cpf)                 # back to instance defaults
```

Array input:

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new

formatter.format([                   # => "123.456.789-10"
  '123',
  '456',
  '789',
  '10'
])
```

### Input formats

**String:** Raw digits, or already formatted CPF (e.g. `123.456.789-10`, `123 456 789 10`). Non-digit characters are removed; leading zeros are preserved.

**Array of strings:** Each element must be a `String`; values are concatenated (e.g. per digit, grouped segments, or mixed with punctuation — all non-digits are stripped during normalization). Non-string elements are not allowed.

### Formatting options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `hidden` | `Boolean`, `nil` | `false` | When truthy, replaces the inclusive index range `[hidden_start, hidden_end]` on the normalized 11-digit string before punctuation is applied |
| `hidden_key` | `String`, `nil` | `'*'` | Replacement for each hidden position (may be multi-character or empty); must not use disallowed key characters |
| `hidden_start` | `Integer`, `nil` | `3` | Start index `0`–`10` (inclusive) |
| `hidden_end` | `Integer`, `nil` | `10` | End index `0`–`10` (inclusive); if `hidden_start > hidden_end`, they are swapped |
| `dot_key` | `String`, `nil` | `'.'` | Separator after the 3rd and 6th digits |
| `dash_key` | `String`, `nil` | `'-'` | Separator after the 9th digit |
| `escape` | `Boolean`, `nil` | `false` | When truthy, HTML-escapes the final string |
| `encode` | `Boolean`, `nil` | `false` | When truthy, URL-encodes the final string (similar to `encodeURIComponent`) |
| `on_fail` | `Proc`, `nil` | see below | `(value, error) -> String` — used when sanitized length ≠ 11 |

Default **`on_fail`** returns an empty string. Signature: `(original_input, error) -> String`, where `error` is a **`CpfFmt::DomainError`** (currently an `InvalidLengthError` with `actual_input`, `evaluated_input`, `expected_length`). The callback return value must be a `String`; otherwise **`CpfFmt::TypeMismatchError`** is raised.

Example with all options:

```ruby
require 'cpf-fmt'

cpf = '12345678910'

CpfFmt.cpf_fmt(
  cpf,
  hidden: true,
  hidden_key: '#',
  hidden_start: 3,
  hidden_end: 9,
  dot_key: ' ',
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

Every custom error includes the `CpfFmt::Error` marker module. Domain failures (`InvalidLengthError`, `OutOfRangeError`, `ValidationError`) inherit from `CpfFmt::DomainError` (`RangeError`).

**Important:** length failures are **constructed as `InvalidLengthError` and passed to `on_fail` as a `DomainError`**, not raised from `format` / `cpf_fmt`. Passing both an `options` instance/`Hash` and any non-`nil` keyword argument raises `InvalidArgumentCombinationError`.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CpfFmt::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Both an `options` instance/`Hash` and any non-`nil` keyword argument are passed at once |
| `CpfFmt::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | CPF input or option has the wrong data type |
| `CpfFmt::InvalidLengthError` | `CpfFmt::DomainError` | Domain error | Sanitized length is not exactly 11 (passed to `on_fail` as `DomainError`) |
| `CpfFmt::OutOfRangeError` | `CpfFmt::DomainError` | Domain error | `hidden_start` / `hidden_end` outside `0`–`10` |
| `CpfFmt::ValidationError` | `CpfFmt::DomainError` | Domain error | Key option contains a disallowed character |

#### `CpfFmt::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises or constructs for `on_fail`.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CpfFmt::Error
  # everything this library raises
```

#### `CpfFmt::DomainError`

- **Inheritance:** `CpfFmt::DomainError < RangeError` (includes `CpfFmt::Error`)
- **Category:** Domain error — ancestor for numeric/length domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CpfFmt::OutOfRangeError` / construct `InvalidLengthError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CpfFmt::DomainError
  # OutOfRangeError, InvalidLengthError, ValidationError, and other DomainError subclasses
```

#### `CpfFmt::TypeMismatchError`

- **Inheritance:** `CpfFmt::TypeMismatchError < TypeError` (includes `CpfFmt::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when the CPF input is not a `String` or an `Array` of strings, when an option has the wrong type, or when `on_fail` does not return a `String`.
- **Example:**

```ruby
CpfFmt::CpfFormatter.new.format(12_345) # raises CpfFmt::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CpfFmt::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CpfFmt::InvalidLengthError`

- **Inheritance:** `CpfFmt::InvalidLengthError < CpfFmt::DomainError < RangeError` (includes `CpfFmt::Error`)
- **Category:** Domain error — a collection or string length violates a business rule.
- **When it is raised:** Not raised from `format`; constructed and passed as the `DomainError` second argument to `on_fail` when the sanitized CPF does not contain exactly 11 digits.
- **Example:**

```ruby
CpfFmt::CpfFormatter.new.format(
  'short',
  on_fail: ->(_value, error) {
    error # => #<CpfFmt::InvalidLengthError ...> (a DomainError)
    'invalid'
  }
) # => "invalid"

```

- **How to rescue it:** Handle inside `on_fail` (typical), or rescue if you re-raise:

```ruby
rescue CpfFmt::InvalidLengthError
  # this exact length violation

rescue CpfFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### `CpfFmt::InvalidArgumentCombinationError`

- **Inheritance:** `CpfFmt::InvalidArgumentCombinationError < ArgumentError` (includes `CpfFmt::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `CpfFormatter.new`, `#format`, or `cpf_fmt` receives both an `options` argument (instance or `Hash`) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
begin
  CpfFmt::CpfFormatter.new({ dash_key: '_' }, hidden: true)
rescue CpfFmt::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (hidden:, ...), not both.
end
```

- **How to rescue it:**

```ruby
rescue CpfFmt::InvalidArgumentCombinationError
  # this library's invalid argument combination

rescue ArgumentError
  # native argument errors, including this library's InvalidArgumentCombinationError
```

#### `CpfFmt::OutOfRangeError`

- **Inheritance:** `CpfFmt::OutOfRangeError < CpfFmt::DomainError < RangeError` (includes `CpfFmt::Error`)
- **Category:** Domain error — a numeric value violates a business range rule.
- **When it is raised:** Raised when `hidden_start` or `hidden_end` is outside the inclusive range `0`–`10`.
- **Example:**

```ruby
CpfFmt::CpfFormatterOptions.new(hidden_start: 11) # raises CpfFmt::OutOfRangeError
```

- **How to rescue it:**

```ruby
rescue CpfFmt::OutOfRangeError
  # this exact range violation

rescue CpfFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### `CpfFmt::ValidationError`

- **Inheritance:** `CpfFmt::ValidationError < CpfFmt::DomainError < RangeError` (includes `CpfFmt::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when a key option (`hidden_key`, `dot_key`, `dash_key`) contains a disallowed character.
- **Example:**

```ruby
CpfFmt::CpfFormatterOptions.new(dot_key: 'å') # raises CpfFmt::ValidationError
```

- **How to rescue it:**

```ruby
rescue CpfFmt::ValidationError
  # this exact domain validation failure

rescue CpfFmt::DomainError
  # RangeError-rooted domain failures from this library
```

#### Rescue granularity

```ruby
# 1) Single native class — catches type misuse from this library (and other TypeErrors).
rescue TypeError
  # CpfFmt::TypeMismatchError and any other TypeError (library or not)

# 2) CpfFmt::DomainError — catches business-rule violations under DomainError.
rescue CpfFmt::DomainError
  # CpfFmt::OutOfRangeError, CpfFmt::InvalidLengthError, CpfFmt::ValidationError,
  # and other DomainError subclasses

# 3) CpfFmt::Error — catches everything the library raises.
rescue CpfFmt::Error
  # every custom error that includes CpfFmt::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CpfFmt::OutOfRangeError
  # only CpfFmt::OutOfRangeError
```

Notable attributes:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`, `option_name` (nil for CPF input)
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `expected_length`
- `OutOfRangeError`: `option_name`, `actual_input`, `min_expected_value`, `max_expected_value`
- `ValidationError`: `option_name`, `actual_input`, `forbidden_characters`

## API

### Exports

After `require 'cpf-fmt'`:

- **`CpfFmt.cpf_fmt`**: `(cpf_input, options = nil, **keywords) -> String` — convenience helper.
- **`CpfFmt::CpfFormatter`**: Class to format CPF with optional default options; accepts `String` or `Array<String>` in `format`.
- **`CpfFmt::CpfFormatterOptions`**: Class holding options; supports merge via constructor, `set`, and keyword arguments.
- **`CpfFmt::CPF_LENGTH`**: `11` (constant).
- **`CpfFmt::VERSION`**: gem version string.
- **Errors**: `CpfFmt::Error`, `CpfFmt::DomainError`, `CpfFmt::InvalidArgumentCombinationError`, `CpfFmt::TypeMismatchError`, `CpfFmt::InvalidLengthError`, `CpfFmt::OutOfRangeError`, `CpfFmt::ValidationError`.

### Other available resources

- **`CpfFmt::CpfFormatterOptions::CPF_LENGTH`**: `11`.
- **`CpfFmt::CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS`**: Characters forbidden in `hidden_key`, `dot_key`, `dash_key`.
- **`CpfFmt::CpfFormatterOptions::DEFAULT_*`**: Default values for each option.
- **`CpfFmt::CpfFormatterOptions.default_on_fail`**: Shared default failure callback.

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
