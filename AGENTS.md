# AGENTS.md

This file is the **primary entry point** for AI agents working in the Ruby monorepo. Apply the rules below whenever designing, implementing, renaming, raising, constructing, rescuing, or documenting error classes in any package under `packages/*`.

---

## Error hierarchy standard

Follow these rules **exactly** when describing, categorizing, and documenting every error class a library raises or constructs for callbacks. Do not invent alternate hierarchies, mix categories, or skip required documentation sections.

### 1. Core principle

Every package must have **two distinguishable categories** of errors, and every abstract or concrete error class in the library must belong to **exactly one** of them:

| Category | Meaning |
|---|---|
| **API misuse errors** | The caller invoked the library incorrectly (wrong type, missing argument, invalid argument combination). These are contract violations, generally detectable without running business logic. |
| **Domain errors** | The call was structurally correct, but a value violates a business/domain rule (out-of-range number, invalid string/array length, invalid enum value, etc.). These are only detectable at runtime, against actual data. |

When documenting any raised or callback-delivered error, always state which of these two categories it belongs to and why.

### 2. Native superclass mapping

Every custom error class must inherit from the native Ruby exception class that matches its semantic meaning. Never invent a new base error without inheriting from one of these:

| Scenario | Required native superclass |
|---|---|
| Argument has the wrong data type | `TypeError` |
| Required argument was not provided | `ArgumentError` |
| Argument combination does not match the API's valid signatures (overload-style rules) | `ArgumentError` |
| Argument has a valid type but an invalid value per business rules (e.g., negative number, out-of-range value) | `RangeError` (via `DomainError`) |
| Invalid string/array/collection length | `RangeError` (via `DomainError`) |
| A domain rule that is not numeric or length-based (e.g., invalid enum, invalid format, forbidden characters) | `RangeError` (via `DomainError`), using a dedicated `ValidationError` subclass |

Never document or recommend `rescue Exception` or inheriting directly from `Exception`. All library errors must ultimately descend from `StandardError` through one of the native classes above.

Ruby has a single `Exception` hierarchy; "Error" is a naming convention, not a separate type system. Do not write as if "erro" and "exceção" were structurally distinct kinds of failures.

### 3. Required module marker for library-wide rescue

Every package must define a non-class module used purely as a marker, mixed into every library error via `include`, so consumers can do `rescue MyLib::Error` regardless of which native class each error inherits from:

```ruby
module MyLib
  module Error; end
end
```

Every custom error class must `include MyLib::Error` in addition to inheriting from its native superclass.

**Reason:** Ruby only supports single inheritance, so a marker module is how the library achieves both native-compatible rescue behavior and a library-wide rescue at the same time.

Replace `MyLib` with the package's public root namespace (e.g. `CnpjFmt`, `CnpjDV`).

### 4. Required intermediate class for domain errors

Every package must define an intermediate class that groups **all** domain/business-rule errors under one rescuable ancestor, separate from misuse errors:

```ruby
module MyLib
  class DomainError < RangeError
    include Error
  end
end
```

Rules:

- Every domain leaf (`OutOfRangeError`, `InvalidLengthError`, `ValidationError`, etc.) must inherit from `DomainError`, not directly from `RangeError` and not from `ArgumentError`.
- Misuse errors (`TypeError` / `ArgumentError`-based contract violations) must **not** inherit from `DomainError`.
- `ValidationError` is a **domain** leaf for non-numeric, non-length rule failures. It inherits from `DomainError` so `rescue MyLib::DomainError` covers length, range, and validation failures together. It is also rescuable via `MyLib::ValidationError`, `RangeError`, or `MyLib::Error`.

### 5. Naming conventions

- Misuse error class names must describe the **contract violation**, not the symptom: `TypeMismatchError`, `MissingArgumentError`, `InvalidArgumentCombinationError`.
- Domain error class names must describe the **violated rule**: `OutOfRangeError`, `InvalidLengthError`, `ValidationError`.
- Do not use generic names like `Error`, `Invalid`, or `Failure` for leaf classes — reserve unqualified `Error` for the root marker module only.

### 6. Catalog of standard leaves (define only what you use)

The following is the **catalog** of standard leaf names and inheritance. Packages must define `Error`, `DomainError` (when they have any domain leaf), and every leaf they **raise or construct** for a public API. Do **not** define unused skeleton leaves just for monorepo consistency — omit classes with no raise/construct surface (prefer the lean approach used by `cnpj-dv`).

```ruby
module MyLib
  module Error; end

  # --- API misuse (define only leaves the package actually raises) ---

  class TypeMismatchError < TypeError
    include Error
  end

  class MissingArgumentError < ArgumentError
    include Error
  end

  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end

  # --- Domain (all domain leaves inherit DomainError) ---

  class DomainError < RangeError
    include Error
  end

  class OutOfRangeError < DomainError; end

  class InvalidLengthError < DomainError; end

  class ValidationError < DomainError; end
end
```

Add further leaf classes only when a distinct failure mode needs its own rescue target; every new leaf must still follow sections 1–5.

### 7. Raised vs constructed (callback-delivered) errors

Most failures are **raised**. Some packages instead **construct** a domain error and pass it to a callback (e.g. `on_fail`) without raising from the public entry point.

Rules:

- Constructed errors still use the same hierarchy, naming, and marker rules as raised ones.
- Type the callback’s error argument as `DomainError` (the grouping ancestor), even when the concrete instance is a leaf such as `InvalidLengthError`.
- Document constructed errors with the same five-part entry shape, but state clearly that they are **not raised** from the entry point and show the callback signature / handling path instead of (or in addition to) a `rescue` example.
- Include constructed leaves in the summary table; note in the trigger column that they are passed to the callback.

### 8. Required documentation structure per error class

For every error class the library raises or constructs for a public callback, produce a documentation entry containing, **in this order**:

1. **Class name and full inheritance chain** (e.g., `MyLib::OutOfRangeError < MyLib::DomainError < RangeError`, includes `MyLib::Error`).
2. **Category** — `"API misuse"` or `"Domain error"`.
3. **When it is raised / constructed** — one sentence, concrete trigger condition (say which applies).
4. **Example** — a minimal code snippet showing the call that raises it, or the callback that receives it.
5. **How to rescue / handle it** — for raised errors, show at least two valid `rescue` clauses (leaf + broader ancestor). For constructed errors, show typical callback handling and optional `rescue` if the consumer re-raises.

Keep each error's trigger description to a **single, unambiguous sentence** — no compound conditions.

#### Template (fill per class)

Use this shape for every error class entry:

- Heading: `### \`MyLib::OutOfRangeError\``
- **Inheritance:** `MyLib::OutOfRangeError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — the call shape was valid, but a numeric value violated a domain range rule.
- **When it is raised:** Raised when a numeric argument falls outside the inclusive bounds accepted by the API.
- **Example:** a minimal Ruby snippet that triggers the raise (e.g. `MyLib.process(count: -1)`).
- **How to rescue it:** at least two `rescue` clauses — the leaf (`rescue MyLib::OutOfRangeError`) and a broader ancestor (`rescue MyLib::DomainError` or `rescue MyLib::Error` / native class).

### 9. Required per-class documentation (standard leaves)

Document every leaf the package raises or constructs. When a catalog leaf is used, use entries equivalent to the following (adapt examples to the package's real API; keep category/inheritance/rescue rules unchanged). Skip documentation for leaves the package does not define.

#### `MyLib::TypeMismatchError`

- **Inheritance:** `MyLib::TypeMismatchError < TypeError` (includes `MyLib::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when an argument's runtime type does not match the type required by the API contract.
- **Example:**

```ruby
MyLib.process("1") # raises MyLib::TypeMismatchError when an Integer is required
```

- **How to rescue it:**

```ruby
rescue MyLib::TypeMismatchError
  # this library's type-contract violation

rescue TypeError
  # native type errors, including this library's TypeMismatchError
```

#### `MyLib::MissingArgumentError`

- **Inheritance:** `MyLib::MissingArgumentError < ArgumentError` (includes `MyLib::Error`)
- **Category:** API misuse — a required argument was omitted.
- **When it is raised:** Raised when a required argument is not provided.
- **Example:**

```ruby
MyLib.process # raises MyLib::MissingArgumentError when a required keyword is omitted
```

- **How to rescue it:**

```ruby
rescue MyLib::MissingArgumentError
  # this library's missing-argument contract violation

rescue ArgumentError
  # native argument errors of this kind
```

#### `MyLib::InvalidArgumentCombinationError`

- **Inheritance:** `MyLib::InvalidArgumentCombinationError < ArgumentError` (includes `MyLib::Error`)
- **Category:** API misuse — the provided arguments do not form a valid API signature.
- **When it is raised:** Raised when the combination of provided arguments does not match any valid overload-style signature.
- **Example:**

```ruby
MyLib.process(a: 1, b: 2) # raises MyLib::InvalidArgumentCombinationError when a and b are mutually exclusive
```

- **How to rescue it:**

```ruby
rescue MyLib::InvalidArgumentCombinationError
  # this library's invalid signature combination

rescue MyLib::Error
  # any error raised by this library
```

#### `MyLib::OutOfRangeError`

- **Inheritance:** `MyLib::OutOfRangeError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — a numeric value violates a business range rule.
- **When it is raised:** Raised when a numeric argument is outside the inclusive range accepted by the domain rule.
- **Example:**

```ruby
MyLib.process(count: -1) # raises MyLib::OutOfRangeError
```

- **How to rescue it:**

```ruby
rescue MyLib::OutOfRangeError
  # this exact range violation

rescue MyLib::DomainError
  # all domain failures from this library
```

#### `MyLib::InvalidLengthError`

- **Inheritance:** `MyLib::InvalidLengthError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — a collection or string length violates a business rule.
- **When it is raised:** Raised when a string, array, or other collection has a length outside the bounds required by the domain rule. (If the package delivers length failures via callback instead, say so and document the callback path.)
- **Example (raised):**

```ruby
MyLib.process(digits: "12") # raises MyLib::InvalidLengthError when length must be 11
```

- **Example (callback-delivered):**

```ruby
MyLib.process(
  digits: "12",
  on_fail: ->(_value, error) {
    error # => #<MyLib::InvalidLengthError ...> (a DomainError)
    "invalid"
  }
)
```

- **How to rescue / handle it:**

```ruby
rescue MyLib::InvalidLengthError
  # this exact length violation

rescue MyLib::DomainError
  # all domain failures from this library
```

#### `MyLib::ValidationError`

- **Inheritance:** `MyLib::ValidationError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule (e.g., invalid enum, format, or forbidden characters).
- **When it is raised:** Raised when a value has a valid type and length but violates a domain validation rule that is not numeric-range or length-based.
- **Example:**

```ruby
MyLib.process(mode: :entropic) # raises MyLib::ValidationError when :entropic is not an allowed mode
```

- **How to rescue it:**

```ruby
rescue MyLib::ValidationError
  # this exact domain validation failure

rescue MyLib::DomainError
  # OutOfRangeError, InvalidLengthError, ValidationError, and other DomainError subclasses
```

Also document the intermediate ancestors consumers may rescue:

#### `MyLib::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises or constructs for callbacks.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue MyLib::Error
  # everything this library raises
```

#### `MyLib::DomainError`

- **Inheritance:** `MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — ancestor for **all** domain failures (length, range, validation, and any other domain leaves).
- **When it is raised:** Not raised directly unless a package documents a generic domain failure; prefer raising or constructing a leaf subclass.
- **Example:** Prefer `raise MyLib::OutOfRangeError` / `raise MyLib::ValidationError` / construct `InvalidLengthError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue MyLib::DomainError
  # OutOfRangeError, InvalidLengthError, ValidationError, and any other DomainError subclass
```

### 10. Required summary table

Include one consolidated table listing every error class in the library that is raised or constructed for a public callback, with columns: `Class`, `Inherits from`, `Category`, `Trigger condition`. Order rows by category (**misuse errors first**, **domain errors second**), then alphabetically within each category.

Example table covering the full catalog (include only rows for leaves the package actually defines):

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `MyLib::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Argument combination does not match a valid API signature |
| `MyLib::MissingArgumentError` | `ArgumentError` (+ `include Error`) | API misuse | Required argument was not provided |
| `MyLib::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | Argument has the wrong data type |
| `MyLib::InvalidLengthError` | `MyLib::DomainError` | Domain error | String/array/collection length violates a domain rule |
| `MyLib::OutOfRangeError` | `MyLib::DomainError` | Domain error | Numeric value is outside an accepted domain range |
| `MyLib::ValidationError` | `MyLib::DomainError` | Domain error | Value fails a non-numeric, non-length domain rule |

When documenting a package, also describe `MyLib::DomainError` in narrative docs as the domain grouping ancestor; leaf rows above are what the summary table must cover for raised or callback-delivered failure modes. Do not list unused catalog leaves that the package does not define.

### 11. Required "rescue granularity" section

Include a dedicated documentation section showing the four levels of granularity available to library consumers, using **real classes from the library** (not placeholders). Adapt the comments to the leaves the package actually defines:

```ruby
# 1) Single native class — catches misuse errors of that kind,
#    including non-library ones already handled elsewhere in the consumer's code.
rescue TypeError
  # MyLib::TypeMismatchError and any other TypeError (library or not)

# 2) MyLib::DomainError — catches all business-rule violations under DomainError
#    (length, range, validation, and other domain leaves).
rescue MyLib::DomainError
  # MyLib::OutOfRangeError, MyLib::InvalidLengthError, MyLib::ValidationError,
  # and other DomainError subclasses

# 3) MyLib::Error — catches everything the library raises, regardless of native ancestry.
rescue MyLib::Error
  # every custom error that includes MyLib::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue MyLib::OutOfRangeError
  # only MyLib::OutOfRangeError
```

Never recommend or document `rescue Exception` as a pattern for consumers.

### 12. Agent checklist

Before finishing any task that adds, changes, or documents errors:

1. Every custom error belongs to exactly one category: API misuse or domain.
2. Every custom error inherits from the correct native superclass per the mapping table.
3. Every custom error `include`s the package `Error` marker module.
4. Every domain leaf (including `ValidationError`) inherits from `DomainError`, not bare `RangeError` or `ArgumentError`.
5. Misuse errors do not inherit from `DomainError`.
6. Only define catalog leaves that the package raises or constructs; do not ship unused public error classes.
7. Callback-delivered failures type the error argument as `DomainError` and document the construct-and-pass path.
8. Leaf names follow the naming conventions; unqualified `Error` is only the marker module.
9. Each raised or constructed error has a five-part documentation entry (chain, category, when, example, rescue/handle).
10. A summary table exists with the required columns and ordering, listing only defined failure modes.
11. A rescue-granularity section exists with the four levels above, using real library classes.
12. No docs mention `rescue Exception` or inheriting from `Exception` directly.

---

## Aggregator package re-exports

Applies to aggregator gems such as `*-utilities` and `br-utilities` that load component packages and expose a unified façade.

### Shape

- One re-export file per component under `src/<agg-pkg>/<component_snake>.rb` (e.g. `src/cnpj-utilities/cnpj_fmt.rb`).
- Nest the full sibling module on the façade: `<Utils>::CnpjFmt = ::CnpjFmt` (same-object assignment only — no wrappers).
- Root shortcuts only for the three (or package-appropriate) **main classes** (e.g. `<Utils>::CnpjFormatter = CnpjFmt::CnpjFormatter`).
- Options, helpers, errors, and types stay under the nested module — **not** aliased at the `<Utils>` root.
- Root sibling modules (`CnpjFmt`, `CnpjGen`, `CnpjVal`, …) remain supported unchanged.
- Require the re-export files from the aggregator entrypoint **after** class/module promotion and **after** the façade implementation file.

### Default singleton + class helpers

When the façade mirrors a JS default export / Python module-level singleton:

- Expose a mutable constant `<Utils>::DEFAULT = new` (UPPERCASE names a constant binding, not an immutable value — do not freeze the instance).
- Add class-method aliases for each façade operation that forward to `DEFAULT` (e.g. `CnpjUtils.format` / `.generate` / `.is_valid`). Prefer these in end-user docs as the quick path.
- Mutating `DEFAULT` affects subsequent class-helper calls; `CnpjUtils.new` (custom) instances stay independent.
- Specs: helper existence, parity with `DEFAULT`, mutability coupling with restore, custom-instance independence.

### Reference

Shipped reference: `ruby/packages/cnpj-utilities` (`CnpjUtils::CnpjFmt` nest + `CnpjUtils::CnpjFormatter` shortcut; `DEFAULT` + class helpers).
