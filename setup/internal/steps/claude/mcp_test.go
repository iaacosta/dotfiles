package claude

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
)

func TestUserMCPServers(t *testing.T) {
	cases := []struct {
		name          string
		existing      string
		token         string
		claudeMissing bool
		wantCalls     []string
		wantWarning   string
	}{
		{
			name:  "fresh machine with token",
			token: "secret",
			wantCalls: []string{
				"claude mcp add --scope user --transport http linear-server https://mcp.linear.app/mcp",
				"claude mcp add --scope user --transport http excalidraw https://api.excalidraw.com/api/v1/mcp --header Authorization: Bearer secret",
			},
		},
		{
			name:        "fresh machine without token",
			wantCalls:   []string{"claude mcp add --scope user --transport http linear-server https://mcp.linear.app/mcp"},
			wantWarning: "EXCALIDRAW_API_KEY",
		},
		{
			name:     "already configured",
			existing: `{"numStartups": 3, "mcpServers": {"linear-server": {}, "excalidraw": {}}}`,
		},
		{
			name:          "claude not installed",
			token:         "secret",
			claudeMissing: true,
			wantWarning:   "Install Claude Code",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, runner, _ := fake.Env(t)
			t.Setenv("EXCALIDRAW_API_KEY", tc.token)
			if tc.existing != "" {
				os.WriteFile(filepath.Join(env.Home, ".claude.json"), []byte(tc.existing), 0o600)
			}
			if tc.claudeMissing {
				runner.Handler = func(string) (string, error) { return "", errors.New("not found") }
			}

			plan, err := userMCPServers(context.Background(), env)
			if err != nil {
				t.Fatal(err)
			}
			fake.Apply(t, env, plan)

			if strings.Join(runner.Calls, "\n") != strings.Join(tc.wantCalls, "\n") {
				t.Errorf("calls:\n%s\nwant:\n%s", strings.Join(runner.Calls, "\n"), strings.Join(tc.wantCalls, "\n"))
			}
			if warnings := strings.Join(plan.Warnings, "\n"); tc.wantWarning != "" && !strings.Contains(warnings, tc.wantWarning) {
				t.Errorf("warnings %q, want %q", warnings, tc.wantWarning)
			}
			for _, action := range plan.Actions {
				if strings.Contains(action.Desc, "secret") {
					t.Errorf("token leaked into %q", action.Desc)
				}
			}
		})
	}
}
