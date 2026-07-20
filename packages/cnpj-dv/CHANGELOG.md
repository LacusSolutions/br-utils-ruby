# cnpj-dv

## 2.0.0

### 🎉 v2 at a glance 🎊

- **Error hierarchy**: Aligns with the monorepo standard — API misuse vs domain errors, `CnpjDV::Error` marker, and native-compatible rescue.

### BREAKING CHANGES

- **Error classes**: Removed `CnpjCheckDigitsTypeError`, `CnpjCheckDigitsInputTypeError`, `CnpjCheckDigitsException`, `CnpjCheckDigitsInputLengthException`, and `CnpjCheckDigitsInputInvalidException`.
- **Migration map**: `InputTypeError` → `TypeMismatchError`; `InputLengthException` → `InvalidLengthError`; `InputInvalidException` → `ValidationError`.
- **Rescue targets**: `rescue CnpjCheckDigitsException` no longer applies; use `rescue CnpjDV::Error` for a library-wide catch, or `rescue DomainError` for `InvalidLengthError` and `ValidationError`.
- **Docs**: READMEs now document misuse vs domain categories, per-class rescue guidance, and four rescue granularity levels — see [README](./README.md).

## 1.0.0

### 🚀 Stable Version Released!

Utility class to calculate check digits on CNPJ (Brazilian Business Tax ID). Main features:

- **Flexible input**: Accepts a `String` or `Array` of strings (formatted or raw).
- **Format agnostic**: Automatically strips non-alphanumeric characters and uppercases letters before processing.
- **Alphanumeric CNPJ**: Supports letters `A–Z` in the base; check digits remain numeric via modulo-11.
- **Lazy evaluation**: `CnpjDV::CnpjCheckDigits` computes `first`, `second`, `both`, and `cnpj` only on first access, then caches.
- **Eligibility gates**: Rejects wrong types, invalid length, all-zero base/branch IDs, and repeated numeric digits.
- **Error handling**: `CnpjCheckDigitsInputTypeError` (`TypeError`) plus length/invalid `StandardError` subclasses with structured attributes.
- **Minimal dependencies**: Requires `lacus-utils` for reusable utilities.

For detailed usage and API reference, see the [README](./README.md).
