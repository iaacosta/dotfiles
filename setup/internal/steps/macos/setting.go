package macos

import (
	"context"

	"setup/internal/core"
)

func setting(domain, key, kind, value string) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		current, _ := env.Run.Output(ctx, "defaults", "read", domain, key)
		if current == readValue(value) {
			return core.Plan{Done: []string{key + " = " + value}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Set " + key + " to " + value + " (log out to apply)",
			Do: func(ctx context.Context, env *core.Env) error {
				return env.Run.Run(ctx, "defaults", "write", domain, key, "-"+kind, value)
			},
		}}}, nil
	}
}

func readValue(value string) string {
	switch value {
	case "true":
		return "1"
	case "false":
		return "0"
	}
	return value
}
