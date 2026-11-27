#!/bin/sh
# Fails when the shipped binary's package graph holds a denied package
# (M-001 D-08: no network, read-only). It reads the graph of the GOOS,
# GOARCH, and CGO_ENABLED of its environment: make check runs it once
# per release target and once on the host through
# scripts/each-target.sh. Test code is outside the graph: go list runs
# without -test.
set -eu

main_pkg=./cmd/wanonymizer
denied="net net/http crypto/tls os/exec database/sql"

target=$(go env GOOS)/$(go env GOARCH)
graph=$(go list -deps -f '{{.ImportPath}}: {{join .Imports " "}}' "$main_pkg")

status=0
for pkg in $denied; do
	if printf '%s\n' "$graph" | grep -q "^$pkg:"; then
		importers=$(printf '%s\n' "$graph" |
			awk -v p="$pkg" '{ for (i = 2; i <= NF; i++) if ($i == p) { sub(/:$/, "", $1); print $1 } }' |
			tr '\n' ' ')
		echo "denied package on $target: $pkg (imported by: ${importers% })" >&2
		status=1
	fi
done

if [ "$status" -eq 0 ]; then
	echo "no denied package in the graph of $main_pkg on $target"
fi
exit "$status"
