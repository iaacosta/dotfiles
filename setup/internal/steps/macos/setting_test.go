package macos

import (
	"context"
	"slices"
	"testing"

	"setup/internal/fake"
)

func TestSetting(t *testing.T) {
	env, runner, _ := fake.Env(t)
	current := map[string]string{"KeyRepeat": "1", "ApplePressAndHoldEnabled": "1"}
	runner.Handler = func(cmd string) (string, error) {
		for key, value := range current {
			if cmd == "defaults read NSGlobalDomain "+key {
				return value, nil
			}
		}
		return "", nil
	}

	if plan, _ := setting("NSGlobalDomain", "KeyRepeat", "int", "1")(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("matching int: %+v", plan)
	}
	plan, _ := setting("NSGlobalDomain", "ApplePressAndHoldEnabled", "bool", "false")(context.Background(), env)
	fake.Apply(t, env, plan)
	if !slices.Equal(runner.Calls, []string{"defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false"}) {
		t.Fatalf("calls: %v", runner.Calls)
	}

	current["ApplePressAndHoldEnabled"] = "0"
	if plan, _ := setting("NSGlobalDomain", "ApplePressAndHoldEnabled", "bool", "false")(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("bool false reads back as 0: %+v", plan)
	}
}
