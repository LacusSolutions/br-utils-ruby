# Ruby monorepo: design and operations

## Folder structure

```
ruby/
├── .github/workflows/
│   ├── ci.yml          # Lint + test matrix (one job per package)
│   └── release.yml     # Tag-driven publish (OIDC, single gem)
├── .ruby-version       # 3.2.0 (minimum Ruby 3.2)
├── .gemrc
├── config/
│   └── gems.yml        # Single source of truth: gem name (hyphenated) → dir + deps (DAG)
├── Gemfile             # Root: tooling only (rake, rubocop)
├── Rakefile            # monorepo:check_cycles, monorepo:order, monorepo:each[task]
├── lib/rake/
│   └── gem_tasks.rake  # Shared build/clean/test stub for packages
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
- From a package dir: `bundle exec rake test`, `bundle exec rake build`.

---

## Comparison with JS/Python/PHP siblings

- **JS**: Workspaces + changesets; version bumps and publish are centralized. Here we use tags and one-gem-per-tag for simplicity.
- **Python**: Similar per-package version and release; we mirror "publish only what’s tagged" and dependency order.
- **PHP**: Composer workspaces with path repos; we mirror path deps in Gemfile and released constraints in gemspec.
