# Contributing to ruby-macho

Thank you for helping improve `ruby-macho`.

## Set up the repository

Install Ruby 3.3 or newer and Bundler, then install the locked dependencies:

```console
bundle install
```

Run the same repository-owned checks used by CI:

```console
bundle exec rake
```

That command runs RuboCop, the complete Minitest suite, YARD documentation
checks, and a build-and-smoke test of the packaged gem. CI also enforces the
current minimum line and branch coverage percentages.

Useful focused commands are:

```console
bundle exec rake test
bundle exec ruby -Ilib -Itest test/test_macho.rb
bundle exec rubocop
bundle exec rake doc
bundle exec rake package_smoke
bundle exec rake bench
```

The benchmark task requires macOS command-line tools. The library and test
suite otherwise run on both macOS and Linux, as reflected in the CI matrix.

You can optionally install the repository's pre-commit checks with:

```console
bundle exec overcommit --install
```

## Submit a change

- Add a focused regression test for behavior changes and bug fixes.
- Keep public behavior and limitations documented in `README.md` and YARD
  comments.
- Keep commits focused and include a `Signed-off-by` trailer. `git commit -s`
  adds it automatically.
- Run `bundle exec rake` before opening a pull request.

## Test fixtures

Mach-O fixtures live under `test/bin`. Prefer a small, source-generated
reproducer over copying a production binary. Sources and generation recipes
live under `test/src` and `test/bin/yaml2obj`.

Any new or replaced binary fixture must include:

- the smallest practical source or deterministic generation recipe;
- the upstream source and version, when applicable;
- a SHA-256 digest for externally built artifacts;
- the reason the fixture is necessary and the test that exercises it; and
- its license and attribution requirements.

LLVM-derived malformed fixtures retain their license in
`test/bin/llvm/LICENSE.txt`. Update the README attribution and keep applicable
license material adjacent to any new third-party fixture.

## Reporting problems

Use [GitHub Issues](https://github.com/Homebrew/ruby-macho/issues) for ordinary
bugs. Report suspected vulnerabilities privately through
[GitHub's security advisory form](https://github.com/Homebrew/ruby-macho/security/advisories/new)
and follow [Homebrew's security policy](https://github.com/Homebrew/.github/security/policy).
