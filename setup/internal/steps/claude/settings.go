package claude

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"setup/internal/core"
)

// Settings added to ~/.claude/settings.json when missing; existing values are kept
var defaultSettings = map[string]any{
	"statusLine": map[string]any{"type": "command", "command": "~/.claude/statusline.sh"},
	"tui":        "fullscreen",
}

func settingsDefaults(_ context.Context, env *core.Env) (core.Plan, error) {
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

	var plan core.Plan
	var missing []string
	for _, key := range slices.Sorted(maps.Keys(defaultSettings)) {
		if _, ok := settings[key]; ok {
			plan.Done = append(plan.Done, key+" configured in settings.json")
		} else {
			missing = append(missing, key)
		}
	}
	if len(missing) == 0 {
		return plan, nil
	}
	plan.Actions = []core.Action{{
		Desc: fmt.Sprintf("Add %s to ~/.claude/settings.json", strings.Join(missing, ", ")),
		Do: func(context.Context, *core.Env) error {
			for _, key := range missing {
				settings[key] = defaultSettings[key]
			}
			out, err := json.MarshalIndent(settings, "", "  ")
			if err != nil {
				return err
			}
			if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
				return err
			}
			return os.WriteFile(path, append(out, '\n'), 0o600)
		},
	}}
	return plan, nil
}
