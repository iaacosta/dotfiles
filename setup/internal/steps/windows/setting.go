package windows

import (
	"context"
	"strings"

	"setup/internal/core"
)

// setting writes a per-user REG_SZ value, which needs no admin rights.
func setting(key, name, value string) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		out, _ := env.Run.Output(ctx, "reg.exe", "query", key, "/v", name)
		if current(out, name) == value {
			return core.Plan{Done: []string{name + " = " + value}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Set " + name + " to " + value + " (sign out of Windows to apply)",
			Do: func(ctx context.Context, env *core.Env) error {
				return env.Run.Run(ctx, "reg.exe", "add", key, "/v", name, "/t", "REG_SZ", "/d", value, "/f")
			},
		}}}, nil
	}
}

// current reads the value from `reg query` output, whose matching line looks
// like "    KeyboardDelay    REG_SZ    1".
func current(out, name string) string {
	for _, line := range strings.Split(out, "\n") {
		if fields := strings.Fields(line); len(fields) == 3 && fields[0] == name {
			return fields[2]
		}
	}
	return ""
}
