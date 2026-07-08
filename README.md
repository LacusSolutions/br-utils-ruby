# Lacus Solutions' Utils

[![Gem Version](https://img.shields.io/gem/v/lacus-utils)](https://rubygems.org/gems/lacus-utils)
[![Downloads Count](https://img.shields.io/gem/dt/lacus-utils)](https://rubygems.org/gems/lacus-utils)
[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.2-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

A Ruby reusable utilities library for Lacus Solutions' packages.

## Ruby Support

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
|--- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

## Features

- **Type description**: Ruby-native type labels for error messages (`nil`, `hash`, `symbol`, built-ins, arrays, `NaN`, `Infinity`)
- **Random sequences**: Generate numeric, alphabetic, or alphanumeric sequences of any length using a cryptographically secure RNG
- **Zero dependencies**: No external runtime dependencies

## Installation

Install the gem directly:

```bash
gem install lacus-utils
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'lacus-utils'
```

## Require

```ruby
require 'lacus-utils'
```

## Quick Start

```ruby
require 'lacus-utils'

LacusUtils.describe_type(nil)              # => 'nil'
LacusUtils.describe_type('hello')          # => 'string'
LacusUtils.describe_type(42)               # => 'integer number'
LacusUtils.describe_type(3.14)             # => 'float number'
LacusUtils.describe_type([1, 2, 3])        # => 'number[]'
LacusUtils.describe_type([1, 'a', 2])      # => '(number | string)[]'
LacusUtils.describe_type({})               # => 'hash'

LacusUtils.generate_random_sequence(10, :numeric)      # => e.g. '9956000611'
LacusUtils.generate_random_sequence(6, :alphabetic)    # => e.g. 'AXQMZB'
LacusUtils.generate_random_sequence(8, :alphanumeric)  # => e.g. '8ZFB2K09'
LacusUtils.generate_random_sequence(8)                 # => e.g. '8ZFB2K09' (alphanumeric)
```

## API

All entry points are module functions on `LacusUtils`, implemented in [`src/`](src/) and covered by tests in [`tests/`](tests/).

### `LacusUtils.describe_type(value) -> String`

Describes the type of a value for error messages. Pure, deterministic, and never raises.

| Input | Result |
|--------|--------|
| `nil` | `'nil'` |
| `String` | `'string'` |
| `true` / `false` | `'boolean'` |
| `Integer` | `'integer number'` |
| `Float` (finite) | `'float number'` |
| `Float::NAN` | `'NaN'` |
| `Float::INFINITY` / `-Float::INFINITY` | `'Infinity'` |
| `Complex` | `'complex number'` |
| `Rational` | `'rational number'` |
| `Symbol` | `'symbol'` |
| `Hash` | `'hash'` |
| `Set` | `'set'` |
| `Proc` / `Method` | `'function'` |
| `Class` / `Module` | `'class'` |
| custom object | `'object'` |
| `[]` | `'Array (empty)'` |
| `[1, 2, 3]` | `'number[]'` |
| `[1, 'a', 2]` | `'(number \| string)[]'` |

Inside an array, numeric values collapse to `'number'`, and the union of element types preserves first-seen order (it is **not** sorted).

### `LacusUtils.generate_random_sequence(size, type = :alphanumeric) -> String`

Generates a random character sequence of the given length and type, drawn using a cryptographically secure RNG (`SecureRandom`).

- **`size`**: `Integer` — length of the sequence (e.g. `10`). `0` returns `''`.
- **`type`**: `Symbol` — character set to draw from (defaults to `:alphanumeric`). One of:
  - **`:numeric`**: digits `0-9`
  - **`:alphabetic`**: uppercase letters `A-Z`
  - **`:alphanumeric`**: digits and uppercase letters `0-9A-Z`

```ruby
LacusUtils.generate_random_sequence(10, :numeric)      # => e.g. '9956000611'
LacusUtils.generate_random_sequence(6, :alphabetic)    # => e.g. 'AXQMZB'
LacusUtils.generate_random_sequence(8)                 # => e.g. '8ZFB2K09' (alphanumeric)
LacusUtils.generate_random_sequence(0)                 # => ''
```

Raises `ArgumentError` when `size` is negative, and `ArgumentError` when `type` is not one of the three known kinds:

```ruby
LacusUtils.generate_random_sequence(-1)       # => ArgumentError: size must be non-negative, got -1
LacusUtils.generate_random_sequence(4, :foo)  # => ArgumentError: unknown sequence type: :foo
```

### Exports summary

| Method | Description |
|--------|-------------|
| `describe_type(value)` | Type description for error messages |
| `generate_random_sequence(size, type = :alphanumeric)` | Random sequence generation |

## Contribution & Support

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md) for details. If you find this project helpful, please consider:

- ⭐ Starring the repository
- 🤝 Contributing to the codebase
- 💡 [Suggesting new features](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reporting bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE) file for details.

## Changelog

See [CHANGELOG](./CHANGELOG.md) for a list of changes and version history.

---

Made with ❤️ by [Lacus Solutions](https://github.com/LacusSolutions)
