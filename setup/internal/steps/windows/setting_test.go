package windows

import (
	"context"
	"slices"
	"testing"

	"setup/internal/fake"
)

func TestSetting(t *testing.T) {
	env, runner, _ := fake.Env(t)
	current := map[string]string{"KeyboardSpeed": "31", "KeyboardDelay": "1"}
	runner.Handler = func(cmd string) (string, error) {
		for name, value := range current {
			if cmd == "reg.exe query "+keyboardKey+" /v "+name {
				return "\r\n" + keyboardKey + "\r\n    " + name + "    REG_SZ    " + value + "\r\n\r\n", nil
			}
		}
		return "", nil
	}

	if plan, _ := setting(keyboardKey, "KeyboardSpeed", "31")(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("matching value: %+v", plan)
	}
	plan, _ := setting(keyboardKey, "KeyboardDelay", "0")(context.Background(), env)
	fake.Apply(t, env, plan)
	want := "reg.exe add " + keyboardKey + " /v KeyboardDelay /t REG_SZ /d 0 /f"
	if !slices.Equal(runner.Calls, []string{want}) {
		t.Fatalf("calls: %v", runner.Calls)
	}
}
