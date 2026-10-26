package claude

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"setup/internal/fake"
)

func TestStatusLineSetting(t *testing.T) {
	cases := []struct {
		name     string
		existing string
	}{
		{"no settings file", ""},
		{"settings without statusLine", `{"model": "opus", "permissions": {"allow": ["Bash(ls:*)"]}}`},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, _, _ := fake.Env(t)
			path := filepath.Join(env.Home, ".claude/settings.json")
			if tc.existing != "" {
				os.MkdirAll(filepath.Dir(path), 0o755)
				os.WriteFile(path, []byte(tc.existing), 0o600)
			}

			plan, err := statusLineSetting(context.Background(), env)
			if err != nil {
				t.Fatal(err)
			}
			fake.Apply(t, env, plan)

			var settings map[string]any
			raw, _ := os.ReadFile(path)
			if err := json.Unmarshal(raw, &settings); err != nil {
				t.Fatal(err)
			}
			if settings["statusLine"].(map[string]any)["command"] != "~/.claude/statusline.sh" {
				t.Fatalf("settings: %s", raw)
			}
			if tc.existing != "" && settings["model"] != "opus" {
				t.Fatalf("lost existing settings: %s", raw)
			}
			if plan, _ := statusLineSetting(context.Background(), env); len(plan.Actions) != 0 {
				t.Fatalf("second run: %+v", plan)
			}
		})
	}
}
