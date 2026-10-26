package shell

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
)

func TestZshrcStub(t *testing.T) {
	env, _, _ := fake.Env(t)
	env.Dotfiles = filepath.Join(env.Home, "dotfiles")
	path := env.HomePath(".zshrc")
	os.Symlink("/old/zshrc", path)

	plan, _ := zshrcStub(context.Background(), env)
	fake.Apply(t, env, plan)

	content, _ := os.ReadFile(path)
	if !strings.Contains(string(content), `source "$HOME/dotfiles/.zshrc"`) {
		t.Fatalf("stub:\n%s", content)
	}
	if backups, _ := filepath.Glob(path + ".backup.*"); len(backups) != 1 {
		t.Fatal("old ~/.zshrc wasn't backed up")
	}
	if plan, _ := zshrcStub(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("second run: %+v", plan)
	}
}

func TestLoginShell(t *testing.T) {
	env, _, _ := fake.Env(t)

	t.Setenv("SHELL", "/bin/zsh")
	if plan, _ := loginShell(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("zsh already: %+v", plan)
	}
	t.Setenv("SHELL", "/bin/bash")
	if plan, _ := loginShell(context.Background(), env); len(plan.Actions) != 1 {
		t.Fatalf("bash: %+v", plan)
	}
}
