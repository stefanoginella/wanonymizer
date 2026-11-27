# Constitution

## Non-negotiables

- No network: the tool opens no connection, with no telemetry and no update check. Why: users run it on raw personal data, also on production servers.
- No original value appears in a log, a report, an error message, or a temporary file. Why: these files get shared and pasted, and they would leak what the output hides.
- Never silent: each table and key without a rule is swept or emptied, and named in the report. A parse error stops the run with a non-zero exit code, and partial output is never presented as complete. Why: the user cannot see a leak in a multi-GB dump.
- Read-only: the tool never writes to a database or to its input file. Why: it must be safe to run next to production.
- Irreversible: replacement values come from a random key made per run and never stored, never from a plain hash of the original. Why: a plain hash of an email is confirmed by one guess.
- Synthetic fixtures only: no real personal data and no real secrets in the repo, the tests, or the issues. Why: the repo is public.
- No legal labels: the docs and the output never say "GDPR-compliant" and never guarantee "anonymous". They say what the tool changes and the risk that stays. Why: the controller makes that assessment per recipient ([R-002](research/R-002-gdpr-anonymisation.md)).
- One CLI rule: each command, verb, flag, and exit code follows the CLI rule in `architecture.md`. Why: a user and a script must be able to predict the next command from the ones they know.

## Definition of Done

- `make check` passes: `gofmt -l .` prints nothing, `go vet ./...`, `golangci-lint run`, `go test -race ./...`, and `go build ./...`.
- A unit that adds or changes a rule has a golden-dump test with canary values for it.
- The README and the pack docs match the new behavior.

## Sensitive paths

- `internal/dump/**`: the SQL dump tokenizer and writer; a defect breaks the dump.
- `internal/rewrite/**`: rewriting inside PHP-serialized and JSON values; a defect breaks the dump or leaks.
- `internal/pseudo/**`: the run key and the replacement values; a weak replacement can be reversed.
- `internal/sweep/**`: the detectors; a miss leaks.
- `packs/**`: the built-in rule packs; a missed column leaks.
- `.github/workflows/**` and `.goreleaser.yaml`: CI and release; the released binary runs on raw personal data.
