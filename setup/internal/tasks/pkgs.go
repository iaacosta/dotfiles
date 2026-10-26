package tasks

import (
	"context"
	"strings"

	"setup/internal/core"
)

func Pkgs(names ...string) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		var plan core.Plan
		var missing []string
		for _, name := range names {
			if env.Manager.Installed(ctx, env, name) {
				plan.Done = append(plan.Done, name)
			} else {
				missing = append(missing, name)
			}
		}
		if len(missing) > 0 {
			plan.Actions = append(plan.Actions, core.Action{
				Desc: "Install " + strings.Join(missing, ", ") + " with " + env.Manager.Name(),
				Do: func(ctx context.Context, env *core.Env) error {
					return env.Manager.Install(ctx, env, missing...)
				},
			})
		}
		return plan, nil
	}
}
