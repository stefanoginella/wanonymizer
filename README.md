# wanonymizer

> **Work in progress: not ready for use.** There is no release yet,
> and the current binary only prints its version. Do not use it on
> real data.

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
  then run `sudo apt install ./wanonymizer_<version>_linux_<cpu>.deb`.

- Fedora, RHEL, and other RPM systems: download the `.rpm` for your CPU
  (amd64 or arm64), then run
  `sudo dnf install ./wanonymizer_<version>_linux_<cpu>.rpm`.

- Archives: a `.tar.gz` for macOS and Linux and a `.zip` for Windows,
  each for amd64 and arm64, on the releases page. An archive has no top
  folder: it unpacks `LICENSE`, `README.md`, and the binary into the
  folder you unpack it in, where `tar` replaces files of the same name.
  So unpack it into an empty folder:

  ```sh
  mkdir wanonymizer
  tar -xzf wanonymizer_<version>_<os>_<cpu>.tar.gz -C wanonymizer
  ```

  ```powershell
  Expand-Archive wanonymizer_<version>_windows_<cpu>.zip -DestinationPath wanonymizer
  ```

  Then put `wanonymizer` (or `wanonymizer.exe`) on your `PATH`.

- From source, with Go 1.27.4 or later:

  ```sh
  go install github.com/stefanoginella/wanonymizer/cmd/wanonymizer@latest
  ```

A tag with a prerelease suffix, such as `v1.2.0-rc.1`, is published as
a GitHub prerelease, with its files, checksums, and attestations; the
Homebrew cask, like `go install ...@latest`, stays on the last stable
release.

## Verify a download

Each release lists the SHA-256 of every archive and package in
`checksums.txt`. Download it next to your file, then run:

```sh
sha256sum --ignore-missing --check checksums.txt         # Linux
shasum -a 256 --ignore-missing --check checksums.txt     # macOS
```

On Windows, in PowerShell, print the file's SHA-256 and its line of
`checksums.txt`; the two hashes must be equal:

```powershell
(Get-FileHash -Algorithm SHA256 <file>).Hash.ToLower()
Select-String -SimpleMatch <file> checksums.txt
```

Each file of `checksums.txt` also has a GitHub build provenance
attestation. With the [GitHub CLI](https://cli.github.com/), this
command checks that the attestation of your file was signed by the
`release.yml` workflow of this repository:

```sh
gh attestation verify <file> --repo stefanoginella/wanonymizer \
  --signer-workflow stefanoginella/wanonymizer/.github/workflows/release.yml
```

## macOS: unsigned binaries

The macOS binaries are not signed or notarized. The Homebrew cask
removes the quarantine attribute itself. For a direct download, remove
it before the first run, or macOS blocks the binary:

```sh
xattr -dr com.apple.quarantine <path to the binary>
```

`<path to the binary>` is the unpacked `wanonymizer` binary, as in the
cask. Run it on the binary only: on a folder, it would also remove the
attribute from every other download in that folder.

## Development

You need Go 1.27.4 or later, `make`, and `curl`. On Linux and Windows,
you also need a C compiler (such as gcc) for `go test -race`: the race
detector needs cgo there. macOS needs none.

- `make tools` downloads the pinned versions of golangci-lint,
  GoReleaser, actionlint, and zizmor into `./bin/` (gitignored), each
  checked against its SHA-256 first, and replaces the copies that are
  there. It runs on macOS and Linux. The Makefile uses `./bin/` before
  the tools on your `PATH`.
- `make check` runs every check, fast to slow, and stops at the first
  failure: `gofmt -l` on the `.go` files that `./...` walks,
  `go vet ./...`, `golangci-lint run`, `go mod tidy -diff` (fails when
  `go.mod` or `go.sum` would change), `go test -race ./...`,
  `go build -o /dev/null ./...`, and a dependency check that fails when
  the binary's package graph holds `net`, `net/http`, `crypto/tls`,
  `os/exec`, or `database/sql`. `go vet`, `golangci-lint`, and the
  dependency check run once per release target (macOS, Linux, and
  Windows, each on amd64 and arm64), with `CGO_ENABLED=0` as the
  release builds, so code built only for another system is checked
  too.
- `make snapshot` builds the release into `./dist/` (archives,
  packages, checksums, and the cask) and publishes nothing.

## License

[MIT](LICENSE).
