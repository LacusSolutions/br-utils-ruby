# lacus-utils

## 1.1.0

### Improvements

- **Ruby 3.1**: minimum supported version lowered from `3.2` to `3.1`.

## 1.0.0

### 🚀 Stable Version Released!

Initial release of `lacus-utils` on RubyGems: general-purpose utilities for Lacus Solutions' Ruby packages. Main features:

- **Type description**: `LacusUtils.describe_type` returns Ruby-native type labels (`nil`, `hash`, `symbol`, `integer number`, and array notation like `number[]` or `(number | string)[]`).
- **Random sequences**: `LacusUtils.generate_random_sequence` draws `:numeric`, `:alphabetic`, or `:alphanumeric` strings from a cryptographically secure `SecureRandom` RNG.
- **Strict validation**: `generate_random_sequence` raises `ArgumentError` on a negative `size` or an unknown `type`.
- **Zero dependencies**: no external runtime gems required; targets Ruby `3.2`.

For detailed usage and API reference, see the [README](./README.md).
