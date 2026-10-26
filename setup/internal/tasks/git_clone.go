package tasks

import (
	"context"
	"os"
	"path/filepath"

	"setup/internal/core"
)

func GitClone(url, dest string) core.Task {
	return func(_ context.Context, env *core.Env) (core.Plan, error) {
		path := env.HomePath(dest)
		if info, err := os.Stat(path); err == nil && info.IsDir() {
			return core.Plan{Done: []string{"~/" + dest + " cloned"}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Clone " + url + " into ~/" + dest,
			Do: func(ctx context.Context, env *core.Env) error {
				if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
					return err
				}
				return env.Run.Run(ctx, "git", "clone", url, path)
			},
		}}}, nil
	}
}
