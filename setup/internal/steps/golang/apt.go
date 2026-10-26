package golang

import (
	"context"
	"strings"

	"setup/internal/core"
	"setup/internal/tasks"
)

var goRelease = tasks.Release{
	Name:        "go",
	URL:         "https://go.dev/dl/{version}.linux-{arch}.tar.gz",
	Version:     latestGo,
	Bins:        []string{"bin/go", "bin/gofmt"},
	VersionArgs: []string{"version"},
}

func latestGo(ctx context.Context, env *core.Env) (string, error) {
	out, err := env.Run.Output(ctx, "curl", "-fsSL", "https://go.dev/VERSION?m=text")
	return strings.Split(out, "\n")[0], err
}
