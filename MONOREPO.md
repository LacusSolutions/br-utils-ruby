# Ruby monorepo: design and operations

## Folder structure

```
ruby/
├── .github/workflows/
│   ├── ci.yml          # Lint + test matrix (one job per package)
│   ├── commitlint.yml  # Conventional Commits lint (PR/push) + linter self-test
│   └── release.yml     # Tag-driven publish (OIDC, single gem)
├── .githooks/
│   ├── pre-commit      # RuboCop auto-correct + re-stage of staged files
│   ├── pre-push        # Run the test suite; abort push on failure
│   └── commit-msg      # Conventional Commits hook (enable via rake hooks:install)
├── bin/
│   └── commit-lint     # Pure-Ruby commit message linter CLI
├── config/
│   └── gems.yml        # Single source of truth: gem name (hyphenated) → dir + deps (DAG)
├── .ruby-version       # 3.2.0 (minimum Ruby 3.2)
├── .gemrc
├── Gemfile             # Root: tooling only (rake, rubocop, rspec)
├── Rakefile            # monorepo:check_cycles, monorepo:order, monorepo:each[task]
├── lib/
│   ├── commit_lint.rb  # Conventional Commits rules (scopes from config/gems.yml)
│   └── rake/
│       └── gem_tasks.rake  # Shared build/clean/test stub for packages
├── packages/
│   ├── lacus-utils/    # Leaf — shared Lacus helpers (mirrors Python lacus.utils)
│   ├── cpf-dv/         # Leaf
│   │   ├── src/cpf-dv.rb, src/cpf-dv/version.rb
│   │   ├── cpf-dv.gemspec
│   │   ├── Gemfile
│   │   ├── Rakefile
│   │   └── tests/      # Better Specs-style examples, e.g. cpf_dv.spec.rb
│   ├── cpf-fmt/
│   ├── cpf-gen/        # Deps: cpf-dv (path in Gemfile)
│   ├── cpf-val/
│   ├── cpf-utilities/  # Deps: cpf-fmt, cpf-gen, cpf-val
│   ├── cnpj-dv/
│   ├── cnpj-fmt/
│   ├── cnpj-gen/
│   ├── cnpj-val/
│   ├── cnpj-utilities/
│   └── br-utilities/   # Umbrella: cpf-utilities, cnpj-utilities (gem name br-utilities, module BrUtils)
├── LICENSE
└── MONOREPO.md
```

- **Ruby**: Minimum version 3.2 (`.ruby-version`, all gemspecs, CI).
- **Naming**: Gem names and package dirs are **hyphenated** (`cpf-dv`, `cpf-utilities`, `br-utilities`, `lacus-utils`). Source files and require paths match: `src/cpf-dv.rb`, `src/cpf-dv/version.rb`. Module names stay CamelCase (e.g. `CpfDv`, `BrUtils`, `LacusUtils`). Spec files use snake_case with a `.spec.rb` suffix (`cpf_dv.spec.rb`).
- **Testing**: [RSpec](https://rspec.info/) with conventions from [Better Specs](https://www.betterspecs.org/). Shared config lives in `tests/spec_helper.rb`; each package loads it from `tests/spec_helper.rb` and runs `rake test` via `lib/rake/rspec_tasks.rake`.
- **Source layout**: All package source code lives under `src/`; gemspec uses `require_paths = ["src"]` and `Dir["src/**/*"]`.
- **Single config**: `config/gems.yml` uses hyphenated gem names as keys; Rake and CI use it for build order and cycle checks.

---

## Gemspec vs Gemfile (dependency resolution)

- **Gemspec**: Declares **released** dependencies with version constraints (e.g. `add_runtime_dependency "cpf_fmt", ">= 1.0", "< 2"`). This is what users and RubyGems see.
- **Gemfile**: In the monorepo, **overrides** internal gems with `path: "../cpf-fmt"` so `bundle install` uses local code. List path for **all** internal gems in the dependency tree (direct + transitive); otherwise Bundler will try to resolve transitive deps from RubyGems and fail for unreleased gems.
- **When a gem is published**: The built `.gem` only contains the gemspec. Installers resolve `cpf_fmt` from RubyGems, not from path. So development = path, published consumption = version from RubyGems. No switching logic required; Bundler and RubyGems handle it by context.

---

## Tagging strategy

- **Format**: `<gem_name>@<version>` (e.g. `cpf-dv@1.0.1`, `br-utilities@2.1.0`). Gem names are hyphenated.
- **Rule**: Version in source must match the tag. Before tagging:
  1. Bump `src/<gem_name>/version.rb` and commit.
  2. Push the tag: `git tag cpf-dv@1.0.1 && git push origin cpf-dv@1.0.1`.
- **Release workflow**: Triggered by tag push or manual dispatch. It validates package dir and version file, runs tests for that package only, builds the gem, and publishes via `rubygems/release-gem` (OIDC). Only the tagged gem is published; internal dependencies must already be on RubyGems at compatible versions.

---

## Release automation (Trusted Publishing / OIDC)

1. **One-time setup**: On RubyGems.org, add a trusted publisher for the repo (GitHub OIDC). Configure workflow identity (repo, optional environment).
2. **Workflow**: `release.yml` requests `id-token: write` and uses the `release` environment. No API key or token in secrets.
3. **Publish only changed gems**: Each release is one tag → one gem. No "publish all" step; you tag only what you release.
4. **Order**: Release leaves first (e.g. `cpf_dv`, `cpf_fmt`), then dependents (`cpf_utils`), then umbrella (`br_utils`). Enforced by process, not by workflow.

---

## Preventing circular dependencies

- **DAG**: `config/gems.yml` must form a directed acyclic graph. No gem may depend (directly or transitively) on itself.
- **Check**: `rake monorepo:check_cycles` runs a topological sort; it fails if a cycle exists.
- **CI**: `monorepo-check` job runs this on every push. Adding a new dependency that creates a cycle will break CI.

---

## Scaling to 10+ gems (CI speed)

- **Lint**: Single job for the whole repo (RuboCop).
- **Test**: One matrix job per package; jobs run in parallel. No single "install everything and test everything" job. Each package has its own `bundle install` and `rake test`; Bundler cache is per-package (or use a cache key that includes `packages/<name>/Gemfile.lock`).
- **Release**: One workflow run per tag; only that package is tested and published. No full-matrix release.
- **Optional**: Add a "changed packages" job that uses `git diff` to run tests only for packages under changed paths; keep the full matrix as a fallback for main.

---

## Risk analysis and edge cases

| Risk | Mitigation |
|------|------------|
| Releasing a dependent before its dependency | Process: release in topological order (leaves first). Optionally add a release checklist or script that checks RubyGems for minimum versions. |
| Version in source != tag | Release workflow greps `lib/<gem>/version.rb` for the tag version and fails if it doesn’t match. |
| Path dep left in gemspec | Gemspecs must not use `path:`. Only Gemfile uses path. Code review and RuboCop (or a custom task) can enforce "no path in gemspec". |
| Stale Gemfile.lock for a package | CI runs `bundle install` and tests; lockfile is updated on next commit. Consider `bundle lock --update` in CI and fail if lock changed. |
| OIDC environment not set on RubyGems | Release job fails at push with a clear auth error. Document required RubyGems trusted publisher setup in README. |
| Tag format typo (e.g. `cpf-dv@1.0.0` with hyphen) | Validate step maps tag to dir via `tr '_' '-'`; wrong tag format (e.g. hyphen in gem name) yields "package not found". Enforce tag format in docs. |
| Multiple gems changed, only one tagged | By design: one tag = one release. To release several, tag each and push in dependency order. |
| Pre-release versions (e.g. 1.0.0.pre1) | Semver regex in validate allows optional `-pre` suffix; ensure RubyGems accepts the version string. |

---

## Rake commands

- `rake` or `rake monorepo:check_cycles` — Verify DAG.
- `rake monorepo:order` — List gems in build order.
- `rake monorepo:each[test]` — Run `rake test` in each package in dependency order (fails fast).
- `rake lint` — Run RuboCop across the monorepo.
- `rake format` — Auto-correct safe RuboCop offenses (`rubocop -a`).
- `rake lint:commits` — Lint commit messages in `origin/main..HEAD` (override with `COMMIT_RANGE`).
- `rake hooks:install` / `rake hooks:uninstall` — Enable/disable the git `commit-msg` hook.
- From a package dir: `bundle exec rake test`, `bundle exec rake build`.

## Linting and formatting

[RuboCop](https://rubocop.org/) is the linter and formatter (via auto-correct). Configuration lives in `.rubocop.yml` at the repo root; extensions include [rubocop-rspec](https://docs.rubocop.org/rubocop-rspec/) (for `tests/**/*.spec.rb`) and [rubocop-packaging](https://github.com/rubygems/rubocop-packaging) (gemspec hygiene). CI runs `bundle exec rubocop` on every push.

---

## Git hooks

Local automation lives in `.githooks/` and is enabled with `rake hooks:install` (it points `core.hooksPath` at the folder, so all three hooks activate together). Undo with `rake hooks:uninstall`.

- **`pre-commit`** — Runs `rubocop --autocorrect` on the staged Ruby files (`*.rb`, `*.rake`, `*.gemspec`, `*.ru`, `Gemfile`, `Rakefile`) and re-stages the corrections so they are committed alongside your change. Only the linting changes are staged: a file may be partially staged (also carry unstaged edits), so the hook lints the staged snapshot in isolation and replays your unstaged edits back onto the working tree afterwards. If an unstaged edit overlaps a corrected line the fix cannot be merged into the working copy — the staged/committed version is still linted and your unstaged edit is kept untouched. The commit is aborted if RuboCop reports offenses that safe auto-correction cannot fix (try `rake lint:autocorrect_all` or fix them by hand).
- **`pre-push`** — Runs the repository specs (`rake test`) and every package's tests (`rake monorepo:each[test]`) in build order, aborting the push if any test fails. Delete-only pushes skip the suite.
- **`commit-msg`** — Conventional Commits check (see below).

Both `pre-commit` and `pre-push` prefer `bundle exec` and fall back to `ruby -S bundle exec` when the local `bundle` binstub cannot locate Ruby (some rvm/rbenv setups).

---

## Commit message linting (Conventional Commits)

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org), enforced by a **pure-Ruby** linter (no Node/commitlint dependency) so it behaves identically in a git hook and in CI.

- **Rules** (`lib/commit_lint.rb`): mirrors `@commitlint/config-conventional` — header `type(scope)?!?: subject`, header ≤ 100 chars, known lower-case `type`, lower-case subject with no trailing period, and a blank line before any body. Merge/revert/fixup/squash headers are skipped.
- **Scopes**: optional; when present must be one of a fixed per-package list (`SCOPES` in `lib/commit_lint.rb`), mirroring the JS sibling's `@commitlint/config-workspace-scopes`. A few scope names intentionally differ from the gem name: `utils` (`lacus-utils`), `cnpj-utils` (`cnpj-utilities`), `cpf-utils` (`cpf-utilities`), `br-utils` (`br-utilities`). The rest match the gem name (`cnpj-dv`, `cnpj-fmt`, `cnpj-gen`, `cnpj-val`, `cpf-dv`, `cpf-fmt`, `cpf-gen`, `cpf-val`).
- **CLI** (`bin/commit-lint`): `--file PATH` (hook), `--message MSG`, or `--range A..B`.
- **Local hook**: `.githooks/commit-msg` runs the CLI on every commit; enable with `rake hooks:install` (sets `core.hooksPath`).
- **CI**: `.github/workflows/commitlint.yml` lints the PR/push commit range and runs the linter's RSpec self-test.

---

## Comparison with JS/Python/PHP siblings

- **JS**: Workspaces + changesets; version bumps and publish are centralized. Here we use tags and one-gem-per-tag for simplicity.
- **Python**: Similar per-package version and release; we mirror "publish only what’s tagged" and dependency order.
- **PHP**: Composer workspaces with path repos; we mirror path deps in Gemfile and released constraints in gemspec.
