![br-utils for Ruby](https://br-utils.vercel.app/img/cover_br-utils.jpg)

Brazilian data utilities (CPF, CNPJ, etc.) as a **multi-gem monorepo**, publishable to RubyGems with independent versioning and GitHub Actions (Trusted Publishing / OIDC).

## Structure

- **Root**: Tooling (Rake, RuboCop), shared config in `config/gems.yml`, no app code.
- **Packages**: Under `packages/` — each is a gem (e.g. `cpf-dv`, `cpf-utilities`, `br-utilities`). Internal dependencies use path in development and version constraints when published.

See [MONOREPO.md](MONOREPO.md) for folder layout, tagging, dependency resolution, and risks.

## Local setup

```bash
bundle install
rake hooks:install          # enable the git hooks (pre-commit, pre-push, commit-msg)
rake monorepo:check_cycles
cd packages/cpf-dv && bundle install && rake test
```

## Git hooks

`rake hooks:install` points `core.hooksPath` at `.githooks/`, enabling:

- **pre-commit**: RuboCop auto-corrects the staged Ruby files and re-stages only the
  linting changes (unstaged edits in the same files are preserved, never committed).
  Aborts if offenses remain that safe auto-correction can't fix.
- **pre-push**: runs the repository specs and every package's tests in build order,
  aborting the push if any test fails.
- **commit-msg**: rejects commit messages that don't follow Conventional Commits.

Undo with `rake hooks:uninstall`. See [MONOREPO.md](MONOREPO.md#git-hooks) for details.

## Commit messages

Commits follow [Conventional Commits](https://www.conventionalcommits.org). A pure-Ruby
linter (`bin/commit-lint`) enforces this in two places:

- **Locally**: `rake hooks:install` sets `core.hooksPath` to `.githooks`, so the
  `commit-msg` hook rejects non-conforming messages. Undo with `rake hooks:uninstall`.
- **CI**: the `Commit Lint` workflow validates every commit in a push/PR.

Allowed `type`s: `build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test`.
The `(scope)` is optional; when present it must be one of the per-package scopes below
(a few differ from the gem name). Example: `feat(cpf-gen): add batch generator`.

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

Lint a range manually with `rake lint:commits` (defaults to `origin/main..HEAD`, override
with `COMMIT_RANGE`).

## Releasing (one gem at a time)

1. Bump version in `packages/<dir>/src/<gem_name>/version.rb`, commit.
2. Push tag: `git tag <gem_name>@<version>` (e.g. `cpf-dv@1.0.1`), then `git push origin <tag>`.
3. Configure [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) for this repo and the `release` environment.
4. The Release workflow runs: tests the package, builds the gem, publishes to RubyGems via OIDC. No secrets required.

Release leaves first (e.g. `cpf-dv`, `cpf-fmt`), then dependents (`cpf-utilities`, `cnpj-utilities`), then `br-utilities`.

## License

MIT. See [LICENSE](LICENSE).
