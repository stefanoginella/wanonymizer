// Command wanonymizer is a placeholder entry point: it prints its build
// version and exits, so the release path has a binary to build. M-002
// replaces it with the real CLI.
package main

import (
	"fmt"
	"os"
	"runtime/debug"
)

// version is set at release time with -ldflags "-X main.version=...".
var version string

// main writes the version line to stdout, whatever the arguments, and
// exits 1 when the write fails.
func main() {
	if _, err := fmt.Fprintf(os.Stdout, "wanonymizer %s\n", buildVersion()); err != nil {
		os.Exit(1)
	}
}

// buildVersion returns the release version, else the module version
// that the build recorded, else "devel".
func buildVersion() string {
	if version != "" {
		return version
	}
	if info, ok := debug.ReadBuildInfo(); ok {
		if v := info.Main.Version; v != "" && v != "(devel)" {
			return v
		}
	}
	return "devel"
}
