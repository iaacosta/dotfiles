package tasks

import (
	"context"

	"setup/internal/core"
)

type Overrides map[core.Manager]core.Task

func Pkg(name string, custom Overrides) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		if task, ok := custom[env.Manager]; ok {
			return task(ctx, env)
		}
		if env.Manager.Installed(ctx, env, name) {
			return core.Plan{Done: []string{name}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Install " + name + " with " + env.Manager.Name(),
			Do: func(ctx context.Context, env *core.Env) error {
				return env.Manager.Install(ctx, env, name)
			},
		}}}, nil
	}
}
