package core

import "context"

type Manager interface {
	Name() string
	Setup(ctx context.Context, env *Env) (Plan, error)
	Installed(ctx context.Context, env *Env, pkg string) bool
	Install(ctx context.Context, env *Env, pkgs ...string) error
}
