# cpf-gen

## 1.0.0

### 🚀 Stable Version Released!

Utility module to generate valid CPF (Brazilian personal ID) strings. Main features:

- **Multiple interfaces**: supports `CpfGen.cpf_gen` and `CpfGen::CpfGenerator` with shared `CpfGen::CpfGeneratorOptions` defaults; an `options` argument (instance or `Hash`) is never merged with keyword overrides — passing both at once raises `InvalidArgumentCombinationError`.
- **Numeric CPF**: generates 11-digit numeric identifiers; random body is always digits (`0-9`).
- **Prefix support**: partial start strings are sanitized (digits only, truncated to 9) and validated — rejects zeroed base ID and 9 repeated digits via `ValidationError`; only missing digits up to 9 are randomly generated.
- **Optional formatting**: `format: true` returns the standard masked `XXX.XXX.XXX-XX` layout; default output is unformatted.
- **Strict options merging**: `CpfGeneratorOptions.new`/`#set` fold positional `Hash`/instance layers left to right, then apply keyword overrides with the highest precedence, filling any still-unresolved option with its `DEFAULT_*` value; property setters (`format=`, `prefix=`) never accept `nil` directly — pass the matching `DEFAULT_*` constant to reset explicitly.
- **Structured errors**: `CpfGen::Error` marker with misuse leaves (`TypeMismatchError`, `InvalidArgumentCombinationError`) and domain leaf (`ValidationError` under `DomainError`).
- **Check digits**: computed via `cpf-dv`; generator retries when check-digit computation rejects a random body candidate.

For detailed usage and API reference, see the [README](./README.md).
