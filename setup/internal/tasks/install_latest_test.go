package tasks_test

import (
	"context"
	"slices"
	"strings"
	"testing"

	"setup/internal/core"
	"setup/internal/fake"
	"setup/internal/tasks"
)

func TestInstallLatest(t *testing.T) {
	env, runner, _ := fake.Env(t)
	installed := ""
	runner.Handler = func(cmd string) (string, error) {
		switch {
		case strings.HasSuffix(cmd, "versions --bare"), strings.HasSuffix(cmd, " global"):
			return installed, nil
		case strings.Contains(cmd, " install --skip-existing "):
			installed = strings.Fields(cmd)[3]
		}
		return "", nil
	}
	latest := func(context.Context, *core.Env, string) (string, error) { return "3.4.7", nil }
	task := tasks.InstallLatest("Ruby", "rbenv-fake", latest)

	plan, _ := task(context.Background(), env)
	fake.Apply(t, env, plan)

	bin := env.HomePath(".rbenv-fake/bin/rbenv-fake")
	want := []string{bin + " install --skip-existing 3.4.7", bin + " global 3.4.7"}
	if !slices.Equal(runner.Calls, want) {
		t.Fatalf("calls %v, want %v", runner.Calls, want)
	}
	if plan, _ := task(context.Background(), env); !slices.Equal(plan.Done, []string{"Ruby 3.4.7 (global)"}) {
		t.Fatalf("second run: %+v", plan)
	}
}
