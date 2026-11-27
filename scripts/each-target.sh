#!/bin/sh
# Runs a command once per release target (M-001 D-03, D-13), with GOOS
# and GOARCH set and CGO_ENABLED=0, as the release builds. It stops at
# the first target whose run fails, and names it.
# Usage: scripts/each-target.sh <command> [<arg>...]
set -eu

# The release targets: keep this list equal to goos x goarch of the
# build in .goreleaser.yaml.
targets="darwin/amd64 darwin/arm64 linux/amd64 linux/arm64 windows/amd64 windows/arm64"

for target in $targets; do
	echo "--> $target"
	if ! GOOS=${target%/*} GOARCH=${target#*/} CGO_ENABLED=0 "$@"; then
		echo "failed for $target: $*" >&2
		exit 1
	fi
done
