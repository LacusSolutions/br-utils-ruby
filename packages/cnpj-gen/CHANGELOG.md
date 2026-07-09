# cnpj-gen

## 1.0.0

### 🚀 Stable Version Released!

Utility module to generate valid CNPJ (Brazilian legal entity ID) strings. Main features:

- **Multiple interfaces**: supports `CnpjGen.cnpj_gen` and `CnpjGen::CnpjGenerator` with shared `CnpjGen::CnpjGeneratorOptions` defaults and keyword overrides on `generate`.
- **Alphanumeric CNPJ**: generates 14-character alphanumeric identifiers (`0-9A-Z`) aligned with the new [14-character alphanumeric CNPJ](https://www.gov.br/receitafederal/pt-br/assuntos/noticias/2023/julho/cnpj-alfa-numerico); optional `numeric` or `alphabetic` via the `type` option.
- **`type` option**: controls character set for randomly generated segments (`numeric`, `alphabetic`, or `alphanumeric`, default `alphanumeric`).
- **Prefix support**: partial start strings are sanitized (alphanumeric only, uppercased) and validated; only missing characters up to 12 are randomly generated.
- **Optional formatting**: `format: true` returns the standard masked `XX.XXX.XXX/XXXX-XX` layout; default output is unformatted.
- **Prefix validation**: rejects zeroed base ID, zeroed branch ID, and 12 repeated digits via `CnpjGeneratorOptionPrefixInvalidException`.
- **Structured errors**: `CnpjGeneratorTypeError` / `CnpjGeneratorException` hierarchies for option type and business-rule failures.
- **Check digits**: computed via `cnpj-dv`; generator retries when check-digit computation rejects a random body candidate.

For detailed usage and API reference, see the [README](./README.md).
