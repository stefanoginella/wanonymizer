---
id: M-001
title: guardrails
type: guard
rigor: strict
uat: no
status: building
spec_hash: 73c6cf65d3fbca59677f05d4e601b45a9277ade724fb4022c090cdc90f4b2b30
---

## Goal

Every later milestone of I-001 runs under the project's checks from its first commit, and the first release needs no new setup: after the manual actions, a tag push is enough. It is for the maintainer and the contributors of a public repository whose code handles personal data and secrets: a format, vet, lint, race, test, build, or network-import defect fails a check before it lands, and the release path (binaries, checksums, attestations, Linux packages, the Homebrew cask) is proven by a build that publishes nothing, before the first binary reaches a user.

## Scope

- A Go 1.27 module at `github.com/stefanoginella/wanonymizer` (D-01), with a placeholder entry point in `cmd/wanonymizer/` that prints its build version, so the release path has a binary to build. M-002 replaces it under the CLI rule.
- `make check`: gofmt, go vet, golangci-lint with the linters of D-10, a `go mod tidy` drift check, the tests with the race detector, the build, and the dependency check of D-08. `make tools` installs the pinned dev tools.
- GitHub Actions CI on each push and pull request, with the jobs of D-07, every action pinned by commit SHA, and Dependabot (D-09).
- A release workflow on a pushed `v*` tag that publishes the GitHub release, the attestations of D-06, and the Homebrew cask of D-05. It is written and checked here; its first run is the `release` command.
- The MIT license, with the copyright holder of D-02.
- A GoReleaser config for the targets of D-03: archives, `checksums.txt`, .deb and .rpm packages, and the Homebrew cask, built without publishing.
- A README: what the tool is and that it has no release yet, the install channels, how to verify a download, the macOS quarantine command of D-05, and the development commands.

## Out of scope

- A published release, a tag, and a tap commit: the `release` command, after the manual actions in `roadmap.md`.
- macOS signing and notarization (D-05); cosign signatures and SBOMs (D-06).
- winget and Scoop packages: a roadmap row.
- The CLI rule and every real command, verb, and flag: M-002.
- Repository settings, such as required checks on `main` or GitHub's SHA-pinning policy: the user's to turn on, not set by this milestone.
- A real import into WordPress in CI (I-001 D-10).

## Acceptance criteria

- AC-01: `make check` exits 0 after it runs each of its steps (gofmt, go vet, golangci-lint, the `go mod tidy` drift check, the race-enabled tests, the build, and the dependency check), when the tree is clean. Check: `make check`, locally and in the Linux CI job.
- AC-02: `make check` exits non-zero and shows the output of the step that failed, when one defect is seeded in a throwaway copy of the tree: an unformatted file, a vet error, a finding of each linter of D-10, a `go.mod` that `go mod tidy` would change, a failing test, a data race, a build error, or an import of a package that D-08 denies, from the entry point or through another project package. Check: `make check` in a temporary worktree, once per seeded defect.
- AC-03: Every CI job of D-07 passes on GitHub for the push event and the pull request event, when the unit branch is pushed and its draft PR is open. Check: `gh pr checks` on the draft PR.
- AC-04: `goreleaser check` reports a valid config with no deprecated property, and `goreleaser release --snapshot --clean` writes to `dist/` an archive for each target of D-03, a .deb and an .rpm for Linux amd64 and arm64, a Homebrew cask that removes the quarantine attribute (D-05), and a `checksums.txt` whose SHA-256 lines match each archive and package, while it publishes nothing (no GitHub release, no tap commit), when both run on the tree with no release token set. Check: the CI release dry run, `sha256sum --check dist/checksums.txt`, and `gh release list`.
- AC-05: `wanonymizer --version` prints the version that its build recorded and exits 0, when the binary comes from the amd64 .deb installed in a Debian container, from the amd64 .rpm installed in a Fedora container, or from `go install` of the module path at the pushed commit. Check: the CI release dry run, and `go install` straight from GitHub into a temporary `GOBIN`.
- AC-06: The release workflow runs only on a pushed `v*` tag, its release job alone holds the write permissions (contents, id-token, attestations) and the tap token, and every other workflow has read-only contents permission, when actionlint and zizmor read the workflows. Check: actionlint and zizmor pass, and the `on:` and `permissions:` blocks hold what this AC names.
- AC-07: Every `uses:` in the workflows names a full commit SHA with its version as a comment, and Dependabot updates GitHub Actions and Go modules weekly, when zizmor reads the workflows with a hash-pin policy for every action. Check: zizmor, which fails on a seeded tag reference, and `.github/dependabot.yml`.
- AC-08: LICENSE holds the MIT license text with the copyright line `Copyright (c) 2026 <the name of D-02>`, when read in the tree. Check: a diff with the SPDX MIT text (spdx.org/licenses/MIT), which differs only in that line.

## Decisions

| ID | Decision | Why | Rejected alternative |
|---|---|---|---|
| D-01 | The owner is the `stefanoginella` account: module path `github.com/stefanoginella/wanonymizer`, tap repository `stefanoginella/homebrew-tap` | The user's choice (2026-11-27): the account that creates the repository; no organization to set up | An organization: a home that outlives one account, but it must exist first, and a later move changes the module path |
| D-02 | LICENSE names the user (the git user name) as copyright holder; the .deb and .rpm maintainer field holds the same name, with no email | The user's choice (2026-11-27). nfpm needs a non-empty `maintainer` (nfpm.goreleaser.com/docs/configuration, read 2026-11-27); Debian policy expects `Name <email>`, so lintian would warn, while dpkg still installs it | "The wanonymizer authors" with a GitHub noreply email: no personal name. The user's name with an email: reachable, and the address gets spam |
| D-03 | Release targets: macOS, Linux, and Windows on amd64 and arm64 (6 binaries), with .deb and .rpm for both Linux CPUs | The user's choice (2026-11-27): Apple silicon and Intel laptops, x86 and ARM servers, Windows on ARM | Also 386 and armv7: 10 binaries, two hard to test. 4 binaries: no ARM servers, no Windows on ARM |
| D-04 | The GitHub repository and its `origin` remote exist before `build`: `build` pushes the unit branch, opens a draft PR, and a real CI run proves the CI criteria | The user's choice (2026-11-27): a workflow that passes a linter can still fail on GitHub (permissions, runner images) | The repository later: the CI criteria proven by a workflow linter only, until the first push |
| D-05 | Homebrew: a cask in the tap, with unsigned binaries. The cask's post-install step removes the macOS quarantine attribute, and the README gives the same `xattr` command for a direct download | The user's choice (2026-11-27). GoReleaser hard-deprecated formulas for prebuilt binaries (`brews`) since v2.16, and documents this hook for unsigned casks; it warns that Apple may block the bypass (goreleaser.com/deprecations and goreleaser.com/customization/homebrew_casks, read 2026-11-27) | A cask with a caveats note only: a manual step for every Mac user. Sign and notarize: the $99/year Apple Developer Program and 5 secrets. A formula: `goreleaser check` warns, and GoReleaser may drop it |
| D-06 | Each release carries `checksums.txt` and a GitHub build provenance attestation for each file that it lists; users verify a download with `gh attestation verify` | The user's choice (2026-11-27): free on public repositories, SLSA v1.0 Build L2 by GitHub's docs, and GoReleaser's documented setup (docs.github.com artifact attestations; goreleaser.com/customization/attestations, updated 2026-08-30) | Also a cosign keyless signature: verifiable without gh, but one more tool and a signer identity to type. SBOMs: list contents, prove no origin. Checksums only: a tampered release can carry matching checksums |
| D-07 | CI on each push and pull request: `make check` on Linux; the race-enabled tests and the build on macOS and Windows; govulncheck; actionlint and zizmor on the workflows; a release dry run (`goreleaser check`, a snapshot build, the .deb and .rpm installed in Debian and Fedora containers, and the installed binary run) | The user's choice (2026-11-27). Standard GitHub-hosted runners, macOS and Windows included, are free on public repositories; larger runners are billed (docs.github.com/en/billing/concepts/product-billing/github-actions, read 2026-11-27) | Linux only: the CRLF and stdin quirks of Windows unseen. No dry run: the release path proven once, then broken unseen |
| D-08 | A dependency check fails when the shipped binary's package graph holds `net`, `net/http`, `crypto/tls`, `os/exec`, or `database/sql`; test code is outside that graph | The user's choice (2026-11-27): it enforces the "no network" and "read-only" non-negotiables, also through a dependency. A later milestone that needs one of them (`net/mail` pulls in `net`) changes the check by a decision | A lint rule on the project's own imports: misses a dependency. No check: review alone |
| D-09 | Every action in the workflows is pinned by full commit SHA with a version comment; Dependabot updates GitHub Actions and Go modules weekly | The user's choice (2026-11-27): GitHub's secure-use docs recommend full SHAs, and Dependabot updates the SHA and its comment, free on public repositories (docs.github.com/en/actions/reference/security/secure-use, read 2026-11-27). Dependabot reads its config from `main`, so it starts after the first merge | A workflow lockfile (`gh actions-lock`, GA 2026-10-28): one month old, linter support unknown. Major tags: a moved tag runs new code next to the tap token |
| D-10 | golangci-lint runs its standard set (errcheck, govet, ineffassign, staticcheck, unused) plus gosec, errorlint, nolintlint, misspell, and forbidigo against `fmt.Print*`, `print`, and `println` | The user's choice (2026-11-27): gosec fits code that handles secrets; the dump goes to stdout, so a stray print corrupts it; nolintlint makes each exception name its linter and a reason | The standard set only: no security linter, no stdout guard. All linters minus a deny list: style noise, and each upgrade can turn CI red |
