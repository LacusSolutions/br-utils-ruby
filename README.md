![cnpj-gen for Ruby](https://br-utils.vercel.app/img/cover_cnpj-gen.jpg)

[![Gem Version](https://img.shields.io/gem/v/cnpj-gen)](https://rubygems.org/gems/cnpj-gen)
[![Gem Downloads](https://img.shields.io/gem/dt/cnpj-gen)](https://rubygems.org/gems/cnpj-gen)
[![Ruby Version](https://img.shields.io/gem/rv/cnpj-gen)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby utility to generate valid CNPJ (Brazilian Business Tax ID) values.

## Ruby Support

| ![Ruby 3.1](https://img.shields.io/badge/Ruby-3.1-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) | ![Ruby 4.0](https://img.shields.io/badge/Ruby-4.0-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Alphanumeric CNPJ**: Generates 14-character CNPJ with optional numeric, alphabetic, or alphanumeric (default) character sets
- ✅ **Optional prefix**: Provide 0–12 alphanumeric characters to fix the start of the CNPJ (e.g. base ID) and generate the rest with valid check digits
- ✅ **Formatting**: Option to return the standard formatted string (`00.000.000/0000-00`)
- ✅ **Reusable generator**: `CnpjGen::CnpjGenerator` class with default options and per-call overrides
- ✅ **Keyword overrides**: Pass `format:`, `prefix:`, and `type:` on `cnpj_gen`, `CnpjGenerator#generate`, and constructors
- ✅ **Minimal dependencies**: Only [`cnpj-dv`](https://rubygems.org/gems/cnpj-dv) and [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: API misuse vs domain errors with a `CnpjGen::Error` marker for library-wide rescue

## Installation

Install the gem directly:

```bash
gem install cnpj-gen
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cnpj-gen'
```

## Require

```ruby
require 'cnpj-gen'
```

## Quick Start

```ruby
require 'cnpj-gen'

CnpjGen.cnpj_gen                    # => e.g. "AB123CDE000155" (14-char alphanumeric)

CnpjGen.cnpj_gen(format: true)      # => e.g. "AB.123.CDE/0001-55"

CnpjGen.cnpj_gen(prefix: '45623767')           # => e.g. "45623767ABCD96"
CnpjGen.cnpj_gen(                              # => e.g. "45.623.767/ABCD-96"
  prefix: '45623767',
  format: true
)

CnpjGen.cnpj_gen(type: 'numeric')      # => e.g. "65453043000178" (digits only)
CnpjGen.cnpj_gen(type: 'alphabetic')   # => e.g. "ABCDEFGHIJKL80" (letters only, except check digits)
```

Options can also be passed as a `Hash`:

```ruby
CnpjGen.cnpj_gen({ format: true, type: 'numeric' })
```

## Usage

The main entry points are the module helper `CnpjGen.cnpj_gen`, the class `CnpjGen::CnpjGenerator`, and the options class `CnpjGen::CnpjGeneratorOptions`.

### Generator options

All options are optional:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When truthy, return the generated CNPJ in standard format (`00.000.000/0000-00`). Non-boolean values are coerced (`false`, `''`, and `0` become `false`; other values become truthy). |
| `prefix` | `String` | `''` | Partial start string (0–12 alphanumeric chars). Only alphanumeric characters are kept and uppercased; missing characters are generated randomly and check digits are computed. |
| `type` | `String` | `'alphanumeric'` | Character set for the randomly generated part (`prefix` is kept as-is after sanitization). Must be one of `'numeric'`, `'alphabetic'`, or `'alphanumeric'`. **Check digits are always numeric.** |

Prefix rules: base ID (first 8 chars) and branch ID (chars 9–12) cannot be all zeros; 12 repeated digits (e.g. `777777777777`) are also not allowed.

`nil` is accepted as a keyword argument on `cnpj_gen`, `CnpjGenerator.new`, `CnpjGenerator#generate`, and `CnpjGeneratorOptions.new`/`#set` — it simply means "no override for this option". It is **not** accepted by the `CnpjGeneratorOptions` property setters (`options.format = value`, `options.prefix = value`, `options.type = value`): calling a setter with `nil` directly raises `CnpjGen::TypeMismatchError`. To reset a property to its default value through a setter, pass the literal constant instead, e.g. `options.format = CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT`.

### `CnpjGen.cnpj_gen` (helper)

Generates a valid CNPJ string. With no options, returns a 14-character alphanumeric CNPJ. This is a convenience wrapper around `CnpjGen::CnpjGenerator.new(...).generate`.

- **`options`** (optional): `CnpjGen::CnpjGeneratorOptions` instance, a `Hash` of option keys, or `nil`. See [Generator options](#generator-options).
- **`format`**, **`prefix`**, **`type`** (keyword arguments): Only used when `options` is omitted (`nil`). Passing `options` **and** any non-`nil` of these keywords at the same time raises `InvalidArgumentCombinationError` — the two ways of passing options are never merged.

### `CnpjGen::CnpjGenerator` (class)

For reusable defaults or per-call overrides, use the class:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(type: 'numeric', format: true)

generator.generate                    # => e.g. "73.008.535/0005-06"
generator.generate(prefix: '12345678')   # override for this call only
generator.options                     # current default options (CnpjGen::CnpjGeneratorOptions)
```

- **`initialize(options = nil, **keywords)`**: Optional default options. When `options` is given (a `CnpjGen::CnpjGeneratorOptions` instance or a `Hash`) alone, it determines the default options; a `CnpjGen::CnpjGeneratorOptions` instance is stored by reference (mutating it later affects future `generate` calls that do not pass per-call options), while a `Hash` builds a new instance. When `options` is omitted (`nil`), the default options are built exclusively from the keyword arguments (`format:`, `prefix:`, `type:`). Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError` instead of silently ignoring the keywords.
- **`generate(options = nil, **keywords)`**: Returns a valid CNPJ. `options` and the keyword arguments are never merged: a given `options` argument alone fully overrides the instance defaults for this call; otherwise, any given keyword overrides the instance defaults for this call. When neither is given, the instance defaults are used as-is. The instance defaults are never mutated by a per-call override. Passing `options` together with any non-`nil` keyword raises `InvalidArgumentCombinationError`.
- **`options`**: Reader returning the default options used when per-call options are not provided (same instance as used internally; mutating it affects future `generate` calls).

Default options on the instance; per-call overrides:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(format: true)

generator.generate              # formatted CNPJ
generator.generate(format: false)  # this call only: unformatted
generator.generate              # formatted again (instance defaults preserved)
```

### `CnpjGen::CnpjGeneratorOptions` (class)

Holds options (`format`, `prefix`, `type`) with validation and merge support:

```ruby
require 'cnpj-gen'

options = CnpjGen::CnpjGeneratorOptions.new(
  prefix: 'AB123XYZ',
  type: 'numeric',
  format: true
)
options.prefix   # => "AB123XYZ"
options.type     # => "numeric"
options.format   # => true
options.set(format: false)  # merge and return self
options.all      # => { format: false, prefix: "AB123XYZ", type: "numeric" }

# Resetting a property to its default value requires the literal constant —
# a bare `nil` on a setter raises TypeMismatchError:
options.format = CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT
```

- **`initialize(*options, **keywords)`**: Every positional `options` argument (each a `Hash` or another `CnpjGen::CnpjGeneratorOptions` instance) is folded left to right — later arguments win — then the keyword arguments (`format:`, `prefix:`, `type:`) are applied on top with the highest precedence. At every step, a `nil` value for a given key is ignored in favor of whatever was resolved so far. Any option still unresolved after that is set to its `DEFAULT_*` value.
- **`format`**, **`prefix`**, **`type`**: Accessors with setters; `prefix` is validated (base/branch ineligible, repeated digits). The setters **never accept `nil`** — pass the matching `DEFAULT_*` constant (e.g. `CnpjGeneratorOptions::DEFAULT_PREFIX`) to reset a property explicitly.
- **`set(*options, **keywords)`**: Updates multiple options at once, using the same fold-then-keywords, ignore-`nil` resolution as `initialize`. Any option left unresolved after merging keeps its **current** value on the instance (a partial update, not a re-initialization). Returns `self`.
- **`all`**: Shallow `Hash` copy of current options (`:format`, `:prefix`, `:type`).

## API

### Exports

After `require 'cnpj-gen'`:

- **`CnpjGen.cnpj_gen`**: `(options = nil, **keywords) -> String` — convenience helper.
- **`CnpjGen::CnpjGenerator`**: Class to generate CNPJ with optional default options and per-call overrides.
- **`CnpjGen::CnpjGeneratorOptions`**: Class holding options with validation and merge.
- **`CnpjGen::CNPJ_LENGTH`**: `14` (constant).
- **`CnpjGen::CNPJ_PREFIX_MAX_LENGTH`**: `12` (constant).
- **`CnpjGen::CNPJ_TYPE_VALUES`**: `%w[alphabetic alphanumeric numeric]` — allowed `type` values.
- **`CnpjGen::VERSION`**: gem version string.
- **Errors**: `CnpjGen::Error`, `CnpjGen::DomainError`, `CnpjGen::InvalidArgumentCombinationError`, `CnpjGen::TypeMismatchError`, `CnpjGen::ValidationError`.

### Error handling

Errors fall into two categories:

| Category | Meaning |
|---|---|
| **API misuse** | The caller invoked the library incorrectly (wrong type for an option, or an invalid argument combination). |
| **Domain error** | The call was structurally correct, but a value violates a business rule (invalid `prefix`, or `type` not in the allowed set). |

Every custom error includes the `CnpjGen::Error` marker module. Domain failures (`ValidationError`) inherit from `CnpjGen::DomainError` (`RangeError`).

**Important:** passing both an `options` instance/`Hash` and any non-`nil` keyword argument raises `InvalidArgumentCombinationError`.

#### Summary

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `CnpjGen::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Both an `options` instance/`Hash` and any non-`nil` keyword argument are passed at once |
| `CnpjGen::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | A generator option has the wrong data type |
| `CnpjGen::ValidationError` | `CnpjGen::DomainError` | Domain error | `prefix` is ineligible, or `type` is not one of the allowed values |

#### `CnpjGen::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue CnpjGen::Error
  # everything this library raises
```

#### `CnpjGen::DomainError`

- **Inheritance:** `CnpjGen::DomainError < RangeError` (includes `CnpjGen::Error`)
- **Category:** Domain error — ancestor for all domain failures.
- **When it is raised:** Not raised directly; prefer raising a leaf subclass.
- **Example:** Prefer `raise CnpjGen::ValidationError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue CnpjGen::DomainError
  # ValidationError and other DomainError subclasses
```

#### `CnpjGen::TypeMismatchError`

- **Inheritance:** `CnpjGen::TypeMismatchError < TypeError` (includes `CnpjGen::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when a generator option (`format`, `prefix`, or `type`) has the wrong runtime type.
- **Example:**

```ruby
CnpjGen.cnpj_gen(prefix: 123) # raises CnpjGen::TypeMismatchError
```

- **How to rescue it:**

```ruby
rescue CnpjGen::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `CnpjGen::InvalidArgumentCombinationError`

- **Inheritance:** `CnpjGen::InvalidArgumentCombinationError < ArgumentError` (includes `CnpjGen::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `CnpjGenerator.new`, `#generate`, or `cnpj_gen` receives both an `options` argument (instance or `Hash`) and any non-`nil` keyword argument at the same time.
- **Example:**

```ruby
begin
  CnpjGen::CnpjGenerator.new({ format: true }, prefix: 'AB')
rescue CnpjGen::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (format:, prefix:, type:), not both.
end
```

- **How to rescue it:**

```ruby
rescue CnpjGen::InvalidArgumentCombinationError
  # this library's invalid argument combination

rescue ArgumentError
  # native argument errors, including this library's InvalidArgumentCombinationError
```

#### `CnpjGen::ValidationError`

- **Inheritance:** `CnpjGen::ValidationError < CnpjGen::DomainError < RangeError` (includes `CnpjGen::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule.
- **When it is raised:** Raised when `prefix` is ineligible (zeroed base/branch ID, or 12 repeated digits), or when `type` is not one of `'alphabetic'`, `'alphanumeric'`, or `'numeric'`.
- **Example:**

```ruby
CnpjGen.cnpj_gen(prefix: '000000000001') # raises CnpjGen::ValidationError
CnpjGen.cnpj_gen(type: 'invalid')        # raises CnpjGen::ValidationError
```

- **How to rescue it:**

```ruby
rescue CnpjGen::ValidationError
  # this exact domain validation failure

rescue CnpjGen::DomainError
  # RangeError-rooted domain failures from this library
```

#### Rescue granularity

```ruby
# 1) Single native class — catches type misuse from this library (and other TypeErrors).
rescue TypeError
  # CnpjGen::TypeMismatchError and any other TypeError (library or not)

# 2) CnpjGen::DomainError — catches business-rule violations under DomainError.
rescue CnpjGen::DomainError
  # CnpjGen::ValidationError and other DomainError subclasses

# 3) CnpjGen::Error — catches everything the library raises.
rescue CnpjGen::Error
  # every custom error that includes CnpjGen::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue CnpjGen::ValidationError
  # only CnpjGen::ValidationError
```

Notable attributes:

- `TypeMismatchError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `reason` (prefix failures), `expected_values` (type failures)

Property setters never accept `nil` directly — pass the matching `DEFAULT_*` constant to reset:

```ruby
options = CnpjGen::CnpjGeneratorOptions.new
begin
  options.prefix = nil
rescue CnpjGen::TypeMismatchError => e
  puts e.message
  # CNPJ generator option "prefix" must be of type string. Got nil.
end

options.prefix = CnpjGen::CnpjGeneratorOptions::DEFAULT_PREFIX # explicit reset instead
```

Check-digit computation failures from `cnpj-dv` are handled internally by retrying generation with the same resolved options; they are not raised to callers under normal operation.

### Other available resources

- **`CnpjGen::CnpjGeneratorOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjGen::CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH`**: `12`.
- **`CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT`**, **`DEFAULT_PREFIX`**, **`DEFAULT_TYPE`**: Class-level default constants.

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
