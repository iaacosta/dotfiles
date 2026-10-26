package tasks

import (
	"context"
	"os"
	"path/filepath"
	"time"

	"setup/internal/core"
)

func Symlink(target, path string) core.Task {
	return func(_ context.Context, env *core.Env) (core.Plan, error) {
		target, path := env.DotfilesPath(target), env.HomePath(path)
		info, err := os.Lstat(path)
		exists := err == nil
		isLink := exists && info.Mode()&os.ModeSymlink != 0

		if current, _ := os.Readlink(path); isLink && current == target {
			return core.Plan{Done: []string{"~/" + rel(env, path) + " linked"}}, nil
		}
		desc := "Link ~/" + rel(env, path) + " -> " + target
		if exists && !isLink {
			desc += " (backs up the existing one)"
		}
		return core.Plan{Actions: []core.Action{{
			Desc: desc,
			Do: func(context.Context, *core.Env) error {
				if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
					return err
				}
				var err error
				switch {
				case isLink:
					err = os.Remove(path)
				case exists:
					err = os.Rename(path, path+".backup."+time.Now().Format("20060102150405"))
				}
				if err != nil {
					return err
				}
				return os.Symlink(target, path)
			},
		}}}, nil
	}
}

func rel(env *core.Env, path string) string {
	r, _ := filepath.Rel(env.Home, path)
	return r
}
