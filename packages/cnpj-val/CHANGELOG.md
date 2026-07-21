# cnpj-val

## 1.0.0

### 🚀 Stable Version Released!

Utility module to validate CNPJ (Brazilian legal entity ID) strings. Main features:

- **Multiple interfaces**: supports `CnpjVal.cnpj_val` and `CnpjVal::CnpjValidator` with shared `CnpjVal::CnpjValidatorOptions` defaults; an `options` argument (instance or `Hash`) is never merged with keyword overrides — passing both at once raises `InvalidArgumentCombinationError`.
- **Alphanumeric CNPJ**: validates the [14-character alphanumeric CNPJ](https://www.gov.br/receitafederal/pt-br/assuntos/noticias/2023/julho/cnpj-alfa-numerico) (digits and `A–Z`); default `type` is `"alphanumeric"`, with optional `"numeric"` for digits-only.
- **Flexible input**: accepts a `String` or `Array<String>` (formatted or raw); non-significant characters are stripped per `type`.
- **`type` and `case_sensitive` options**: control character set and whether lowercase letters are accepted on alphanumeric input.
- **Structured errors**: `CnpjVal::Error` marker with misuse leaves (`TypeMismatchError`, `InvalidArgumentCombinationError`) and domain leaf (`ValidationError` under `DomainError`); invalid CNPJ data returns `false`.
- **Check-digit delegation**: validation uses `CnpjDV::CnpjCheckDigits` from `cnpj-dv` for eligibility rules and verifier digits.
- **Keyword options**: `case_sensitive:` and `type:` overrides on `CnpjVal.cnpj_val`, `CnpjValidator#initialize`, and `#is_valid` (mutually exclusive with an `options` argument).
- **Constants**: `CnpjVal::CNPJ_LENGTH` and `CnpjValidatorOptions::DEFAULT_CASE_SENSITIVE` / `DEFAULT_TYPE`.

For detailed usage and API reference, see the [README](./README.md).
