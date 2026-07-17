# AGENTS.md

This file is the **primary entry point** for AI agents working in the Ruby monorepo. Apply the rules below whenever designing, implementing, renaming, raising, rescuing, or documenting error classes in any package under `packages/*`.

---

## Error hierarchy standard

Follow these rules **exactly** when describing, categorizing, and documenting every error class a library raises. Do not invent alternate hierarchies, mix categories, or skip required documentation sections.

### 1. Core principle

Every package must have **two distinguishable categories** of errors, and every abstract or concrete error class in the library must belong to **exactly one** of them:

| Category | Meaning |
|---|---|
| **API misuse errors** | The caller invoked the library incorrectly (wrong type, missing argument, invalid argument combination). These are contract violations, generally detectable without running business logic. |
| **Domain errors** | The call was structurally correct, but a value violates a business/domain rule (out-of-range number, invalid string/array length, invalid enum value, etc.). These are only detectable at runtime, against actual data. |

When documenting any raised error, always state which of these two categories it belongs to and why.

### 2. Native superclass mapping

Every custom error class must inherit from the native Ruby exception class that matches its semantic meaning. Never invent a new base error without inheriting from one of these:

| Scenario | Required native superclass |
|---|---|
| Argument has the wrong data type | `TypeError` |
| Required argument was not provided | `ArgumentError` |
| Argument combination does not match the API's valid signatures (overload-style rules) | `ArgumentError` |
| Argument has a valid type but an invalid value per business rules (e.g., negative number, out-of-range value) | `RangeError` |
| Invalid string/array/collection length | `RangeError` |
| A domain rule that is not numeric or length-based (e.g., invalid enum, invalid format) | `ArgumentError`, using a dedicated `ValidationError` subclass — do not force it into `RangeError` |

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

Replace `MyLib` with the package's public root namespace (e.g. `CnpjFmt`, `CpfDV`).

### 4. Required intermediate class for domain errors

Every package must define an intermediate class that groups all domain/business-rule errors under one rescuable ancestor, separate from misuse errors:

```ruby
module MyLib
  class DomainError < RangeError
    include Error
  end
end
```

Rules:

- All domain-error subclasses that are numeric or length-based (`OutOfRangeError`, `InvalidLengthError`, etc.) must inherit from `DomainError`, not directly from `RangeError`.
- Misuse errors (`TypeError` / `ArgumentError`-based contract violations) must **not** inherit from `DomainError`.
- Non-numeric, non-length domain failures use a dedicated `ValidationError < ArgumentError` that `include`s `Error`. Categorize and document `ValidationError` as a **domain error**, not API misuse. It is rescued via `MyLib::ValidationError`, `ArgumentError`, or `MyLib::Error` — not via `MyLib::DomainError` (Ruby single inheritance: `DomainError` remains `RangeError`-rooted).

### 5. Naming conventions

- Misuse error class names must describe the **contract violation**, not the symptom: `TypeMismatchError`, `MissingArgumentError`, `InvalidArgumentCombinationError`.
- Domain error class names must describe the **violated rule**: `OutOfRangeError`, `InvalidLengthError`, `ValidationError`.
- Do not use generic names like `Error`, `Invalid`, or `Failure` for leaf classes — reserve unqualified `Error` for the root marker module only.

### 6. Required skeleton (all packages)

Unless a package has no public raise surface yet, implement at least this skeleton (rename `MyLib` to the package namespace):

```ruby
module MyLib
  module Error; end

  class TypeMismatchError < TypeError
    include Error
  end

  class MissingArgumentError < ArgumentError
    include Error
  end

  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end

  class DomainError < RangeError
    include Error
  end

  class OutOfRangeError < DomainError; end

  class InvalidLengthError < DomainError; end

  class ValidationError < ArgumentError
    include Error
  end
end
```

Add further leaf classes only when a distinct failure mode needs its own rescue target; every new leaf must still follow sections 1–5.

### 7. Required documentation structure per error class

For every error class the library raises, produce a documentation entry containing, **in this order**:

1. **Class name and full inheritance chain** (e.g., `MyLib::OutOfRangeError < MyLib::DomainError < RangeError`, includes `MyLib::Error`).
2. **Category** — `"API misuse"` or `"Domain error"`.
3. **When it is raised** — one sentence, concrete trigger condition.
4. **Example** — a minimal code snippet showing the call that raises it.
5. **How to rescue it** — show at least two valid `rescue` clauses: the most specific class, and one broader ancestor (native class or `MyLib::Error` / `MyLib::DomainError`) relevant to that error.

Keep each error's "when it is raised" description to a **single, unambiguous sentence** — no compound conditions.

#### Template (fill per class)

Use this shape for every error class entry:

- Heading: `### \`MyLib::OutOfRangeError\``
- **Inheritance:** `MyLib::OutOfRangeError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — the call shape was valid, but a numeric value violated a domain range rule.
- **When it is raised:** Raised when a numeric argument falls outside the inclusive bounds accepted by the API.
- **Example:** a minimal Ruby snippet that triggers the raise (e.g. `MyLib.process(count: -1)`).
- **How to rescue it:** at least two `rescue` clauses — the leaf (`rescue MyLib::OutOfRangeError`) and a broader ancestor (`rescue MyLib::DomainError` or `rescue MyLib::Error` / native class).

### 8. Required per-class documentation (standard leaves)

Document every leaf the package raises. For the standard skeleton, use entries equivalent to the following (adapt examples to the package's real API; keep category/inheritance/rescue rules unchanged).

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
  # RangeError-rooted domain failures from this library
```

#### `MyLib::InvalidLengthError`

- **Inheritance:** `MyLib::InvalidLengthError < MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — a collection or string length violates a business rule.
- **When it is raised:** Raised when a string, array, or other collection has a length outside the bounds required by the domain rule.
- **Example:**

```ruby
MyLib.process(digits: "12") # raises MyLib::InvalidLengthError when length must be 11
```

- **How to rescue it:**

```ruby
rescue MyLib::InvalidLengthError
  # this exact length violation

rescue RangeError
  # native range errors, including DomainError descendants
```

#### `MyLib::ValidationError`

- **Inheritance:** `MyLib::ValidationError < ArgumentError` (includes `MyLib::Error`)
- **Category:** Domain error — a value fails a non-numeric, non-length domain rule (e.g., invalid enum or format).
- **When it is raised:** Raised when a value has a valid type and length but violates a domain validation rule that is not numeric-range or length-based.
- **Example:**

```ruby
MyLib.process(mode: :entropic) # raises MyLib::ValidationError when :entropic is not an allowed mode
```

- **How to rescue it:**

```ruby
rescue MyLib::ValidationError
  # this exact domain validation failure

rescue MyLib::Error
  # any error raised by this library
```

Also document the intermediate ancestors consumers may rescue:

#### `MyLib::Error` (marker module)

- **Inheritance:** module marker mixed into every library error via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error the library raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue MyLib::Error
  # everything this library raises
```

#### `MyLib::DomainError`

- **Inheritance:** `MyLib::DomainError < RangeError` (includes `MyLib::Error`)
- **Category:** Domain error — ancestor for numeric/length domain failures.
- **When it is raised:** Not raised directly unless a package documents a generic domain failure; prefer raising a leaf subclass.
- **Example:** Prefer `raise MyLib::OutOfRangeError` / `raise MyLib::InvalidLengthError` over raising `DomainError` directly.
- **How to rescue it:**

```ruby
rescue MyLib::DomainError
  # OutOfRangeError, InvalidLengthError, and any other DomainError subclass
```

### 9. Required summary table

Include one consolidated table listing every error class in the library with columns: `Class`, `Inherits from`, `Category`, `Trigger condition`. Order rows by category (**misuse errors first**, **domain errors second**), then alphabetically within each category.

Standard skeleton table (adapt class prefixes to the package namespace; keep columns and ordering rules):

| Class | Inherits from | Category | Trigger condition |
|---|---|---|---|
| `MyLib::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | API misuse | Argument combination does not match a valid API signature |
| `MyLib::MissingArgumentError` | `ArgumentError` (+ `include Error`) | API misuse | Required argument was not provided |
| `MyLib::TypeMismatchError` | `TypeError` (+ `include Error`) | API misuse | Argument has the wrong data type |
| `MyLib::InvalidLengthError` | `MyLib::DomainError` | Domain error | String/array/collection length violates a domain rule |
| `MyLib::OutOfRangeError` | `MyLib::DomainError` | Domain error | Numeric value is outside an accepted domain range |
| `MyLib::ValidationError` | `ArgumentError` (+ `include Error`) | Domain error | Value fails a non-numeric, non-length domain rule |

When documenting a package, also list `MyLib::DomainError` in narrative docs as the domain grouping ancestor; leaf rows above are what the summary table must cover for raised failure modes.

### 10. Required "rescue granularity" section

Include a dedicated documentation section showing the four levels of granularity available to library consumers, using **real classes from the library** (not placeholders). For the standard skeleton:

```ruby
# 1) Single native class — catches all misuse errors of that kind,
#    including non-library ones already handled elsewhere in the consumer's code.
rescue ArgumentError
  # MyLib::MissingArgumentError, MyLib::InvalidArgumentCombinationError,
  # and any other ArgumentError (library or not)
  # Note: also catches MyLib::ValidationError because it inherits ArgumentError

# 2) MyLib::DomainError — catches only business-rule violations under DomainError.
rescue MyLib::DomainError
  # MyLib::OutOfRangeError, MyLib::InvalidLengthError, and other DomainError subclasses

# 3) MyLib::Error — catches everything the library raises, regardless of native ancestry.
rescue MyLib::Error
  # every custom error that includes MyLib::Error

# 4) Specific leaf class — catches only that exact failure mode.
rescue MyLib::OutOfRangeError
  # only MyLib::OutOfRangeError
```

Never recommend or document `rescue Exception` as a pattern for consumers.

### 11. Agent checklist

Before finishing any task that adds, changes, or documents errors:

1. Every custom error belongs to exactly one category: API misuse or domain.
2. Every custom error inherits from the correct native superclass per the mapping table.
3. Every custom error `include`s the package `Error` marker module.
4. Numeric/length domain leaves inherit from `DomainError`, not bare `RangeError`.
5. Misuse errors do not inherit from `DomainError`.
6. Leaf names follow the naming conventions; unqualified `Error` is only the marker module.
7. Each raised error has a five-part documentation entry (chain, category, when, example, rescue).
8. A summary table exists with the required columns and ordering.
9. A rescue-granularity section exists with the four levels above, using real library classes.
10. No docs mention `rescue Exception` or inheriting from `Exception` directly.
