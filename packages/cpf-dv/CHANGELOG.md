# cpf-dv

## 1.0.0

### 🚀 Stable Version Released!

Utility class to calculate check digits on CPF (Brazilian Individual Tax ID). Main features:

- **Flexible input**: Accepts a `String` or `Array` of strings (formatted or raw).
- **Format agnostic**: Automatically strips non-digit characters before processing.
- **Lazy evaluation**: `CpfDV::CpfCheckDigits` computes `first`, `second`, `both`, and `cpf` only on first access, then caches.
- **Eligibility gates**: Rejects wrong types, invalid length (not 9–11 digits), and repeated base digits.
- **Error handling**: Lean catalog with `CpfDV::Error` marker, `TypeMismatchError` (`TypeError`), plus `InvalidLengthError` / `ValidationError` under `DomainError`.
- **Minimal dependencies**: Requires `lacus-utils` for reusable utilities.

For detailed usage and API reference, see the [README](./README.md).
