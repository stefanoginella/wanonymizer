# Architecture

## Target

- An open-source project (MIT) for WordPress developers, agencies, and support teams, who run it on their own machines and servers.

## Stack

- Go 1.27, one static binary per OS and CPU.
- No fake-data library with locales exists for Go ([R-001](research/R-001-prior-art.md)): the tool ships its own word lists.

## Structure

- `cmd/wanonymizer/`: the CLI entry point.
- `internal/dump/`: the SQL dump tokenizer and writer.
- `internal/rewrite/`: rewriting inside PHP-serialized and JSON values.
- `internal/pseudo/`: the run key and the replacement values.
- `internal/sweep/`: the detectors for data without a rule.
- `packs/`: the built-in rule packs, as data files embedded in the binary.

## Boundaries

- The data flow is one stream: `internal/dump` reads statements, the rules of the matching packs pick a replacement for each value, `internal/dump` writes the result.
- Only `internal/dump` reads the input and writes the output. Only `internal/pseudo` holds the run key.
- A pack is data, not code: the built-in packs and the project config use the same format.
- The CLI rule (the form of commands, verbs, flags, and exit codes): M-002 sets it with the first command and writes it here.

## Data storage

- None of its own: a SQL dump in (a file or stdin), a SQL dump out, and a run report.
- The project config is two files: one that can be committed (rules for custom plugins, tables, and columns), and a local one that is never committed (the always and never word lists).

## Access

- None: a local command-line tool with no sign-in.

## Environments

- Local: the user runs the binary on a laptop or on a server over SSH.
- CI: GitHub Actions on each push and pull request: `make check` on Linux, the tests on macOS and Windows, govulncheck, the workflow linters, and a release dry run ([M-001](initiatives/I-001-dump-anonymizer/milestones/M-001-guardrails/spec.md) D-07). Vet, lint, the dependency check, and govulncheck run per release target and on the host ([M-001 report](initiatives/I-001-dump-anonymizer/milestones/M-001-guardrails/report.md) D-13).
- Release: a workflow on a pushed `v*` tag runs GoReleaser: binaries for macOS, Linux, and Windows on amd64 and arm64, `checksums.txt` with a GitHub build provenance attestation for each file it lists, .deb and .rpm files, and a Homebrew cask in `stefanoginella/homebrew-tap` (M-001 D-03, D-05, D-06). A tag with a prerelease suffix gives a GitHub prerelease and leaves the cask alone (M-001 report D-14). `go install github.com/stefanoginella/wanonymizer/cmd/wanonymizer@latest` also works.

## External services

- GitHub (the repository, Actions, Releases, Dependabot, artifact attestations, and the Homebrew tap repository): credentials are GitHub Actions secrets. It has no test mode: a release or a tap update is a live write that waits for the user's yes. Attestations of a public repository are signed through the public Sigstore instance, and their log is public.
- CI only: govulncheck queries vuln.go.dev.
- None at run time: the tool works offline.

## Background work

- None: each run reads one dump and ends.

## Logs and monitoring

- None: progress and errors go to stderr, and each run writes a report of what was replaced, removed, and swept. Neither holds an original value.
