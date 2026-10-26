package managers

import (
	"context"

	"setup/internal/core"
)

type Apt struct{}

func (Apt) Name() string { return "apt" }

func (Apt) Setup(context.Context, *core.Env) (core.Plan, error) {
	return core.Plan{Done: []string{"Using apt"}}, nil
}

func (Apt) Installed(ctx context.Context, env *core.Env, pkg string) bool {
	status, _ := env.Run.Output(ctx, "dpkg-query", "-W", "-f=${Status}", pkg)
	return status == "install ok installed"
}

var aptUpdated bool

func (Apt) Install(ctx context.Context, env *core.Env, pkgs ...string) error {
	if !aptUpdated {
		if err := env.Run.Run(ctx, "sudo", "apt-get", "update"); err != nil {
			return err
		}
		aptUpdated = true
	}
	return env.Run.Run(ctx, "sudo", append([]string{"apt-get", "install", "-y"}, pkgs...)...)
}
