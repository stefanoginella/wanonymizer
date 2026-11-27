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
- CI: GitHub Actions runs `make check` on each push and pull request.
- Release: GoReleaser builds binaries for macOS, Linux, and Windows with checksums, .deb and .rpm files, and the Homebrew tap formula. `go install` also works.

## External services

- GitHub (the repository, Actions, Releases, and the Homebrew tap repository): credentials are GitHub Actions secrets. It has no test mode: a release or a tap update is a live write that waits for the user's yes.
- None at run time: the tool works offline.

## Background work

- None: each run reads one dump and ends.

## Logs and monitoring

- None: progress and errors go to stderr, and each run writes a report of what was replaced, removed, and swept. Neither holds an original value.
