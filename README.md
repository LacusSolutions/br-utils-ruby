cpf-dv for Ruby

[Gem Version](https://rubygems.org/gems/cpf-dv)
[Downloads Count](https://rubygems.org/gems/cpf-dv)
[Ruby Version](https://www.ruby-lang.org/)
[Test Status](https://github.com/LacusSolutions/br-utils-ruby/actions)
[Last Update Date](https://github.com/LacusSolutions/br-utils-ruby)
[Project License](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🌎 [Acessar documentação em português](https://github.com/LacusSolutions/br-utils-ruby/blob/main/packages/cpf-dv/README.pt.md)

A Ruby utility to calculate check digits on CPF (Brazilian Individual's Taxpayer ID).

## Ruby Support


| Ruby 3.1  | Ruby 3.2  | Ruby 3.3  | Ruby 3.4  | Ruby 4.0  |
| --------- | --------- | --------- | --------- | --------- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |




## Features

- ✅ **Flexible input**: Accepts `String` or `Array` of strings
- ✅ **Format agnostic**: Strips non-numeric characters from string input
- ✅ **Auto-expansion**: Multi-character strings in arrays are joined and parsed like a single string
- ✅ **Input validation**: Rejects ineligible CPFs (9 identical digits in the base — repeated-digit pattern)
- ✅ **Lazy evaluation**: Check digits are calculated only when accessed (via methods)
- ✅ **Caching**: Calculated values are cached for subsequent access
- ✅ **Minimal dependencies**: Only [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: API misuse vs domain errors with a `CpfDV::Error` marker for library-wide rescue



## Installation

Install the gem directly:

```bash
gem install cpf-dv
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cpf-dv'
```



## Require

```ruby
require 'cpf-dv'
```



## Quick Start

```ruby
require 'cpf-dv'

check_digits = CpfDV::CpfCheckDigits.new('054496519')

check_digits.first   # => '1'
check_digits.second  # => '0'
check_digits.both    # => '10'
check_digits.cpf     # => '05449651910'
```



## Usage

The main resource of this package is the class `CpfDV::CpfCheckDigits`. Through an instance, you access CPF check-digit information:

- `initialize`: `CpfDV::CpfCheckDigits.new(cpf_input)` — `cpf_input` must be a `String` or an `Array` of strings. After sanitization, the value must have 9–11 digits (formatting stripped from strings). Only the **first 9** digits are used as the base; if you pass 10 or 11 digits (e.g. a full CPF including prior check digits), digits 10–11 are **ignored** and the check digits are recalculated. There are **no options**, keyword arguments, or configuration objects — the constructor takes only the CPF input.
- `first`: First check digit (10th digit of the full CPF). Lazy, cached.
- `second`: Second check digit (11th digit of the full CPF). Lazy, cached.
- `both`: Both check digits concatenated as a string.
- `cpf`: The complete CPF as a string of 11 digits (9 base digits + 2 check digits).



### Input formats

The `CpfCheckDigits` class accepts multiple input formats:

**String input:** plain digits or formatted CPF (e.g. `054.496.519-10`, `123.456.789`). Non-numeric characters are removed. Leading zeros are preserved.

**Array of strings:** each element must be a string; values are concatenated and then parsed like a single string (e.g. `['0','5','4',…]`, `['054','496','519']`, `['054496519']`). Non-string elements are not allowed.

```ruby
require 'cpf-dv'

# String — plain, formatted, or with existing check digits (only first 9 digits used)
CpfDV::CpfCheckDigits.new('054496519')
CpfDV::CpfCheckDigits.new('054.496.519-10')
CpfDV::CpfCheckDigits.new('05449651910')

# Array of strings — single- or multi-character elements
CpfDV::CpfCheckDigits.new(%w[0 5 4 4 9 6 5 1 9])
CpfDV::CpfCheckDigits.new(%w[054 496 519])
CpfDV::CpfCheckDigits.new(%w[054496519])
```



### Error handling

Errors fall into two categories:

| Category | Meaning |
|---|---|
| **API misuse** | The caller invoked the library incorrectly (wrong type). Detectable from the call shape. |
| **Domain error** | The call was structurally correct, but a value violates a business rule (length, eligibility). |

Every custom error includes the `CpfDV::Error` marker module. Domain failures (`InvalidLengthError`, `ValidationError`) inherit from `CpfDV::DomainError` (`RangeError`).

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CpfDV::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | Argument has the wrong data type |
| `CpfDV::InvalidLengthError` | `CpfDV::DomainError` | Domain error | Sanitized length is not 9–11 |
| `CpfDV::ValidationError` | `CpfDV::DomainError` | Domain error | First 9 digits are all identical (repeated-digit pattern) |

#### `CpfDV::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CpfDV::Error
  # everything this library raises
```

#### `CpfDV::DomainError`

- **Inheritance:** `CpfDV::DomainError < RangeError` (includes `CpfDV::Error`)
- **Category:** Domain error — ancestor for numeric/length domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CpfDV::InvalidLengthError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CpfDV::DomainError
  # InvalidLengthError, ValidationError, and any other DomainError subclass
```

#### `CpfDV::TypeMismatchError`

- **Inheritance:** `CpfDV::TypeMismatchError < TypeError` (includes `CpfDV::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when the CPF input is not a `String` or an `Array` of strings (or an array contains a non-string element).
- **Example:**

```ruby
CpfDV::CpfCheckDigits.new(12_345_678_901) # raises CpfDV::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CpfDV::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CpfDV::InvalidLengthError`

- **Inheritance:** `CpfDV::InvalidLengthError < CpfDV::DomainError < RangeError` (includes `CpfDV::Error`)
- **Category:** Domain error — a collection or string length violates a business rule.
- **When it is raised:** Raised when the sanitized CPF input does not contain 9 to 11 digits.
- **Example:**

```ruby
CpfDV::CpfCheckDigits.new('12345678') # raises CpfDV::InvalidLengthError
```

- **How to rescue it:**

```ruby
rescue CpfDV::InvalidLengthError
  # this exact length violation

rescue CpfDV::DomainError
  # RangeError-rooted domain failures from this library
```

#### `CpfDV::ValidationError`

- **Inheritance:** `CpfDV::ValidationError < CpfDV::DomainError < RangeError` (includes `CpfDV::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when the first 9 digits are all the same digit (repeated-digit pattern).
- **Example:**

```ruby
CpfDV::CpfCheckDigits.new('111111111') # raises CpfDV::ValidationError
```

- **How to rescue it:**

```ruby
rescue CpfDV::ValidationError
  # this exact domain validation failure

rescue CpfDV::DomainError
  # RangeError-rooted domain failures from this library
```

#### Rescue granularity

```ruby
# 1) Single native class — catches type misuse from this library (and other TypeErrors).
rescue TypeError
  # CpfDV::TypeMismatchError and any other TypeError (library or not)

# 2) CpfDV::DomainError — catches business-rule violations under DomainError.
rescue CpfDV::DomainError
  # CpfDV::InvalidLengthError, CpfDV::ValidationError, and other DomainError subclasses

# 3) CpfDV::Error — catches everything the library raises.
rescue CpfDV::Error
  # every custom error that includes CpfDV::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CpfDV::InvalidLengthError
  # only CpfDV::InvalidLengthError
```

Notable attributes on raised errors:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `min_expected_length`, `max_expected_length`
- `ValidationError`: `actual_input`, `reason`



### Other available resources

After `require 'cpf-dv'`:

- `CpfDV::CPF_MIN_LENGTH`: `9`
- `CpfDV::CPF_MAX_LENGTH`: `11`
- **Errors**: see above (`CpfDV::Error`, `DomainError`, and raised leaves)



## Calculation algorithm

The package calculates CPF check digits using the official Brazilian modulo-11 algorithm:

1. **First check digit (10th position):** apply to the first **9** base digits; weights **10, 9, 8, 7, 6, 5, 4, 3, 2** (left to right); let `remainder = 11 - (sum(digit × weight) % 11)`. The digit is `0` if `remainder > 9`, otherwise `remainder`.
2. **Second check digit (11th position):** apply to the first 9 base digits **plus** the first check digit; weights **11, 10, 9, 8, 7, 6, 5, 4, 3, 2** (left to right); same formula for `remainder`.



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
