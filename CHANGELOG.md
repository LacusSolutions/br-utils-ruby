# cpf-fmt

## 1.0.0

### 🚀 Stable Version Released!

Utility module to format CPF (Brazilian individual taxpayer ID) strings. Main features:

- **Multiple interfaces**: supports `CpfFmt.cpf_fmt` and `CpfFmt::CpfFormatter` with shared `CpfFmt::CpfFormatterOptions` defaults; an `options` argument (instance or `Hash`) is never merged with keyword overrides — passing both at once raises `InvalidArgumentCombinationError`.
- **Numeric CPF**: formats 11-digit input; strips non-digits before delimiter insertion (`XXX.XXX.XXX-XX`).
- **Flexible input**: accepts a `String` or `Array<String>` and concatenates sequence items before sanitization.
- **Customizable output**: configurable `dot_key` and `dash_key` delimiters for flexible layouts.
- **Privacy masking**: `hidden`, `hidden_key`, `hidden_start`, and `hidden_end` mask sensitive digit ranges in the formatted string.
- **Post-format transforms**: optional `escape` (HTML) and `encode` (URL) applied after successful formatting.
- **Structured errors**: `CpfFmt::Error` marker with misuse leaves (`TypeMismatchError`, `InvalidArgumentCombinationError`), domain leaves (`InvalidLengthError`, `OutOfRangeError`, `ValidationError` under `DomainError`); `on_fail` receives `(original_input, DomainError)` (length failures pass `InvalidLengthError`).
- **Strict options merging**: `CpfFormatterOptions.new`/`#set` fold positional `Hash`/instance layers left to right, then apply keyword overrides with the highest precedence, filling any still-unresolved option with its `DEFAULT_*` value; property setters never accept `nil` directly — pass the matching `DEFAULT_*` constant (or use `#set_hidden_range`) to reset explicitly.

For detailed usage and API reference, see the [README](./README.md).
