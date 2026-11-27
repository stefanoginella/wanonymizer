// Command wanonymizer is a placeholder entry point: it prints its build
// version and exits, so the release path has a binary to build. M-002
// replaces it with the real CLI.
package main

import (
	"fmt"
	"io"
	"os"
	"runtime/debug"
)

// version is set at release time with -ldflags "-X main.version=...".
var version string

func main() {
	if err := run(os.Stdout); err != nil {
		os.Exit(1)
	}
}

// run writes the version line to w, whatever the arguments.
func run(w io.Writer) error {
	_, err := fmt.Fprintf(w, "wanonymizer %s\n", buildVersion())
	return err
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
