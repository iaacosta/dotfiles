package shell

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"setup/internal/core"
)

const stub = `# Machine-local zshrc.
#
# Shared shell config lives in the dotfiles repo and is sourced below.
# Put anything machine-specific (PATH additions from brew, sdkman, nvm,
# bun, android sdk, etc.) AFTER the source line. Installers that append
# to ~/.zshrc will land here and won't dirty the dotfiles repo.
source "%s"
`

func zshrcStub(_ context.Context, env *core.Env) (core.Plan, error) {
	path := env.HomePath(".zshrc")
	info, err := os.Lstat(path)
	exists := err == nil
	if exists && info.Mode().IsRegular() {
		return core.Plan{Done: []string{"~/.zshrc stub exists"}}, nil
	}
	shared := sharedZshrc(env)
	desc := "Create ~/.zshrc stub that sources " + shared
	if exists {
		desc += " (backs up the existing one)"
	}
	return core.Plan{Actions: []core.Action{{
		Desc: desc,
		Do: func(context.Context, *core.Env) error {
			if exists {
				if err := os.Rename(path, path+".backup."+time.Now().Format("20060102150405")); err != nil {
					return err
				}
			}
			return os.WriteFile(path, fmt.Appendf(nil, stub, shared), 0o644)
		},
	}}}, nil
}

func sharedZshrc(env *core.Env) string {
	path := env.DotfilesPath(".zshrc")
	if rel, err := filepath.Rel(env.Home, path); err == nil && !strings.HasPrefix(rel, "..") {
		return "$HOME/" + rel
	}
	return path
}
