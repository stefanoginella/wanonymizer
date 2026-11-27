# wanonymizer

wanonymizer is meant to be a command-line filter for WordPress SQL
dumps: it will read a dump from a file or stdin and write a dump in
which the personal data and keys that its rules know about (users,
customers, orders, form entries, password hashes, API keys) are
replaced or removed, so that the copy still imports into a blank site
and can be shared to debug, develop locally, or give to an LLM. Each
run will write a report of what it replaced, removed, and swept, and of
the risk that stays. It will work offline and never write to a
database or to its input file. It is a tool, not a legal assessment:
whether a changed dump is fit to share with a given recipient remains
your decision.

## Status

No release yet. The current code is a placeholder that prints its
version and exits; it changes no dump. The features above are planned,
not shipped.

## Install

These are the channels of the first release, which is not out yet.

- Homebrew (macOS):

  ```sh
  brew install --cask stefanoginella/tap/wanonymizer
  ```

  The fully qualified name trusts only this cask, because Homebrew
  requires explicit trust for non-official taps. To use the short name
  `wanonymizer`, first run:

  ```sh
  brew tap stefanoginella/tap
  brew trust --cask stefanoginella/tap/wanonymizer
  ```

- Debian and Ubuntu: download the `.deb` for your CPU (amd64 or arm64)
  from the [releases page](https://github.com/stefanoginella/wanonymizer/releases),
  then run `sudo apt install ./<file>.deb`.

- Fedora, RHEL, and other RPM systems: download the `.rpm` for your CPU
  (amd64 or arm64), then run `sudo dnf install ./<file>.rpm`.

- Archives: a `.tar.gz` for macOS and Linux and a `.zip` for Windows,
  each for amd64 and arm64, on the releases page. Unpack it and put
  `wanonymizer` (or `wanonymizer.exe`) on your `PATH`.

- From source, with Go 1.27 or later:

  ```sh
  go install github.com/stefanoginella/wanonymizer/cmd/wanonymizer@latest
  ```

## Verify a download

Each release lists the SHA-256 of every archive and package in
`checksums.txt`. Download it next to your file, then run:

```sh
sha256sum --ignore-missing --check checksums.txt         # Linux
shasum -a 256 --ignore-missing --check checksums.txt     # macOS
```

Each file of `checksums.txt` also has a GitHub build provenance
attestation, which proves that the release workflow of this repository
built it. With the [GitHub CLI](https://cli.github.com/):

```sh
gh attestation verify <file> --repo stefanoginella/wanonymizer
```

## macOS: unsigned binaries

The macOS binaries are not signed or notarized. The Homebrew cask
removes the quarantine attribute itself. For a direct download, remove
it before the first run, or macOS blocks the binary:

```sh
xattr -dr com.apple.quarantine <path>
```

`<path>` is the unpacked `wanonymizer` binary, or the folder that holds
it.

## Development

You need Go 1.27, `make`, and `curl`.

- `make tools` installs the pinned versions of golangci-lint,
  GoReleaser, actionlint, and zizmor into `./bin/` (gitignored), each
  checked against its SHA-256 first. It runs on macOS and Linux. The
  Makefile uses `./bin/` before the tools on your `PATH`.
- `make check` runs every check, fast to slow, and stops at the first
  failure: `gofmt -l .`, `go vet ./...`, `golangci-lint run`,
  `go mod tidy -diff` (fails when `go.mod` or `go.sum` would change),
  `go test -race ./...`, `go build ./...`, and a dependency check that
  fails when the binary's package graph holds `net`, `net/http`,
  `crypto/tls`, `os/exec`, or `database/sql`.

## License

[MIT](LICENSE).
