# cnpj-fmt

## 1.0.0

### 🚀 Stable Version Released!

Utility module to format CNPJ (Brazilian legal entity ID) strings. Main features:

- **Multiple interfaces**: supports `CnpjFmt.cnpj_fmt` and `CnpjFmt::CnpjFormatter` with shared `CnpjFmt::CnpjFormatterOptions` defaults; an `options` argument (instance or `Hash`) is never merged with keyword overrides — passing both at once raises `InvalidArgumentCombinationError`.
- **Alphanumeric CNPJ**: formats 14-character alphanumeric input (digits and `A–Z`); strips punctuation and uppercases letters before delimiter insertion.
- **Flexible input**: accepts a `String` or `Array<String>` and concatenates sequence items before sanitization.
- **Customizable output**: configurable `dot_key`, `slash_key`, and `dash_key` delimiters for flexible `XX.XXX.XXX/XXXX-XX` layouts.
- **Privacy masking**: `hidden`, `hidden_key`, `hidden_start`, and `hidden_end` mask sensitive character ranges in the formatted string.
- **Post-format transforms**: optional `escape` (HTML) and `encode` (URL) applied after successful formatting.
- **Structured errors**: `CnpjFmt::Error` marker with misuse leaves (`TypeMismatchError`, `InvalidArgumentCombinationError`), domain leaves (`InvalidLengthError`, `OutOfRangeError`, `ValidationError` under `DomainError`); `on_fail` receives `(original_input, DomainError)` (length failures pass `InvalidLengthError`).
- **Strict options merging**: `CnpjFormatterOptions.new`/`#set` fold positional `Hash`/instance layers left to right, then apply keyword overrides with the highest precedence, filling any still-unresolved option with its `DEFAULT_*` value; property setters never accept `nil` directly — pass the matching `DEFAULT_*` constant (or use `#set_hidden_range`) to reset explicitly.

For detailed usage and API reference, see the [README](./README.md).
