package shell

import (
	"context"
	"os"
	"os/exec"
	"path/filepath"

	"setup/internal/core"
)

func loginShell(context.Context, *core.Env) (core.Plan, error) {
	if filepath.Base(os.Getenv("SHELL")) == "zsh" {
		return core.Plan{Done: []string{"Login shell is zsh"}}, nil
	}
	return core.Plan{Actions: []core.Action{{
		Desc: "Change login shell to zsh",
		Do: func(ctx context.Context, env *core.Env) error {
			zsh, err := exec.LookPath("zsh")
			if err != nil {
				return err
			}
			return env.Run.Run(ctx, "chsh", "-s", zsh)
		},
	}}}, nil
}
