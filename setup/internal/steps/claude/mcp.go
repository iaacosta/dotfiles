package claude

import (
	"context"
	"encoding/json"
	"errors"
	"os"

	"setup/internal/core"
)

type mcpServer struct {
	name string
	url  string
	// Environment variable holding a bearer token, read when setup runs so it never lands in the repo
	tokenEnv string
}

var mcpServers = []mcpServer{
	{name: "linear-server", url: "https://mcp.linear.app/mcp"},
	{name: "excalidraw", url: "https://api.excalidraw.com/api/v1/mcp", tokenEnv: "EXCALIDRAW_API_KEY"},
}

func userMCPServers(ctx context.Context, env *core.Env) (core.Plan, error) {
	// User-scoped servers live in ~/.claude.json; reading it avoids `claude mcp get` health-checking each one
	var config struct {
		MCPServers map[string]any `json:"mcpServers"`
	}
	raw, err := os.ReadFile(env.HomePath(".claude.json"))
	switch {
	case err == nil:
		if err := json.Unmarshal(raw, &config); err != nil {
			return core.Plan{}, err
		}
	case !errors.Is(err, os.ErrNotExist):
		return core.Plan{}, err
	}

	var plan core.Plan
	for _, server := range mcpServers {
		if _, ok := config.MCPServers[server.name]; ok {
			plan.Done = append(plan.Done, server.name+" MCP server configured")
			continue
		}
		args := []string{"mcp", "add", "--scope", "user", "--transport", "http", server.name, server.url}
		if server.tokenEnv != "" {
			token := os.Getenv(server.tokenEnv)
			if token == "" {
				plan.Warnings = append(plan.Warnings, "Set "+server.tokenEnv+" and re-run to add the "+server.name+" MCP server")
				continue
			}
			args = append(args, "--header", "Authorization: Bearer "+token)
		}
		plan.Actions = append(plan.Actions, core.Action{
			Desc: "Add the " + server.name + " MCP server to Claude Code",
			Do: func(ctx context.Context, env *core.Env) error {
				return env.Run.Run(ctx, "claude", args...)
			},
		})
	}

	if len(plan.Actions) > 0 {
		if _, err := env.Run.Output(ctx, "claude", "--version"); err != nil {
			plan.Warnings = append(plan.Warnings, "Install Claude Code and re-run to add its MCP servers")
			plan.Actions = nil
		}
	}
	return plan, nil
}
