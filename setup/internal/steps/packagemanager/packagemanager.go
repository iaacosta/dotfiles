package packagemanager

import (
	"context"

	"setup/internal/core"
)

func New() core.Step {
	return core.Step{Name: "Package manager", Tasks: []core.Task{setup}}
}

func setup(ctx context.Context, env *core.Env) (core.Plan, error) {
	return env.Manager.Setup(ctx, env)
}
