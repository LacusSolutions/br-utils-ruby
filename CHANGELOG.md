# cnpj-utilities

## 1.0.0

### 🚀 Stable Version Released!

Unified toolkit to deal with CNPJ (Brazilian legal entity ID): formatting, generation, and validation. Main features:

- **Unified façade**: `CnpjUtils` delegates `#format`, `#generate`, and `#is_valid` to `cnpj-fmt`, `cnpj-gen`, and `cnpj-val`.
- **Alphanumeric CNPJ**: full support for the [14-character alphanumeric CNPJ](https://www.gov.br/receitafederal/pt-br/assuntos/noticias/2023/julho/cnpj-alfa-numerico); generate with `type` `"numeric"`, `"alphabetic"`, or `"alphanumeric"`.
- **Quick helpers**: `CnpjUtils.format` / `.generate` / `.is_valid` alias mutable `CnpjUtils::DEFAULT`.
- **Two-tier re-exports**: `CnpjUtils::CnpjFormatter` / `CnpjGenerator` / `CnpjValidator` at the façade root; full sibling surface under `CnpjUtils::CnpjFmt` / `CnpjGen` / `CnpjVal`.
- **Configurable components**: constructor and setters accept component instances, `*Options`, `Hash`, or `nil`; accessors expose `formatter`, `generator`, and `validator`.
- **Per-call overrides**: `#format`, `#generate`, and `#is_valid` accept an options `Hash`/instance or keyword overrides (not both).
- **Root siblings**: after `require 'cnpj-utilities'`, `CnpjFmt`, `CnpjGen`, and `CnpjVal` remain loadable (same objects as the nests).
- **Structured errors**: component exceptions propagate unchanged; `CnpjUtils::InvalidArgumentCombinationError` covers settings/options vs keyword misuse.

For detailed usage and API reference, see the [README](./README.md).
