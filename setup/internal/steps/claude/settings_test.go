package claude

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
)

func TestSettingsDefaults(t *testing.T) {
	cases := []struct {
		name     string
		existing string
	}{
		{"no settings file", ""},
		{"settings without defaults", `{"model": "opus", "permissions": {"allow": ["Bash(ls:*)"]}}`},
		{"settings with a different tui", `{"model": "opus", "tui": "default"}`},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, _, _ := fake.Env(t)
			path := filepath.Join(env.Home, ".claude/settings.json")
			if tc.existing != "" {
				os.MkdirAll(filepath.Dir(path), 0o755)
				os.WriteFile(path, []byte(tc.existing), 0o600)
			}

			plan, err := settingsDefaults(context.Background(), env)
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
			wantTUI := "fullscreen"
			if strings.Contains(tc.existing, `"tui"`) {
				wantTUI = "default"
			}
			if settings["tui"] != wantTUI {
				t.Fatalf("tui: want %q in %s", wantTUI, raw)
			}
			if tc.existing != "" && settings["model"] != "opus" {
				t.Fatalf("lost existing settings: %s", raw)
			}
			if plan, _ := settingsDefaults(context.Background(), env); len(plan.Actions) != 0 {
				t.Fatalf("second run: %+v", plan)
			}
		})
	}
}
