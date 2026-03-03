![br-utils for Ruby](https://br-utils.vercel.app/img/cover_br-utils.jpg)

Brazilian data utilities (CPF, CNPJ, etc.) as a **multi-gem monorepo**, publishable to RubyGems with independent versioning and GitHub Actions (Trusted Publishing / OIDC).

## Structure

- **Root**: Tooling (Rake, RuboCop), shared config in `config/gems.yml`, no app code.
- **Packages**: Under `packages/` — each is a gem (e.g. `cpf-dv`, `cpf-utils`, `br-utilities`). Internal dependencies use path in development and version constraints when published.

See [MONOREPO.md](MONOREPO.md) for folder layout, tagging, dependency resolution, and risks.

## Local setup

```bash
bundle install
rake monorepo:check_cycles
cd packages/cpf-dv && bundle install && rake test
```

## Releasing (one gem at a time)

1. Bump version in `packages/<dir>/src/<gem_name>/version.rb`, commit.
2. Push tag: `git tag <gem_name>@<version>` (e.g. `cpf-dv@1.0.1`), then `git push origin <tag>`.
3. Configure [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) for this repo and the `release` environment.
4. The Release workflow runs: tests the package, builds the gem, publishes to RubyGems via OIDC. No secrets required.

Release leaves first (e.g. `cpf-dv`, `cpf-fmt`), then dependents (`cpf-utils`), then `br-utilities`.

## License

MIT. See [LICENSE](LICENSE).
