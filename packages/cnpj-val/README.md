![cnpj-val for Ruby](https://br-utils.vercel.app/img/cover_cnpj-val.jpg)

[![Gem Version](https://img.shields.io/gem/v/cnpj-val)](https://rubygems.org/gems/cnpj-val)
[![Gem Downloads](https://img.shields.io/gem/dt/cnpj-val)](https://rubygems.org/gems/cnpj-val)
[![Ruby Version](https://img.shields.io/gem/rv/cnpj-val)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to validate CNPJ (Brazilian Business Tax ID) values.

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

## Features

- ✅ **Alphanumeric CNPJ**: Validates 14-character CNPJ in numeric or alphanumeric format
- ✅ **Flexible input**: Accepts `String` or `Array` of strings; array elements are concatenated in order
- ✅ **Format agnostic**: Strips non-alphanumeric characters (or non-digits when `type` is `numeric`) and optionally uppercases before validation
- ✅ **Optional case sensitivity**: When `case_sensitive` is `false`, lowercase letters are accepted for alphanumeric CNPJ
- ✅ **Per-call override model**: Instance defaults can be overridden for one `is_valid` call only
- ✅ **Error handling**: API misuse vs domain errors with a `CnpjVal::Error` marker for library-wide rescue
- ✅ **Minimal dependencies**: [`cnpj-dv`](https://rubygems.org/gems/cnpj-dv) for check-digit calculation and [`lacus-utils`](https://rubygems.org/gems/lacus-utils) for type descriptions in error messages
- ✅ **Dual API style**: Object-oriented (`CnpjVal::CnpjValidator`) and functional (`CnpjVal.cnpj_val`)

## Installation

Install the gem directly:

```bash
gem install cnpj-val
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cnpj-val'
```

## Require

```ruby
require 'cnpj-val'
```

## Quick Start

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new

validator.is_valid('98765432000198')       # => true
validator.is_valid('98.765.432/0001-98')   # => true
validator.is_valid('98765432000199')       # => false

validator.is_valid('1QB5UKALPYFP59')                         # => true (alphanumeric)
validator.is_valid('1QB5UKALpyfp59')                         # => false (default is case-sensitive)
validator.is_valid('1QB5UKALpyfp59', case_sensitive: false)  # => true

validator.is_valid('96206256120884')              # => true (numeric)
validator.is_valid('1QB5UKALPYFP59', type: 'numeric')   # => false (letters stripped → length ≠ 14)
```

Functional helper:

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val('98765432000198')      # => true
CnpjVal.cnpj_val('98.765.432/0001-98')  # => true
CnpjVal.cnpj_val('98765432000199')      # => false
```

## Usage

The main entry points are the class `CnpjVal::CnpjValidator`, the options class `CnpjVal::CnpjValidatorOptions`, and the helper `CnpjVal.cnpj_val`.

### `CnpjVal::CnpjValidator`

- **`initialize(options = nil, **keywords)`**: Optional default validation options. When `options` is given (a `CnpjVal::CnpjValidatorOptions` instance or a `Hash`) alone, it determines the default options; a `CnpjVal::CnpjValidatorOptions` instance is stored by reference (mutating it later affects future `is_valid` calls that do not pass per-call options), while a `Hash` builds a new instance. When `options` is omitted (`nil`), the default options are built exclusively from the keyword arguments (`case_sensitive:`, `type:`). Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError` instead of silently ignoring the keywords. Example: `CnpjVal::CnpjValidator.new(type: 'numeric', case_sensitive: false)`.
- **`options`**: Returns the instance’s `CnpjVal::CnpjValidatorOptions` (same object used internally).
- **`is_valid(cnpj_input, options = nil, **keywords)`**: Validates a CNPJ value.

  Input is normalized to a string (arrays of strings are concatenated). When `case_sensitive` is `false`, the string is uppercased before sanitization. Characters are stripped according to `type`. If the sanitized length is not exactly **14**, the last two characters are not digits, or check digits do not match (`CnpjDV::CnpjCheckDigits` from **`cnpj-dv`**), the method returns `false` — no exception is raised for validation failure.

  If the input is not a `String` or an `Array` of strings, **`CnpjVal::TypeMismatchError`** is raised.

  Per-call `options` and keyword arguments are never merged: a given `options` argument alone fully overrides the instance defaults for this call; otherwise, any given keyword overrides the instance defaults for this call. When neither is given, the instance defaults are used as-is. The instance defaults are never mutated by a per-call override. Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError`.

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new(type: 'numeric')

validator.is_valid('98.765.432/0001-98')   # => true
validator.is_valid('1QB5UKALPYFP59')       # => false (letters stripped → length ≠ 14)
validator.is_valid('1QB5UKALpyfp59', type: 'alphanumeric', case_sensitive: false)  # => true
```

Default options on the instance; per-call overrides:

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new(case_sensitive: false)

validator.is_valid('1qb5ukalpyfp59')                  # => true (instance defaults)
validator.is_valid('1qb5ukalpyfp59', case_sensitive: true)  # this call only: false
validator.is_valid('1qb5ukalpyfp59')                  # => true again
```

### `CnpjVal::CnpjValidatorOptions`

Holds validator settings (`case_sensitive`, `type`). Construct with an optional options `Hash` or `CnpjVal::CnpjValidatorOptions` instance, optional extra override objects (merged in order), and/or keyword arguments. Exposes accessors: `case_sensitive`, `type`.

- **`all`**: Returns a shallow, frozen `Hash` snapshot of all current options.
- **`set(options)`**: Updates multiple fields at once; returns `self`. Accepts a `Hash` or another `CnpjVal::CnpjValidatorOptions` instance. Omitted keys retain their current values.

```ruby
require 'cnpj-val'

options = CnpjVal::CnpjValidatorOptions.new(case_sensitive: false, type: 'numeric')
options.case_sensitive   # => false
options.type             # => "numeric"
options.set({ type: 'alphanumeric' })  # merge and return self
options.all              # => frozen snapshot of current options
```

### Functional helper

`CnpjVal.cnpj_val` builds a new `CnpjVal::CnpjValidator` from the same constructor parameters and calls `is_valid(cnpj_input)` once. Pass either keyword arguments **or** a `Hash`/`CnpjVal::CnpjValidatorOptions` instance for options — not both (passing `options` with any non-`nil` keyword raises `InvalidArgumentCombinationError`):

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val('98765432000198')                              # => true
CnpjVal.cnpj_val('1QB5UKALpyfp59', case_sensitive: false)       # => true
CnpjVal.cnpj_val('1QB5UKALPYFP59', type: 'numeric')           # => false
CnpjVal.cnpj_val('1QB5UKALpyfp59', {                            # Hash form
  type: 'alphanumeric',
  case_sensitive: false,
})                                                              # => true
```

### Input formats

**String:** Raw digits and/or letters, or formatted CNPJ (e.g. `98.765.432/0001-98`, `1Q.B5U.KAL/PYFP-59`). Characters are stripped according to `type`; when `case_sensitive` is `false`, letters are uppercased before alphanumeric validation.

**Array of strings:** Each element must be a `String`; values are concatenated (e.g. per digit, grouped segments, or mixed with punctuation). Non-string elements raise **`CnpjVal::TypeMismatchError`**.

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val(['1', 'Q', 'B', '5', 'U', 'K', 'A', 'L', 'P', 'Y', 'F', 'P', '5', '9'])  # => true
CnpjVal.cnpj_val(['1Q.B5U', 'KAL', 'PYFP-59'])  # => true
```

### Validation options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | `'alphanumeric'` \| `'numeric'` \| `nil` | `'alphanumeric'` | Character set after sanitization: alphanumeric (`0`–`9`, `A`–`Z`, `a`–`z`) or numeric-only (`0`–`9`) |
| `case_sensitive` | `Boolean`, `nil` | `true` | When `false`, lowercase letters are uppercased before alphanumeric validation |

Invalid CNPJ (wrong length after sanitization, invalid check digits, ineligible base/branch `00000000` / `0000`, repeated digits, non-numeric verifier digits) returns **`false`** — no exception is raised for validation failure.

Example with all options:

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val(
  '1QB5UKALpyfp59',
  type: 'alphanumeric',
  case_sensitive: false,
)
```

### Error handling

Errors fall into two categories:

| Category | Meaning |
|---|---|
| **API misuse** | The caller invoked the library incorrectly (wrong type for the CNPJ input or an option, or an invalid argument combination). |
| **Domain error** | The call was structurally correct, but a value violates a business rule (invalid `type` string). |

Every custom error includes the `CnpjVal::Error` marker module. Domain failures (`ValidationError`) inherit from `CnpjVal::DomainError` (`RangeError`). Invalid CNPJ data returns `false` (it does not raise).

**Important:** passing both an `options` instance/`Hash` and any non-`nil` keyword argument raises `InvalidArgumentCombinationError`.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CnpjVal::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Both an `options` instance/`Hash` and any non-`nil` keyword argument are passed at once |
| `CnpjVal::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | CNPJ input or option has the wrong data type |
| `CnpjVal::ValidationError` | `CnpjVal::DomainError` | Domain error | `type` is not one of the allowed values |

#### `CnpjVal::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CnpjVal::Error
  # everything this library raises
```

#### `CnpjVal::DomainError`

- **Inheritance:** `CnpjVal::DomainError < RangeError` (includes `CnpjVal::Error`)
- **Category:** Domain error — ancestor for all domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CnpjVal::ValidationError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CnpjVal::DomainError
  # ValidationError and other DomainError subclasses
```

#### `CnpjVal::TypeMismatchError`

- **Inheritance:** `CnpjVal::TypeMismatchError < TypeError` (includes `CnpjVal::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when the CNPJ input is not a `String` or `Array` of strings, or when a validator option (`type`) has the wrong runtime type.
- **Example:**

```ruby
CnpjVal.cnpj_val(12_345_678_000_198) # raises CnpjVal::TypeMismatchError
CnpjVal.cnpj_val('98765432000198', type: 123) # raises CnpjVal::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CnpjVal::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CnpjVal::InvalidArgumentCombinationError`

- **Inheritance:** `CnpjVal::InvalidArgumentCombinationError < ArgumentError` (includes `CnpjVal::Error`)
- **Category:** API misuse — the provided arguments do not form a valid API signature.
- **When it is raised:** Raised when `CnpjValidator.new`, `#is_valid`, or `cnpj_val` receives both an `options` argument (instance or `Hash`) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
begin
  CnpjVal.cnpj_val('98765432000198', { type: 'numeric' }, case_sensitive: false)
rescue CnpjVal::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (case_sensitive:, type:), not both.
end
```

- **How to rescue it:**

```ruby
rescue CnpjVal::InvalidArgumentCombinationError
  # this library's invalid signature combination

rescue ArgumentError
  # native argument errors, including this library's InvalidArgumentCombinationError
```

#### `CnpjVal::ValidationError`

- **Inheritance:** `CnpjVal::ValidationError < CnpjVal::DomainError < RangeError` (includes `CnpjVal::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when `type` is not one of `'alphanumeric'` or `'numeric'`.
- **Example:**

```ruby
CnpjVal.cnpj_val('98765432000198', type: 'invalid') # raises CnpjVal::ValidationError
```

- **How to rescue it:**

```ruby
rescue CnpjVal::ValidationError
  # this exact domain validation failure

rescue CnpjVal::DomainError
  # ValidationError and other DomainError subclasses
```

#### Rescue granularity

```ruby
# 1) Single native class — catches misuse errors of that kind.
rescue TypeError
  # CnpjVal::TypeMismatchError and any other TypeError (library or not)

# 2) CnpjVal::DomainError — catches all business-rule violations under DomainError.
rescue CnpjVal::DomainError
  # CnpjVal::ValidationError and other DomainError subclasses

# 3) CnpjVal::Error — catches everything the library raises.
rescue CnpjVal::Error
  # every custom error that includes CnpjVal::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CnpjVal::ValidationError
  # only CnpjVal::ValidationError
```

Notable attributes on raised errors:

- `TypeMismatchError`: `option_name` (nil for CNPJ input), `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `expected_values`

## API

### Exports

After `require 'cnpj-val'`:

- **`CnpjVal.cnpj_val`**: `(cnpj_input, options = nil, **keywords) -> Boolean` — convenience helper.
- **`CnpjVal::CnpjValidator`**: Class to validate CNPJ with optional default options; accepts `String` or `Array<String>` in `is_valid`.
- **`CnpjVal::CnpjValidatorOptions`**: Class holding options; supports merge via constructor, `set`, and keyword arguments.
- **`CnpjVal::CNPJ_LENGTH`**: `14` (constant).
- **`CnpjVal::VERSION`**: gem version string.
- **Type predicate**: `CnpjVal::CnpjInput` — `CnpjVal::CnpjInput.accept?(value)` / `CnpjVal::CnpjInput === value` is true only for `String` or `Array<String>`.
- **Type markers**: `CnpjVal::CnpjType`, `CnpjVal::CnpjValidatorOptionsInput`.
- **Errors**: `CnpjVal::Error`, `CnpjVal::DomainError`, `CnpjVal::InvalidArgumentCombinationError`, `CnpjVal::TypeMismatchError`, `CnpjVal::ValidationError`.

### Other available resources

- **`CnpjVal::CnpjValidatorOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjVal::CnpjValidatorOptions::DEFAULT_CASE_SENSITIVE`**: `true`.
- **`CnpjVal::CnpjValidatorOptions::DEFAULT_TYPE`**: `'alphanumeric'`.

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
