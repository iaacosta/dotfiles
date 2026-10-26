package tasks_test

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
	"setup/internal/tasks"
)

func TestGitClone(t *testing.T) {
	env, runner, _ := fake.Env(t)
	runner.Handler = func(cmd string) (string, error) {
		if strings.HasPrefix(cmd, "git clone") {
			return "", os.MkdirAll(strings.Fields(cmd)[3], 0o755)
		}
		return "", nil
	}
	task := tasks.GitClone("https://github.com/tmux-plugins/tpm", ".tmux/plugins/tpm")

	plan, _ := task(context.Background(), env)
	fake.Apply(t, env, plan)

	want := "git clone https://github.com/tmux-plugins/tpm " + filepath.Join(env.Home, ".tmux/plugins/tpm")
	if len(runner.Calls) != 1 || runner.Calls[0] != want {
		t.Fatalf("calls: %v", runner.Calls)
	}
	if plan, _ := task(context.Background(), env); len(plan.Done) != 1 || len(plan.Actions) != 0 {
		t.Fatalf("second run: %+v", plan)
	}
}
