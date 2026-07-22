![cpf-val for Ruby](https://br-utils.vercel.app/img/cover_cpf-val.jpg)

[![Gem Version](https://img.shields.io/gem/v/cpf-val)](https://rubygems.org/gems/cpf-val)
[![Gem Downloads](https://img.shields.io/gem/dt/cpf-val)](https://rubygems.org/gems/cpf-val)
[![Ruby Version](https://img.shields.io/gem/rv/cpf-val)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to validate CPF (Brazilian Individual's Taxpayer ID) values.

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

## Features

- ✅ **Fixed 11-digit CPF**: Validates the standard 11-digit Brazilian CPF via the official modulo-11 algorithm
- ✅ **Flexible input**: Accepts `String` or `Array` of strings; array elements are concatenated in order
- ✅ **Format agnostic**: Strips every non-digit character before validation
- ✅ **Repeated-digit rejection**: All-identical-digit bases (e.g. `111.111.111-11`, `00000000000`) are rejected
- ✅ **Error handling**: Typed API-misuse errors with a `CpfVal::Error` marker for library-wide rescue
- ✅ **Minimal dependencies**: [`cpf-dv`](https://rubygems.org/gems/cpf-dv) for check-digit calculation and [`lacus-utils`](https://rubygems.org/gems/lacus-utils) for type descriptions in error messages
- ✅ **Dual API style**: Object-oriented (`CpfVal::CpfValidator`) and functional (`CpfVal.cpf_val`)

## Installation

Install the gem directly:

```bash
gem install cpf-val
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cpf-val'
```

## Require

```ruby
require 'cpf-val'
```

## Quick Start

```ruby
require 'cpf-val'

validator = CpfVal::CpfValidator.new

validator.is_valid('12345678909')       # => true
validator.is_valid('123.456.789-09')    # => true
validator.is_valid('12345678910')       # => false (invalid check digits)
validator.is_valid('00000000000')       # => false (repeated digits)
```

Functional helper:

```ruby
require 'cpf-val'

CpfVal.cpf_val('12345678909')      # => true
CpfVal.cpf_val('123.456.789-09')   # => true
CpfVal.cpf_val('12345678910')      # => false
```

## Usage

The main entry points are the class `CpfVal::CpfValidator` and the helper `CpfVal.cpf_val`.

### `CpfVal::CpfValidator`

- **`initialize`**: Takes no arguments. CPF validation has no configuration options.
- **`is_valid(cpf_input)`**: Validates a CPF value.

  Input is normalized to a string (arrays of strings are concatenated). Every non-digit character is then stripped. If the sanitized length is not exactly **11**, its base is an all-identical-digit sequence, or the check digits do not match (`CpfDV::CpfCheckDigits` from **`cpf-dv`**), the method returns `false` — no exception is raised for validation failure.

  If the input is not a `String` or an `Array` of strings, **`CpfVal::TypeMismatchError`** is raised.

```ruby
require 'cpf-val'

validator = CpfVal::CpfValidator.new

validator.is_valid('123.456.789-09')             # => true
validator.is_valid('12345678909')                # => true
validator.is_valid(['123', '456', '789', '09'])  # => true
validator.is_valid('12345678910')                # => false (invalid check digits)
validator.is_valid('11111111111')                # => false (repeated digits)
```

### Functional helper

`CpfVal.cpf_val` builds a new `CpfVal::CpfValidator` and calls `is_valid(cpf_input)` once. It takes only the input value:

```ruby
require 'cpf-val'

CpfVal.cpf_val('11144477735')      # => true
CpfVal.cpf_val('111.444.777-35')   # => true
CpfVal.cpf_val('11144477736')      # => false
```

### Input formats

**String:** Plain digits or a formatted CPF (e.g. `123.456.789-09`, `499.784.420-90`, `011_258_960_00`). Non-digit characters are stripped before validation; the result must be exactly 11 digits.

**Array of strings:** Each element must be a `String`; values are concatenated (e.g. per digit, grouped segments, or mixed with punctuation). Non-string elements raise **`CpfVal::TypeMismatchError`**.

```ruby
require 'cpf-val'

CpfVal.cpf_val(['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '9'])  # => true
CpfVal.cpf_val(['123.456', '789-09'])  # => true
```

### Error handling

This package raises only for **API misuse** (wrong input type). Validation failures (wrong length, ineligible base such as repeated digits, invalid check digits) return `false` and do not raise.

Every custom error includes the `CpfVal::Error` marker module. This package defines **no** `CpfVal::DomainError` and no domain leaves — invalid CPF data never raises a domain error.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CpfVal::TypeMismatchError` | `CpfVal::TypeMismatchError < TypeError < StandardError` (+ `include CpfVal::Error`) | API misuse | CPF input is not a `String` or `Array` of strings |

#### `CpfVal::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CpfVal::Error
  # everything this library raises
```

#### `CpfVal::TypeMismatchError`

- **Inheritance:** `CpfVal::TypeMismatchError < TypeError < StandardError` (includes `CpfVal::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when the CPF input is not a `String` or an `Array` of strings (including when an array contains a non-string element).
- **Example:**

```ruby
require 'cpf-val'

begin
  CpfVal.cpf_val(12_345_678_909)
rescue CpfVal::TypeMismatchError => e
  puts e.message
  # CPF input must be of type string or string[]. Got integer number.
end
```

- **How to rescue it:**

```ruby
rescue CpfVal::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### Rescue granularity

```ruby
# 1) Single native class — catches misuse errors of that kind,
#    including non-library ones already handled elsewhere in the consumer's code.
rescue TypeError
  # CpfVal::TypeMismatchError and any other TypeError (library or not)

# 2) CpfVal::DomainError — not applicable: this package defines no DomainError
#    (and no domain leaves). Invalid CPF data returns false instead of raising.
# rescue CpfVal::DomainError  # NameError — constant is not defined

# 3) CpfVal::Error — catches everything the library raises, regardless of native ancestry.
rescue CpfVal::Error
  # every custom error that includes CpfVal::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CpfVal::TypeMismatchError
  # only CpfVal::TypeMismatchError
```

Notable attributes on raised errors:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`

## API

### Exports

After `require 'cpf-val'`:

- **`CpfVal.cpf_val`**: `(cpf_input) -> Boolean` — convenience helper.
- **`CpfVal::CpfValidator`**: Class to validate CPF (no options); accepts `String` or `Array<String>` in `is_valid`.
- **`CpfVal::CPF_LENGTH`**: `11` (constant).
- **`CpfVal::VERSION`**: gem version string.
- **Type predicate**: `CpfVal::CpfInput` — `CpfVal::CpfInput.accept?(value)` / `CpfVal::CpfInput === value` is true only for `String` or `Array<String>`.
- **Errors**: `CpfVal::Error`, `CpfVal::TypeMismatchError`.

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
