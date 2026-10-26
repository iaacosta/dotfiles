package tasks_test

import (
	"context"
	"slices"
	"testing"

	"setup/internal/core"
	"setup/internal/fake"
	"setup/internal/tasks"
)

func TestPkg(t *testing.T) {
	env, _, manager := fake.Env(t)
	ctx := context.Background()

	plan, _ := tasks.Pkg("tmux", nil)(ctx, env)
	if len(plan.Actions) != 1 {
		t.Fatalf("missing package should need an install, got %+v", plan)
	}
	fake.Apply(t, env, plan)

	plan, _ = tasks.Pkg("tmux", nil)(ctx, env)
	if !slices.Equal(plan.Done, []string{"tmux"}) || len(manager.Installs) != 1 {
		t.Fatalf("got %+v, installs %v", plan, manager.Installs)
	}
}

func TestPkgOverride(t *testing.T) {
	env, _, manager := fake.Env(t)
	custom := func(context.Context, *core.Env) (core.Plan, error) {
		return core.Plan{Done: []string{"custom"}}, nil
	}

	plan, _ := tasks.Pkg("neovim", tasks.Overrides{env.Manager: custom})(context.Background(), env)
	if !slices.Equal(plan.Done, []string{"custom"}) || len(manager.Installs) != 0 {
		t.Fatalf("override wasn't used: %+v", plan)
	}
}

func TestPkgsBatchesMissing(t *testing.T) {
	env, _, manager := fake.Env(t)
	manager.Packages["fzf"] = true

	plan, _ := tasks.Pkgs("fzf", "ripgrep", "gh")(context.Background(), env)
	fake.Apply(t, env, plan)

	if !slices.Equal(plan.Done, []string{"fzf"}) || len(manager.Installs) != 1 || !slices.Equal(manager.Installs[0], []string{"ripgrep", "gh"}) {
		t.Fatalf("plan %+v, installs %v", plan, manager.Installs)
	}
}
