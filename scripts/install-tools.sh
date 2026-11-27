#!/bin/sh
# Installs the pinned dev tools into bin/ at the repository root, from
# their release binaries, each verified against its SHA-256 before it is
# unpacked. Each run downloads and replaces every tool.
# Usage: scripts/install-tools.sh
set -eu

# Pinned versions: bump by hand, after a check of each releases page.
GOLANGCI_LINT_VERSION=2.15.0
# GORELEASER_VERSION is also the goreleaser-action `version:` (with a v)
# of .github/workflows/release.yml: change both together; the CI release
# dry run fails when they differ.
GORELEASER_VERSION=2.20.3
ACTIONLINT_VERSION=1.7.12
# zizmor publishes no checksum file: these are the SHA-256 digests that
# GitHub records for the v1.33.1 release assets. Update them with the
# version: gh release view v<version> --repo zizmorcore/zizmor --json assets
ZIZMOR_VERSION=1.33.1
ZIZMOR_SHA256_DARWIN_ARM64=68516d45723aac36e9c87c47d56e8418009fcb919c6ceb44514d85b9d0c1c011
ZIZMOR_SHA256_DARWIN_AMD64=8b609d38243c6dd6ddd29bf93d02d886eb507383fe4735b1cde73e66e4de4f29
ZIZMOR_SHA256_LINUX_ARM64=aa487c792a7cbbe86e4f8dccd3b66de33b3b51813c090aaa0842d7ea08a3fc35
ZIZMOR_SHA256_LINUX_AMD64=3e6a301c7a820a2501915f5a9de8c0486da82bdec7965f068477538a98743d43

bin_dir=$(cd "$(dirname "$0")/.." && pwd)/bin
mkdir -p "$bin_dir"

case $(uname -s) in
Darwin) os=darwin ;;
Linux) os=linux ;;
*) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case $(uname -m) in
arm64 | aarch64) arch=arm64 ;;
x86_64 | amd64) arch=amd64 ;;
*) echo "unsupported CPU: $(uname -m)" >&2; exit 1 ;;
esac

if command -v sha256sum >/dev/null 2>&1; then
	sha256() { sha256sum "$1" | awk '{ print $1 }'; }
else
	sha256() { shasum -a 256 "$1" | awk '{ print $1 }'; }
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# fetch <url> <file>
fetch() {
	curl --fail --silent --show-error --location --proto '=https' \
		--retry 3 --output "$2" "$1"
}

# verify <file> <expected sha256>
verify() {
	actual=$(sha256 "$1")
	if [ -z "$2" ] || [ "$actual" != "$2" ]; then
		echo "checksum mismatch for $(basename "$1"): got $actual, want ${2:-none}" >&2
		exit 1
	fi
}

# published_sum <checksums file> <asset name>
published_sum() {
	awk -v n="$2" '$2 == n || $2 == "*" n { print $1 }' "$1"
}

# place <tool> <version> <extracted binary>
place() {
	install -m 0755 "$3" "$bin_dir/$1"
	echo "installed $1 $2"
}

install_golangci_lint() {
	v=$GOLANGCI_LINT_VERSION
	base=https://github.com/golangci/golangci-lint/releases/download/v$v
	name=golangci-lint-$v-$os-$arch
	d=$work/golangci-lint
	mkdir -p "$d"
	fetch "$base/golangci-lint-$v-checksums.txt" "$d/checksums.txt"
	fetch "$base/$name.tar.gz" "$d/$name.tar.gz"
	verify "$d/$name.tar.gz" "$(published_sum "$d/checksums.txt" "$name.tar.gz")"
	tar -xzf "$d/$name.tar.gz" -C "$d"
	place golangci-lint "$v" "$d/$name/golangci-lint"
}

install_goreleaser() {
	v=$GORELEASER_VERSION
	base=https://github.com/goreleaser/goreleaser/releases/download/v$v
	case $os in darwin) gos=Darwin ;; linux) gos=Linux ;; esac
	case $arch in arm64) garch=arm64 ;; amd64) garch=x86_64 ;; esac
	name=goreleaser_${gos}_$garch.tar.gz
	d=$work/goreleaser
	mkdir -p "$d"
	fetch "$base/checksums.txt" "$d/checksums.txt"
	fetch "$base/$name" "$d/$name"
	verify "$d/$name" "$(published_sum "$d/checksums.txt" "$name")"
	tar -xzf "$d/$name" -C "$d" goreleaser
	place goreleaser "$v" "$d/goreleaser"
}

install_actionlint() {
	v=$ACTIONLINT_VERSION
	base=https://github.com/rhysd/actionlint/releases/download/v$v
	name=actionlint_${v}_${os}_$arch.tar.gz
	d=$work/actionlint
	mkdir -p "$d"
	fetch "$base/actionlint_${v}_checksums.txt" "$d/checksums.txt"
	fetch "$base/$name" "$d/$name"
	verify "$d/$name" "$(published_sum "$d/checksums.txt" "$name")"
	tar -xzf "$d/$name" -C "$d" actionlint
	place actionlint "$v" "$d/actionlint"
}

install_zizmor() {
	v=$ZIZMOR_VERSION
	base=https://github.com/zizmorcore/zizmor/releases/download/v$v
	case $arch in arm64) zarch=aarch64 ;; amd64) zarch=x86_64 ;; esac
	case $os in darwin) ztarget=apple-darwin ;; linux) ztarget=unknown-linux-gnu ;; esac
	case $os-$arch in
	darwin-arm64) want=$ZIZMOR_SHA256_DARWIN_ARM64 ;;
	darwin-amd64) want=$ZIZMOR_SHA256_DARWIN_AMD64 ;;
	linux-arm64) want=$ZIZMOR_SHA256_LINUX_ARM64 ;;
	linux-amd64) want=$ZIZMOR_SHA256_LINUX_AMD64 ;;
	esac
	name=zizmor-$zarch-$ztarget.tar.gz
	d=$work/zizmor
	mkdir -p "$d"
	fetch "$base/$name" "$d/$name"
	verify "$d/$name" "$want"
	tar -xzf "$d/$name" -C "$d"
	place zizmor "$v" "$(find "$d" -type f -name zizmor | head -n 1)"
}

install_golangci_lint
install_goreleaser
install_actionlint
install_zizmor
