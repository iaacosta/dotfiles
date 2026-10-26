package neovim

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"setup/internal/core"
)

func restorePlugins(ctx context.Context, env *core.Env) (core.Plan, error) {
	dir := lazyDir(env)
	if _, err := os.Stat(dir); err != nil {
		return core.Plan{Done: []string{"Plugins not installed yet (lazy.nvim installs them on first launch)"}}, nil
	}
	raw, err := os.ReadFile(env.DotfilesPath("nvim/lazy-lock.json"))
	if err != nil {
		return core.Plan{}, err
	}
	var lock map[string]struct {
		Commit string `json:"commit"`
	}
	if err := json.Unmarshal(raw, &lock); err != nil {
		return core.Plan{}, fmt.Errorf("parse lazy-lock.json: %w", err)
	}

	drifted := 0
	for name, plugin := range lock {
		head, _ := env.Run.Output(ctx, "git", "-C", filepath.Join(dir, name), "rev-parse", "HEAD")
		if head != plugin.Commit {
			drifted++
		}
	}
	if drifted == 0 {
		return core.Plan{Done: []string{"Plugins match lazy-lock.json"}}, nil
	}
	return core.Plan{Actions: []core.Action{{
		Desc: fmt.Sprintf("Restore %d plugin(s) to the versions in lazy-lock.json", drifted),
		Do: func(ctx context.Context, env *core.Env) error {
			return env.Run.Run(ctx, nvimBin(env), "--headless", "+Lazy! restore", "+qa")
		},
	}}}, nil
}

func lazyDir(env *core.Env) string {
	data := os.Getenv("XDG_DATA_HOME")
	if data == "" {
		data = env.HomePath(".local/share")
	}
	return filepath.Join(data, "nvim", "lazy")
}

func nvimBin(env *core.Env) string {
	if path, err := exec.LookPath("nvim"); err == nil {
		return path
	}
	return env.HomePath(".local/bin/nvim")
}
