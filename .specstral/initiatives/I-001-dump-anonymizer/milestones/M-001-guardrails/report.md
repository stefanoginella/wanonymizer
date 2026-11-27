---
id: M-001
---

## Checklist

- [x] T-01: Add the module, the placeholder entry point, the Makefile (`check`, `tools`), the dependency check script, `.golangci.yml`, `.gitattributes`, and the `.gitignore` lines; `make check` passes (e41f3ad, 7cd9482: `make check` exit 0, 7 steps)
- [x] T-02: Add LICENSE and README (ba0cdd7: diff with SPDX MIT differs only in the copyright line)
- [x] T-03: Add `.goreleaser.yaml` and a `make snapshot` target; `goreleaser check` and a local snapshot build pass (844d4cc: check exit 0, no deprecation; snapshot 10 artifacts, `shasum --check` 10 OK)
- [x] T-04: Add `ci.yml` with the jobs of D-07, the zizmor config, and `.github/dependabot.yml`, with every action pinned by SHA; actionlint and zizmor pass locally (0613479: actionlint 0 errors, zizmor no findings, seeded `@v7` fails zizmor; 9/9 `uses:` SHA-pinned)
- [x] T-05: Add `release.yml`; actionlint, zizmor, and `goreleaser check` pass locally (7d3e60b: actionlint 0, zizmor no findings, `goreleaser check` exit 0; 13/13 `uses:` SHA-pinned)
- [ ] review
- [ ] verify
