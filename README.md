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

| ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Alphanumeric CNPJ**: Generates 14-character CNPJ with optional numeric, alphabetic, or alphanumeric (default) character sets
- ✅ **Optional prefix**: Provide 0–12 alphanumeric characters to fix the start of the CNPJ (e.g. base ID) and generate the rest with valid check digits
- ✅ **Formatting**: Option to return the standard formatted string (`00.000.000/0000-00`)
- ✅ **Reusable generator**: `CnpjGen::CnpjGenerator` class with default options and per-call overrides
- ✅ **Keyword overrides**: Pass `format:`, `prefix:`, and `type:` on `cnpj_gen`, `CnpjGenerator#generate`, and constructors
- ✅ **Minimal dependencies**: Only [`cnpj-dv`](https://rubygems.org/gems/cnpj-dv) and [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Error handling**: Specific type errors and exceptions for invalid options

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
| `format` | `Boolean`, `nil` | `false` | When truthy, return the generated CNPJ in standard format (`00.000.000/0000-00`). Non-boolean values are coerced (`false`, `''`, and `0` become `false`; other values become truthy). |
| `prefix` | `String`, `nil` | `''` | Partial start string (0–12 alphanumeric chars). Only alphanumeric characters are kept and uppercased; missing characters are generated randomly and check digits are computed. |
| `type` | `String`, `nil` | `'alphanumeric'` | Character set for the randomly generated part (`prefix` is kept as-is after sanitization). Must be one of `'numeric'`, `'alphabetic'`, or `'alphanumeric'`. **Check digits are always numeric.** |

Prefix rules: base ID (first 8 chars) and branch ID (chars 9–12) cannot be all zeros; 12 repeated digits (e.g. `777777777777`) are also not allowed.

### `CnpjGen.cnpj_gen` (helper)

Generates a valid CNPJ string. With no options, returns a 14-character alphanumeric CNPJ. This is a convenience wrapper around `CnpjGen::CnpjGenerator.new(...).generate`.

- **`options`** (optional): `CnpjGen::CnpjGeneratorOptions` instance, a `Hash` of option keys, or `nil`. See [Generator options](#generator-options).
- **`format`**, **`prefix`**, **`type`** (keyword arguments): Per-option overrides when `options` is omitted or to layer on top of a `Hash`.

### `CnpjGen::CnpjGenerator` (class)

For reusable defaults or per-call overrides, use the class:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(type: 'numeric', format: true)

generator.generate                    # => e.g. "73.008.535/0005-06"
generator.generate(prefix: '12345678')   # override for this call only
generator.options                     # current default options (CnpjGen::CnpjGeneratorOptions)
```

- **`initialize(options = nil, format: nil, prefix: nil, type: nil)`**: Optional default options (plain `Hash`, `CnpjGen::CnpjGeneratorOptions` instance, or keyword arguments). When `options` is a `CnpjGen::CnpjGeneratorOptions` instance, that exact instance is stored (mutating it later affects future `generate` calls that do not pass per-call options).
- **`generate(options = nil, format: nil, prefix: nil, type: nil)`**: Returns a valid CNPJ; per-call options override instance defaults for that call only.
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
```

- **`initialize(options = nil, *extra_overrides, format: nil, prefix: nil, type: nil)`**: Options merged in order (later overrides win). Extra positional arguments may be `Hash` objects or other `CnpjGen::CnpjGeneratorOptions` instances.
- **`format`**, **`prefix`**, **`type`**: Accessors with setters; `prefix` is validated (base/branch ineligible, repeated digits).
- **`set(options)`**: Update multiple options at once; omitted/`nil` fields in a `Hash` keep their current value; returns `self`. Accepts a `Hash` or another `CnpjGen::CnpjGeneratorOptions` instance.
- **`all`**: Shallow `Hash` copy of current options (`:format`, `:prefix`, `:type`).

## API

### Exports

After `require 'cnpj-gen'`:

- **`CnpjGen.cnpj_gen`**: `(options = nil, format: nil, prefix: nil, type: nil) -> String` — convenience helper.
- **`CnpjGen::CnpjGenerator`**: Class to generate CNPJ with optional default options and per-call overrides.
- **`CnpjGen::CnpjGeneratorOptions`**: Class holding options with validation and merge.
- **`CnpjGen::CNPJ_LENGTH`**: `14` (constant).
- **`CnpjGen::CNPJ_PREFIX_MAX_LENGTH`**: `12` (constant).
- **`CnpjGen::CNPJ_TYPE_VALUES`**: `%w[alphabetic alphanumeric numeric]` — allowed `type` values.
- **`CnpjGen::VERSION`**: gem version string.
- **Exceptions**: `CnpjGen::CnpjGeneratorTypeError`, `CnpjGen::CnpjGeneratorOptionsTypeError`, `CnpjGen::CnpjGeneratorException`, `CnpjGen::CnpjGeneratorOptionPrefixInvalidException`, `CnpjGen::CnpjGeneratorOptionTypeInvalidException`.

### Errors & Exceptions

This package uses **TypeError** subclasses for invalid option types and **StandardError** subclasses for invalid option values (`prefix` or `type`). You can rescue specific classes or the base types.

- **CnpjGen::CnpjGeneratorTypeError** — base for option type errors (abstract; rescue subclasses)
- **CnpjGen::CnpjGeneratorOptionsTypeError** — an option has the wrong type (e.g. `prefix` not a `String`)
- **CnpjGen::CnpjGeneratorException** — base for option value exceptions
- **CnpjGen::CnpjGeneratorOptionPrefixInvalidException** — prefix invalid (e.g. all-zero base/branch, repeated digits)
- **CnpjGen::CnpjGeneratorOptionTypeInvalidException** — `type` is not one of `'numeric'`, `'alphabetic'`, `'alphanumeric'`

```ruby
require 'cnpj-gen'

# Option type (e.g. `prefix` must be String)
begin
  CnpjGen.cnpj_gen(prefix: 123)
rescue CnpjGen::CnpjGeneratorOptionsTypeError => e
  puts e.option_name, e.expected_type, e.actual_type
  # CNPJ generator option "prefix" must be of type string. Got integer number.
end

# Invalid prefix (e.g. all-zero base)
begin
  CnpjGen.cnpj_gen(prefix: '000000000001')
rescue CnpjGen::CnpjGeneratorOptionPrefixInvalidException => e
  puts e.reason, e.actual_input
end

# Invalid type value
begin
  CnpjGen.cnpj_gen(type: 'invalid')
rescue CnpjGen::CnpjGeneratorOptionTypeInvalidException => e
  puts e.expected_values, e.actual_input
end

# Any exception from the package
begin
  CnpjGen.cnpj_gen(prefix: '000000000000')
rescue CnpjGen::CnpjGeneratorException => e
  puts e.message
end
```

Notable attributes on raised errors:

- `CnpjGeneratorOptionsTypeError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `CnpjGeneratorOptionPrefixInvalidException`: `actual_input`, `reason`
- `CnpjGeneratorOptionTypeInvalidException`: `actual_input`, `expected_values`

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
