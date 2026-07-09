# cnpj-fmt

## 1.0.0

### 🚀 Stable Version Released!

Utility module to format CNPJ (Brazilian legal entity ID) strings. Main features:

- **Multiple interfaces**: supports `CnpjFmt.cnpj_fmt` and `CnpjFmt::CnpjFormatter` with shared `CnpjFmt::CnpjFormatterOptions` defaults.
- **Alphanumeric CNPJ**: formats 14-character alphanumeric input (digits and `A–Z`); strips punctuation and uppercases letters before delimiter insertion.
- **Flexible input**: accepts a `String` or `Array<String>` and concatenates sequence items before sanitization.
- **Customizable output**: configurable `dot_key`, `slash_key`, and `dash_key` delimiters for flexible `XX.XXX.XXX/XXXX-XX` layouts.
- **Privacy masking**: `hidden`, `hidden_key`, `hidden_start`, and `hidden_end` mask sensitive character ranges in the formatted string.
- **Post-format transforms**: optional `escape` (HTML) and `encode` (URL) applied after successful formatting.
- **Structured errors**: `CnpjFormatterTypeError` / `CnpjFormatterException` hierarchies plus configurable `on_fail` callback for invalid length.
- **Options API**: `CnpjFormatterOptions#set`, `#set_hidden_range`, `#copy`, and `#all` for instance defaults and per-call overrides via `Hash` or keywords.

For detailed usage and API reference, see the [README](./README.md).
