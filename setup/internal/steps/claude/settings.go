package claude

import (
	"context"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"

	"setup/internal/core"
)

var statusLine = map[string]any{"type": "command", "command": "~/.claude/statusline.sh"}

func statusLineSetting(_ context.Context, env *core.Env) (core.Plan, error) {
	path := env.HomePath(".claude/settings.json")
	settings := map[string]any{}
	raw, err := os.ReadFile(path)
	switch {
	case err == nil:
		if err := json.Unmarshal(raw, &settings); err != nil {
			return core.Plan{}, err
		}
	case !errors.Is(err, os.ErrNotExist):
		return core.Plan{}, err
	}
	if _, ok := settings["statusLine"]; ok {
		return core.Plan{Done: []string{"statusLine configured in settings.json"}}, nil
	}
	return core.Plan{Actions: []core.Action{{
		Desc: "Add statusLine to ~/.claude/settings.json",
		Do: func(context.Context, *core.Env) error {
			settings["statusLine"] = statusLine
			out, err := json.MarshalIndent(settings, "", "  ")
			if err != nil {
				return err
			}
			if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
				return err
			}
			return os.WriteFile(path, append(out, '\n'), 0o600)
		},
	}}}, nil
}
