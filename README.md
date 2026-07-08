cnpj-dv for Ruby

[Gem Version](https://rubygems.org/gems/cnpj-dv)
[Downloads Count](https://rubygems.org/gems/cnpj-dv)
[Ruby Version](https://www.ruby-lang.org/)
[Test Status](https://github.com/LacusSolutions/br-utils-ruby/actions)
[Last Update Date](https://github.com/LacusSolutions/br-utils-ruby)
[Project License](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](https://github.com/LacusSolutions/br-utils-ruby/blob/main/packages/cnpj-dv/README.pt.md)

A Ruby utility to calculate check digits on CNPJ (Brazilian Business Tax ID).

## Ruby Support


| Ruby 3.2  | Ruby 3.3  | Ruby 3.4  |
| --------- | --------- | --------- |
| Passing ✔ | Passing ✔ | Passing ✔ |




## Features

- ✅ **Alphanumeric CNPJ**: Full support for the new alphanumeric CNPJ format (introduced in 2026)
- ✅ **Flexible input**: Accepts `String` or `Array` of strings
- ✅ **Format agnostic**: Strips non-alphanumeric characters from string input and uppercases letters
- ✅ **Auto-expansion**: Multi-character strings in arrays are joined and parsed like a single string
- ✅ **Input validation**: Rejects ineligible CNPJs (all-zero base ID `00000000`, all-zero branch `0000`, or 12 numeric-only repeated digits)
- ✅ **Lazy evaluation**: Check digits are calculated only when accessed (via methods)
- ✅ **Caching**: Calculated values are cached for subsequent access
- ✅ **Minimal dependencies**: Only `[lacus-utils](https://rubygems.org/gems/lacus-utils)`
- ✅ **Error handling**: Specific types for type, length, and invalid CNPJ scenarios (`TypeError` vs `StandardError` semantics)



## Installation

Install the gem directly:

```bash
gem install cnpj-dv
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'cnpj-dv'
```



## Require

```ruby
require 'cnpj-dv'
```



## Quick Start

```ruby
require 'cnpj-dv'

check_digits = CnpjDV::CnpjCheckDigits.new('914157320007')

check_digits.first   # => '9'
check_digits.second  # => '3'
check_digits.both    # => '93'
check_digits.cnpj    # => '91415732000793'
```

With alphanumeric CNPJ (new format):

```ruby
require 'cnpj-dv'

check_digits = CnpjDV::CnpjCheckDigits.new('MGKGMJ9X0001')

check_digits.first   # => '6'
check_digits.second  # => '8'
check_digits.both    # => '68'
check_digits.cnpj    # => 'MGKGMJ9X000168'
```



## Usage

The main resource of this package is the class `CnpjDV::CnpjCheckDigits`. Through an instance, you access CNPJ check-digit information:

- `initialize`: `CnpjDV::CnpjCheckDigits.new(cnpj_input)` — `cnpj_input` must be a `String` or an `Array` of strings. After sanitization, the value must have 12–14 alphanumeric characters (formatting stripped from strings; letters uppercased). Only the **first 12** characters are used as the base; if you pass 13 or 14 characters (e.g. a full CNPJ including prior check digits), characters 13–14 are **ignored** and the digits are recalculated. There are **no options**, keyword arguments, or configuration objects — the constructor takes only the CNPJ input.
- `first`: First check digit (13th character of the full CNPJ). Lazy, cached.
- `second`: Second check digit (14th character of the full CNPJ). Lazy, cached.
- `both`: Both check digits concatenated as a string.
- `cnpj`: The complete CNPJ as a string of 14 characters (12 base characters + 2 check digits).



### Input formats

The `CnpjCheckDigits` class accepts multiple input formats:

**String input:** raw digits and/or letters, or formatted CNPJ (e.g. `91.415.732/0007-93`, `MG.KGM.J9X/0001-68`). Non-alphanumeric characters are removed; lowercase letters are uppercased.

**Array of strings:** each element must be a string; values are concatenated and then parsed like a single string (e.g. `['9','1','4',…]`, `['9141','5732','0007']`, `['MG','KGM','J9X','0001']`). Non-string elements are not allowed.

```ruby
require 'cnpj-dv'

# String — plain, formatted, or with existing check digits (only first 12 chars used)
CnpjDV::CnpjCheckDigits.new('914157320007')
CnpjDV::CnpjCheckDigits.new('91.415.732/0007')
CnpjDV::CnpjCheckDigits.new('91415732000793')

# Array of strings — single- or multi-character elements
CnpjDV::CnpjCheckDigits.new(%w[9 1 4 1 5 7 3 2 0 0 0 7])
CnpjDV::CnpjCheckDigits.new(%w[9141 5732 0007])
CnpjDV::CnpjCheckDigits.new(%w[MG KGM J9X 0001])
```



### Errors & exceptions handling

This package uses **TypeError vs StandardError** semantics: *type errors* indicate incorrect API use (e.g. wrong type); *exceptions* indicate invalid or ineligible data (e.g. invalid length or business rules). You can rescue specific classes or use the base classes.

- `CnpjDV::CnpjCheckDigitsTypeError` — base class for type errors; extends Ruby’s `TypeError`
- `CnpjDV::CnpjCheckDigitsInputTypeError` — input is not `String` or `Array` of strings (or array contains a non-string element)
- `CnpjDV::CnpjCheckDigitsException` — base class for data/flow exceptions; extends `StandardError`
- `CnpjDV::CnpjCheckDigitsInputLengthException` — sanitized length is not 12–14
- `CnpjDV::CnpjCheckDigitsInputInvalidException` — base ID `00000000`, branch ID `0000`, or 12 identical numeric digits (repeated-digit pattern)

```ruby
require 'cnpj-dv'

# Input type (e.g. integer not allowed)
begin
  CnpjDV::CnpjCheckDigits.new(12_345_678_000_100)
rescue CnpjDV::CnpjCheckDigitsInputTypeError => e
  puts e.message
  # => CNPJ input must be of type string or string[]. Got integer number.
end

# Length (must be 12–14 alphanumeric characters after sanitization)
begin
  CnpjDV::CnpjCheckDigits.new('12345678901')
rescue CnpjDV::CnpjCheckDigitsInputLengthException => e
  puts e.message
  # => CNPJ input "12345678901" does not contain 12 to 14 characters. Got 11.
end

# Invalid (e.g. all-zero base or branch, or repeated numeric digits)
begin
  CnpjDV::CnpjCheckDigits.new('000000000001')
rescue CnpjDV::CnpjCheckDigitsInputInvalidException => e
  puts e.message
  # => CNPJ input "000000000001" is invalid. Base ID "00000000" is not eligible.
end

# Any data exception from the package
begin
  CnpjDV::CnpjCheckDigits.new('000000000001')
rescue CnpjDV::CnpjCheckDigitsException => e
  puts e.message
end
```

Notable attributes on raised errors:

- `CnpjCheckDigitsInputTypeError`: `actual_input`, `actual_type`, `expected_type`
- `CnpjCheckDigitsInputLengthException`: `actual_input`, `evaluated_input`, `min_expected_length`, `max_expected_length`
- `CnpjCheckDigitsInputInvalidException`: `actual_input`, `reason`



### Other available resources

After `require 'cnpj-dv'`:

- `CnpjDV::CNPJ_MIN_LENGTH`: `12`
- `CnpjDV::CNPJ_MAX_LENGTH`: `14`
- **Exceptions**: see above



## Calculation algorithm

The package computes check digits with the official Brazilian modulo-11 rules extended to alphanumeric characters:

1. **Character value:** each character contributes `ord(character) − 48` (so `0`–`9` stay 0–9; letters use their ASCII offset from `0`).
2. **Weights:** from **right to left**, multiply by weights that cycle **2, 3, 4, 5, 6, 7, 8, 9**, then repeat from 2.
3. **First check digit (13th position):** apply steps 1–2 to the first **12** base characters; let `r = sum % 11`. The digit is `0` if `r < 2`, otherwise `11 − r`.
4. **Second check digit (14th position):** apply steps 1–2 to the first 12 characters **plus** the first check digit; same formula for `r`.



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
