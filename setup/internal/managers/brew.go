package managers

import (
	"context"
	"os"
	"os/exec"
	"path/filepath"

	"setup/internal/core"
)

const (
	brewPrefix    = "/opt/homebrew"
	brewInstaller = "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
)

var brewBin = filepath.Join(brewPrefix, "bin", "brew")

type Brew struct{}

func (Brew) Name() string { return "brew" }

func (Brew) Setup(ctx context.Context, env *core.Env) (core.Plan, error) {
	if _, err := os.Stat(brewBin); err != nil {
		return core.Plan{Actions: []core.Action{{Desc: "Install Homebrew", Do: installBrew}}}, nil
	}
	plan := core.Plan{Done: []string{"Homebrew installed"}}
	if _, err := exec.LookPath("brew"); err != nil {
		plan.Actions = append(plan.Actions, core.Action{Desc: "Add Homebrew to PATH for this run", Do: addBrewToPath})
	}
	return plan, nil
}

func installBrew(ctx context.Context, env *core.Env) error {
	script, err := env.Run.Output(ctx, "curl", "-fsSL", brewInstaller)
	if err != nil {
		return err
	}
	if err := env.Run.Run(ctx, "/bin/bash", "-c", script); err != nil {
		return err
	}
	return addBrewToPath(ctx, env)
}

func addBrewToPath(context.Context, *core.Env) error {
	bin, sbin := filepath.Join(brewPrefix, "bin"), filepath.Join(brewPrefix, "sbin")
	return os.Setenv("PATH", bin+":"+sbin+":"+os.Getenv("PATH"))
}

func (Brew) Installed(ctx context.Context, env *core.Env, pkg string) bool {
	_, err := env.Run.Output(ctx, brewBin, "list", pkg)
	return err == nil
}

func (Brew) Install(ctx context.Context, env *core.Env, pkgs ...string) error {
	return env.Run.Run(ctx, brewBin, append([]string{"install"}, pkgs...)...)
}
