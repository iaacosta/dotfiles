package tasks

import (
	"context"
	"os/exec"
	"path/filepath"

	"setup/internal/core"
)

func InstallLatest(language, tool string, latest func(ctx context.Context, env *core.Env, bin string) (string, error)) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		bin := toolBin(env, tool)
		if versions, _ := env.Run.Output(ctx, bin, "versions", "--bare"); versions != "" {
			global, _ := env.Run.Output(ctx, bin, "global")
			return core.Plan{Done: []string{language + " " + global + " (global)"}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Install the latest " + language + " with " + tool + " and set it as global",
			Do: func(ctx context.Context, env *core.Env) error {
				bin := toolBin(env, tool)
				version, err := latest(ctx, env, bin)
				if err != nil {
					return err
				}
				if err := env.Run.Run(ctx, bin, "install", "--skip-existing", version); err != nil {
					return err
				}
				return env.Run.Run(ctx, bin, "global", version)
			},
		}}}, nil
	}
}

func toolBin(env *core.Env, tool string) string {
	if path, err := exec.LookPath(tool); err == nil {
		return path
	}
	return env.HomePath(filepath.Join("."+tool, "bin", tool))
}
