package fake

import (
	"context"
	"strings"
	"testing"

	"setup/internal/core"
)

type Runner struct {
	Calls   []string
	Handler func(cmd string) (string, error)
}

func (r *Runner) Run(_ context.Context, name string, args ...string) error {
	cmd := strings.Join(append([]string{name}, args...), " ")
	r.Calls = append(r.Calls, cmd)
	_, err := r.handle(cmd)
	return err
}

func (r *Runner) Output(_ context.Context, name string, args ...string) (string, error) {
	return r.handle(strings.Join(append([]string{name}, args...), " "))
}

func (r *Runner) handle(cmd string) (string, error) {
	if r.Handler == nil {
		return "", nil
	}
	return r.Handler(cmd)
}

type Manager struct {
	Packages map[string]bool
	Installs [][]string
}

func (m *Manager) Name() string { return "fake" }

func (m *Manager) Setup(context.Context, *core.Env) (core.Plan, error) { return core.Plan{}, nil }

func (m *Manager) Installed(_ context.Context, _ *core.Env, pkg string) bool { return m.Packages[pkg] }

func (m *Manager) Install(_ context.Context, _ *core.Env, pkgs ...string) error {
	m.Installs = append(m.Installs, pkgs)
	for _, pkg := range pkgs {
		m.Packages[pkg] = true
	}
	return nil
}

func Env(t *testing.T) (*core.Env, *Runner, *Manager) {
	t.Helper()
	runner, manager := &Runner{}, &Manager{Packages: map[string]bool{}}
	return &core.Env{OS: core.Mac, Manager: manager, Home: t.TempDir(), Dotfiles: t.TempDir(), Run: runner}, runner, manager
}

func Apply(t *testing.T, env *core.Env, plan core.Plan) {
	t.Helper()
	for _, action := range plan.Actions {
		if err := action.Do(context.Background(), env); err != nil {
			t.Fatalf("%s: %v", action.Desc, err)
		}
	}
}
