# cpf-val

## 1.0.0

### 🚀 Stable Version Released!

Utility module to validate CPF (Brazilian personal ID) strings. Main features:

- **Multiple interfaces**: supports `CpfVal.cpf_val` and `CpfVal::CpfValidator#is_valid` with no options or keyword arguments.
- **Flexible input**: accepts a `String` or `Array<String>` (formatted or raw); non-digit characters are stripped before validation.
- **Strict validation**: requires exactly `CpfVal::CPF_LENGTH` (`11`) digits and matching check digits; repeated-digit bases return `false`.
- **Structured errors**: `CpfVal::Error` marker with misuse leaf `TypeMismatchError`; invalid CPF data returns `false` without raising.
- **Check-digit delegation**: validation uses `CpfDV::CpfCheckDigits` from `cpf-dv` for eligibility rules and verifier digits.
- **Constants**: `CpfVal::CPF_LENGTH` (`11`) for the required digit count after sanitization.
- **Dependencies**: runtime gems `cpf-dv` and `lacus-utils` (Ruby `>= 3.1`).

For detailed usage and API reference, see the [README](./README.md).
