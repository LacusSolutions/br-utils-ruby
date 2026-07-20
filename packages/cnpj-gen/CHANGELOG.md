# cnpj-gen

## 1.0.0

### 🚀 Stable Version Released!

Utility module to generate valid CNPJ (Brazilian legal entity ID) strings. Main features:

- **Multiple interfaces**: supports `CnpjGen.cnpj_gen` and `CnpjGen::CnpjGenerator` with shared `CnpjGen::CnpjGeneratorOptions` defaults; an `options` argument (instance or `Hash`) is never merged with keyword overrides — passing both at once raises `InvalidArgumentCombinationError`.
- **Alphanumeric CNPJ**: generates 14-character alphanumeric identifiers (`0-9A-Z`) aligned with the new [14-character alphanumeric CNPJ](https://www.gov.br/receitafederal/pt-br/assuntos/noticias/2023/julho/cnpj-alfa-numerico); optional `numeric` or `alphabetic` via the `type` option.
- **`type` option**: controls character set for randomly generated segments (`numeric`, `alphabetic`, or `alphanumeric`, default `alphanumeric`).
- **Prefix support**: partial start strings are sanitized (alphanumeric only, uppercased) and validated — rejects zeroed base ID, zeroed branch ID, and 12 repeated digits via `ValidationError`; only missing characters up to 12 are randomly generated.
- **Optional formatting**: `format: true` returns the standard masked `XX.XXX.XXX/XXXX-XX` layout; default output is unformatted.
- **Strict options merging**: `CnpjGeneratorOptions.new`/`#set` fold positional `Hash`/instance layers left to right, then apply keyword overrides with the highest precedence, filling any still-unresolved option with its `DEFAULT_*` value; property setters (`format=`, `prefix=`, `type=`) never accept `nil` directly — pass the matching `DEFAULT_*` constant to reset explicitly.
- **Structured errors**: `CnpjGen::Error` marker with misuse leaves (`TypeMismatchError`, `InvalidArgumentCombinationError`) and domain leaf (`ValidationError` under `DomainError`).
- **Check digits**: computed via `cnpj-dv`; generator retries when check-digit computation rejects a random body candidate.

For detailed usage and API reference, see the [README](./README.md).
