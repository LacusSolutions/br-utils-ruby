# cpf-utilities

## 1.0.0

### 🚀 Stable Version Released!

Unified toolkit to deal with CPF (Brazilian personal tax ID): formatting, generation, and validation. Main features:

- **Unified façade**: `CpfUtils` delegates `#format`, `#generate`, and `#is_valid` to `cpf-fmt`, `cpf-gen`, and `cpf-val`.
- **Numeric CPF**: digits-only 11-character IDs formatted as `XXX.XXX.XXX-XX` (no alphanumeric / `slash_key` / `type` options).
- **Quick helpers**: `CpfUtils.format` / `.generate` / `.is_valid` alias mutable `CpfUtils::DEFAULT`.
- **Two-tier re-exports**: `CpfUtils::CpfFormatter` / `CpfGenerator` / `CpfValidator` at the façade root; full sibling surface under `CpfUtils::CpfFmt` / `CpfGen` / `CpfVal`.
- **Configurable components**: constructor and setters accept component instances, `*Options`/`Hash` (formatter/generator), or `nil`; validator is instance/`nil`/duck-type only (no `CpfValidatorOptions`).
- **Per-call overrides**: `#format` and `#generate` accept an options `Hash`/instance or keyword overrides (not both); `#is_valid` takes input only.
- **Root siblings**: after `require 'cpf-utilities'`, `CpfFmt`, `CpfGen`, and `CpfVal` remain loadable (same objects as the nests).
- **Structured errors**: `CpfUtils::TypeMismatchError` / `InvalidArgumentCombinationError` (+ `CpfUtils::Error` marker); only `nil` means omitted for settings/options (e.g. `false` raises).

For detailed usage and API reference, see the [README](./README.md).
