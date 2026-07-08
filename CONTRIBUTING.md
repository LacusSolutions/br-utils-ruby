# Contributing to `br-utils`

Thank you for your interest in contributing to this initiative! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contributing Guidelines](#contributing-guidelines)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style](#code-style)
- [Changelog](#changelog)
- [Releasing](#releasing)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Feature Requests](#feature-requests)

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please be respectful, inclusive, and constructive in all interactions.

## Getting Started

Before contributing, please:

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Set up the development environment** (see [Development Setup](#development-setup))
4. **Create a feature branch** for your changes
5. **Make your changes** following our guidelines
6. **Test your changes** thoroughly (see [Development Workflow](#development-workflow))
7. **Submit a pull request**

## Development Setup

### Prerequisites

- **Ruby** 3.2 or higher (minimum version enforced by `.ruby-version`, all gemspecs, and CI)
- **Bundler** — for dependency management
- **Git** — for version control

All commands below assume your shell is in the `ruby/` subrepo root (the directory that contains `Rakefile`, `Gemfile`, `config/`, and `packages/`).

### Installation

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/br-utils-ruby.git
cd br-utils-ruby/ruby

# Install root dev tooling (Rake, RuboCop, RSpec)
bundle install

# Enable the git hooks (pre-commit, pre-push, commit-msg)
rake hooks:install

# Verify the dependency graph is acyclic
rake monorepo:check_cycles

# Install and test one package
cd packages/cpf-dv && bundle install && bundle exec rake test
```

The **root** `Gemfile` carries tooling only (Rake, RuboCop, RSpec). Each package under `packages/<pkg>/` has its own `Gemfile` and is installed and tested independently.

### Rake commands

Run these from the subrepo root:

```bash
# Monorepo integrity
rake                          # Default: check for dependency cycles
rake monorepo:check_cycles    # Verify the config/gems.yml DAG (topological sort)
rake monorepo:order           # List gems in build order (leaves first)
rake monorepo:each[test]      # Run `rake test` in each package, in build order

# Linting and formatting
rake lint                     # Run RuboCop across the monorepo
rake format                   # Auto-correct safe RuboCop offenses (rubocop -a)
rake lint:autocorrect_all     # Auto-correct all offenses, including unsafe (rubocop -A)
rake lint:commits             # Lint commits in origin/main..HEAD (override with COMMIT_RANGE)

# Git hooks
rake hooks:install            # Point core.hooksPath at .githooks (enables all three hooks)
rake hooks:uninstall          # Unset the core.hooksPath override
```

From a package directory (`packages/<pkg>/`):

```bash
bundle exec rake test         # Run the package spec suite
bundle exec rake build        # Build the gem into the package dir
```

### Git hooks

Local automation lives in `.githooks/` and is enabled with `rake hooks:install`, which points `core.hooksPath` at the folder so all three hooks activate together. Undo with `rake hooks:uninstall`.

| Hook | Action |
|------|--------|
| **pre-commit** | Runs `rubocop --autocorrect` on staged Ruby files (`*.rb`, `*.rake`, `*.gemspec`, `*.ru`, `Gemfile`, `Rakefile`) and re-stages only the linting changes. Unstaged edits in the same file are preserved and never committed. Aborts if offenses remain that safe auto-correction cannot fix. |
| **pre-push** | Runs the repository specs (`rake test`) plus every package's tests (`rake monorepo:each[test]`) in build order, aborting the push if any test fails. Delete-only pushes skip the suite. |
| **commit-msg** | Validates the message against Conventional Commits (see [Commit Your Changes](#4-commit-your-changes)). |

Both `pre-commit` and `pre-push` prefer `bundle exec` and fall back to `ruby -S bundle exec` when the local `bundle` binstub cannot locate Ruby (some rvm/rbenv setups).

## Project Structure

```text
ruby/
├── .github/workflows/
│   ├── ci.yml          # Discover packages, then lint + per-package test matrix + DAG check
│   ├── .lint.yml       # Reusable: repo-wide RuboCop
│   ├── .test.yml       # Reusable: per-package test matrix
│   └── release.yml     # Dispatch-driven publish (OIDC, single gem) + GitHub Release
├── .githooks/
│   ├── pre-commit      # RuboCop auto-correct + re-stage of staged files
│   ├── pre-push        # Run the test suite; abort push on failure
│   └── commit-msg      # Conventional Commits hook (enable via rake hooks:install)
├── bin/
│   ├── commit-lint     # Pure-Ruby commit message linter CLI
│   └── release-notes   # Pure-Ruby CHANGELOG release-notes extractor CLI
├── config/
│   └── gems.yml        # Single source of truth: gem name → dir + deps (DAG)
├── lib/
│   ├── commit_lint.rb  # Conventional Commits rules (scopes below)
│   ├── release_notes.rb # CHANGELOG section extraction used by bin/release-notes
│   └── rake/           # Shared Rake tasks (lint, hooks, rspec, gem build/clean)
├── packages/           # Monorepo packages (each is an independent gem)
│   ├── lacus-utils/    # Leaf — shared Lacus helpers
│   ├── cpf-dv/, cpf-fmt/, cpf-gen/, cpf-val/, cpf-utilities/
│   ├── cnpj-dv/, cnpj-fmt/, cnpj-gen/, cnpj-val/, cnpj-utilities/
│   └── br-utilities/   # Umbrella: cpf-utilities + cnpj-utilities (module BrUtils)
├── .ruby-version       # 3.2.0 (minimum Ruby 3.2)
├── .rubocop.yml        # Shared RuboCop config (rubocop-rspec, rubocop-packaging)
├── Gemfile             # Root: tooling only (Rake, RuboCop, RSpec)
├── Rakefile            # monorepo:check_cycles, monorepo:order, monorepo:each[task]
├── LICENSE
└── README.md
```

Each package follows a consistent layout:

- **Source** lives under `src/`; the gemspec uses `require_paths = ["src"]` and `Dir["src/**/*"]`.
- Tests live in `tests/` and use the `.spec.rb` suffix, loading the shared `tests/spec_helper.rb`.
- Each package owns a `Gemfile`, `Rakefile`, `*.gemspec`, `CHANGELOG.md`, and `README.md`.
- Do **not** add package-level RuboCop config — the **root** `.rubocop.yml` governs the whole repo.

### Naming conventions

Gem names and package directories are **hyphenated** (`cpf-dv`, `cpf-utilities`, `br-utilities`, `lacus-utils`). Source files and require paths match (`src/cpf-dv.rb`, `src/cpf-dv/version.rb`). Module names stay CamelCase (`CpfDV`, `BrUtils`, `LacusUtils`), with `*-dv` → `*DV` (e.g. `cnpj-dv` → `CnpjDV`). Spec files use snake_case with a `.spec.rb` suffix (`cpf_dv.spec.rb`).

### Dependency resolution (Gemspec vs Gemfile)

`config/gems.yml` is the single source of truth for gem names, directories, and internal dependencies. It must form a **directed acyclic graph** — `rake monorepo:check_cycles` runs a topological sort on every push and fails if a cycle exists.

- **Gemspec** declares **released** dependencies with version constraints (e.g. `add_dependency "cpf-fmt", ">= 0"`). This is what users and RubyGems see. Gemspecs must **not** use `path:`.
- **Gemfile** overrides internal gems with `path: "../cpf-fmt"` so `bundle install` uses local code. List a path for **all** internal gems in the dependency tree (direct + transitive); otherwise Bundler tries to resolve unreleased gems from RubyGems and fails.

No switching logic is required: development resolves internal deps by path, published consumption resolves them by version from RubyGems.

## Contributing Guidelines

### What We're Looking For

We welcome contributions in the following areas:

- **🐛 Bug Fixes**: Fix issues in formatting, validation, generation, or check-digit calculation
- **✨ New Features**: New options or behavior aligned with CPF/CNPJ rules
- **📚 Documentation**: Improve READMEs, examples, and guides
- **🧪 Tests**: Add or extend specs for the public API and edge cases
- **⚡ Performance**: Optimize hot paths in formatters or validators
- **🔧 Tooling**: Improve Rake tasks, RuboCop config, or CI

### What We're NOT Looking For

- Breaking changes to the public API without discussion
- Changes that reduce test coverage
- Code that doesn't follow our style guidelines
- Features that don't align with the project's goals
- Package-level dev-tool config files (RuboCop, etc.)

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes

- Write clean, readable code following existing package patterns
- Add specs for new functionality
- Update documentation (README, CHANGELOG) when behavior or options change

### 3. Test Your Changes

```bash
# Full CI-equivalent validation (recommended before PR) — from the subrepo root
rake lint
rake test                     # Repository-level specs
rake monorepo:each[test]      # Every package's specs, in build order

# When changes are isolated to one package
cd packages/<pkg>
bundle exec rake test
```

Before pushing, the pre-push hook runs the repository specs and every package's tests automatically. Fix failures locally first.

### 4. Commit Your Changes

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org), enforced by a **pure-Ruby** linter (no Node/commitlint dependency) so it behaves identically in the git hook and in CI.

- **Types**: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`
- **Header**: `type(scope)?!?: subject` — header ≤ 100 chars, lower-case subject with no trailing period, and a blank line before any body.
- **Scopes**: optional; when present must be one of the per-package scopes below. A few scope names intentionally differ from the gem name.

```bash
git commit -m "feat(cpf-gen): add batch generator"
git commit -m "fix(cnpj-val): handle blank input"
git commit -m "docs(br-utils): update README examples"
git commit -m "test(cpf-dv): cover edge case for check digits"
```

| Scope | Package |
|-------|---------|
| `utils` | `lacus-utils` |
| `cnpj-dv` | `cnpj-dv` |
| `cnpj-fmt` | `cnpj-fmt` |
| `cnpj-gen` | `cnpj-gen` |
| `cnpj-val` | `cnpj-val` |
| `cnpj-utils` | `cnpj-utilities` |
| `cpf-dv` | `cpf-dv` |
| `cpf-fmt` | `cpf-fmt` |
| `cpf-gen` | `cpf-gen` |
| `cpf-val` | `cpf-val` |
| `cpf-utils` | `cpf-utilities` |
| `br-utils` | `br-utilities` |

Lint a range manually with `rake lint:commits` (defaults to `origin/main..HEAD`, override with `COMMIT_RANGE`).

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Testing

### Test Structure

- Tests live in the `tests/` directory within each package (never under `src/`)
- Test files use the `.spec.rb` suffix (e.g. `cpf_dv.spec.rb`) with snake_case names
- Each package's `tests/spec_helper.rb` loads the shared root helper and then `require`s the gem
- [RSpec](https://rspec.info/) is the test runner; follow the conventions from [Better Specs](https://www.betterspecs.org/)
- The shared `rake test` task (`lib/rake/rspec_tasks.rake`) runs `tests/**/*.spec.rb` with documentation format

### Writing Tests

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfDV do
  describe '.hello' do
    it 'returns cpf-dv' do
      expect(CpfDV.hello).to eq('cpf-dv')
    end
  end
end
```

Use `describe`/`context`/`it` blocks with descriptive names and prefer `subject`/`let` over instance variables, in the Better Specs style.

### Test Requirements

- **Coverage**: Cover happy paths, boundary conditions, and error cases
- **Cross-language alignment**: Prefer extending existing reference-suite cases over inventing new ones
- **Self-documenting specs**: Follow the naming and structure of sibling specs in the package you are editing
- **Changesets**: Test-only changes do not require a `CHANGELOG.md` entry

## Code Style

### Ruby Guidelines

- Target **Ruby 3.2** (`TargetRubyVersion` in `.rubocop.yml`)
- Add the **`# frozen_string_literal: true`** magic comment to every Ruby file
- Keep the public surface small; favor module functions and small, focused classes
- Use **2 spaces** for indentation (not tabs)
- Keep lines within **120 characters** (`Layout/LineLength`)

### Linting and Formatting

[RuboCop](https://rubocop.org/) is the linter and formatter (via auto-correct). Configuration lives in the root `.rubocop.yml`; extensions include [rubocop-rspec](https://docs.rubocop.org/rubocop-rspec/) (for `tests/**/*.spec.rb`) and [rubocop-packaging](https://github.com/rubygems/rubocop-packaging) (gemspec hygiene). Do not add package-level RuboCop config files.

```bash
rake lint                 # Check (what CI runs)
rake format               # Auto-correct safe offenses
rake lint:autocorrect_all # Auto-correct all offenses, including unsafe
```

CI runs `bundle exec rubocop` on every push.

### Naming Conventions

- **Modules/Classes**: CamelCase (`CpfDV`, `CpfUtils`, `BrUtils`; `*-dv` → `*DV`)
- **Methods**: snake_case (`hello`, `valid?`)
- **Variables**: snake_case (`input`, `options`)
- **Constants**: UPPER_SNAKE_CASE (`VERSION`, `CPF_LENGTH`)
- **Gem names / directories**: hyphenated (`cpf-dv`, `br-utilities`)
- **Source files**: hyphenated, matching the require path (`cpf-dv.rb`, `cpf-dv/version.rb`)
- **Spec files**: snake_case with `.spec.rb` suffix (`cpf_dv.spec.rb`)

### Example Code Style

```ruby
# frozen_string_literal: true

require_relative 'cpf-dv/version'

module CpfDV
  def self.hello
    'cpf-dv'
  end
end
```

## Changelog

Each package under `packages/<pkg>/` owns a `CHANGELOG.md`. Update it when your change is **user-facing** — anything under `src/`, the public `README.md`, `required_ruby_version`, or runtime dependencies / `summary` in the gemspec.

Do **not** add changelog entries for dev-only changes (tests, CI, Rake tasks, `.rubocop.yml`, `Gemfile`/`Gemfile.lock` regeneration, or development-only gemspec edits).

Follow [Semantic Versioning](https://semver.org/):

- **major** — breaking API or behavior change
- **minor** — new public API or feature
- **patch** — bug fix or non-breaking improvement

When you bump the version in `CHANGELOG.md`, also update the `VERSION` constant in `packages/<pkg>/src/<gem_name>/version.rb` to the same value.

## Releasing

Releases are **one gem at a time**, published to RubyGems via GitHub Actions using [Trusted Publishing (OIDC)](https://guides.rubygems.org/trusted-publishing/) — no API keys or secrets required. Only maintainers cut releases.

The `Release and Publish Package` workflow is **manually dispatched** (Actions → *Release and Publish Package* → *Run workflow*) with two inputs, mirroring the Python sibling:

- **`package`** (required): the package **directory** name (e.g. `cpf-val`, `lacus-utils`). The gem name is read from the package gemspec.
- **`version`** (optional): the version to release (e.g. `1.2.3` or a prerelease like `1.2.3.rc1`). Leave it empty to use the **latest** section in that package's `CHANGELOG.md`.

What the workflow does:

1. **Lint & test** the package via the reusable `.lint.yml` / `.test.yml` workflows.
2. **Prepare release notes**: extract the chosen version's `CHANGELOG.md` section with `bin/release-notes` and read the gem name from the gemspec. The tag is `<gem_name>@<version>`.
3. **Validate git state**: fail fast if the tag or a GitHub Release already exists, and confirm the `<package>/main` subtree branch exists.
4. **Publish (OIDC)**: write the version into `packages/<dir>/src/<gem_name>/version.rb` at release time, then build and push via `rubygems/release-gem`. No version-bump commit or manual tag is required beforehand.
5. **Create the GitHub Release**: cut a release (and its `<gem_name>@<version>` tag) against the tip of `<package>/main`, using the extracted notes as the body. Versions containing a letter (e.g. `1.2.3.rc1`) are marked as prereleases.

- **Preview the notes locally**: `ruby bin/release-notes <package> [--version X.Y.Z]` writes `.release/<package>@<version>.md` and prints its path.
- **Order**: Release leaves first (e.g. `cpf-dv`, `cpf-fmt`), then dependents (`cpf-utilities`, `cnpj-utilities`), then the `br-utilities` umbrella. Internal dependencies must already be on RubyGems at compatible versions.

## Pull Request Process

### Before Submitting

- [ ] Code follows our style guidelines (RuboCop)
- [ ] Lint passes (`rake lint`)
- [ ] All tests pass (`rake test` and `rake monorepo:each[test]`)
- [ ] The dependency graph is acyclic (`rake monorepo:check_cycles`)
- [ ] Documentation is updated (README, examples)
- [ ] User-facing changes have a `CHANGELOG.md` entry in the affected package(s)
- [ ] Commit messages follow conventional format (with package scope when applicable)

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass
- [ ] New tests added
- [ ] Coverage maintained

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Changelog updated (if user-facing)
- [ ] No breaking changes (or documented)
```

### Review Process

1. **Automated Checks**: CI runs RuboCop, a per-package test matrix, and the monorepo DAG check on every push
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Minimal steps to reproduce
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: Ruby version, OS, gem version
- **Code Example**: Minimal code that demonstrates the issue

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Install the gem and call the API with...
2. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- Ruby version: [e.g. 3.2.0]
- OS: [e.g. Ubuntu 22.04]
- Gem version: [e.g. cpf-dv 1.0.1]

**Code example**
```ruby
require 'cpf-dv'

result = CpfDV.hello

puts result # expected vs actual
```

**Additional context**
Any other context about the problem.
```

## Feature Requests

### Suggesting Features

When suggesting features, please include:

- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other ways to solve the problem
- **Additional Context**: Any other relevant information

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
A clear description of any alternative solutions.

**Additional context**
Add any other context or screenshots about the feature request.
```

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check the project `README.md`, package READMEs, and inline comments

## Recognition

Contributors will be recognized in:

- **README.md**: Contributors section
- **CHANGELOG.md**: Release notes
- **GitHub**: Contributor statistics

## License

By contributing to `br-utils`, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to `br-utils`! 🎉
