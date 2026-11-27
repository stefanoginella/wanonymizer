# Testing

## Test levels

| Level | What it tests | Tool |
|---|---|---|
| Unit | One package from its public functions: the tokenizer, the rewriter, the replacement values, each detector | `go test`, table tests |
| Property | Pure logic on generated input: a dump or a serialized value that passes through unchanged rules is byte-identical, and a rewritten one stays valid | Go fuzz tests (`go test -fuzz`) |
| Golden dump | The CLI through its real entry point on synthetic fixture dumps seeded with canary values: no canary value is in the output, and the output matches the expected dump | `go test`, fixtures in `testdata/` |

## Not tested

- A real import into WordPress in CI: the user tests the import by hand on a local WordPress for now (I-001 D-10; a deferred row in `roadmap.md`).
- The behavior of MySQL, MariaDB, and WordPress themselves: they have their own tests.

## Commands

- `make check`: format, vet, lint, tests with the race detector, and build.
- `go test ./...`: all tests.
- `go test -run <name> ./internal/<package>/`: one test.

## Test paths

- `**/*_test.go`
- `**/testdata/**`
- `internal/testutil/**`

## Risks

| Risk | P | I | P×I | Protection |
|---|---|---|---|---|
| A rule pack misses a column or a key, and personal data stays in the output | 3 | 3 | 9 | Golden dumps with a canary value in every column and key of the fixture; the sweep as a second net |
| The sweep misses personal data in a table or key without a rule | 3 | 3 | 9 | Detector tests per pattern; the report names every swept table; `--strict` empties them |
| A rewritten value breaks the dump: a serialized length, an escape, a charset | 3 | 2 | 6 | Property tests on round trips; golden dumps |
| A replacement value can be reversed or confirmed by a guess | 2 | 3 | 6 | Tests that two runs give different values, and that no output equals a plain hash of its input |
| An original value appears in a log, a report, or an error | 2 | 3 | 6 | Golden-dump tests scan stderr and the report for canary values |
| Memory grows without limit on a multi-GB dump with one INSERT per table | 2 | 2 | 4 | A test with a generated large statement under a memory limit |
| WooCommerce tax or shipping rules stop matching after the rewrite | 2 | 2 | 4 | Golden dumps that keep the fields the rules match on; the user's manual import test |
| A tampered release binary reaches users | 1 | 3 | 3 | Checksums on each release; CI and release files are sensitive paths |
