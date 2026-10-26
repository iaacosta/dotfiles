package tasks_test

import (
	"context"
	"testing"

	"setup/internal/core"
	"setup/internal/fake"
	"setup/internal/managers"
	"setup/internal/tasks"
)

func doneTask(line string) core.Task {
	return func(context.Context, *core.Env) (core.Plan, error) {
		return core.Plan{Done: []string{line}}, nil
	}
}

func TestOnlyMacAndOnlyWSL(t *testing.T) {
	cases := []struct {
		name             string
		os               core.OS
		wsl              bool
		wantMac, wantWSL bool
	}{
		{"macOS", core.Mac, false, true, false},
		{"Ubuntu", core.Linux, false, false, false},
		{"WSL", core.Linux, true, false, true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, _, _ := fake.Env(t)
			env.OS, env.WSL = tc.os, tc.wsl
			mac, _ := tasks.OnlyMac(doneTask("mac"))(context.Background(), env)
			wsl, _ := tasks.OnlyWSL(doneTask("wsl"))(context.Background(), env)
			if (len(mac.Done) == 1) != tc.wantMac || (len(wsl.Done) == 1) != tc.wantWSL {
				t.Fatalf("mac %+v, wsl %+v", mac, wsl)
			}
		})
	}
}

func TestByManager(t *testing.T) {
	env, _, _ := fake.Env(t)
	byManager := tasks.ByManager(tasks.Overrides{env.Manager: doneTask("mine"), managers.Apt{}: doneTask("apt")})

	plan, _ := byManager(context.Background(), env)
	if len(plan.Done) != 1 || plan.Done[0] != "mine" {
		t.Fatalf("got %+v", plan)
	}

	env.Manager = managers.Brew{}
	if plan, _ := byManager(context.Background(), env); len(plan.Done)+len(plan.Actions) != 0 {
		t.Fatalf("unlisted manager should do nothing, got %+v", plan)
	}
}
