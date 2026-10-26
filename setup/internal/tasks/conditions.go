package tasks

import (
	"context"

	"setup/internal/core"
)

func ByManager(byManager Overrides) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		if task, ok := byManager[env.Manager]; ok {
			return task(ctx, env)
		}
		return core.Plan{}, nil
	}
}

func OnlyMac(tasks ...core.Task) core.Task {
	return when(func(env *core.Env) bool { return env.OS == core.Mac }, tasks)
}

func OnlyWSL(tasks ...core.Task) core.Task {
	return when(func(env *core.Env) bool { return env.WSL }, tasks)
}

func when(applies func(env *core.Env) bool, tasks []core.Task) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		if !applies(env) {
			return core.Plan{}, nil
		}
		return core.Step{Tasks: tasks}.Plan(ctx, env)
	}
}
