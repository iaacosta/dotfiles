package neovim

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
)

func TestRestorePlugins(t *testing.T) {
	env, runner, _ := fake.Env(t)
	t.Setenv("XDG_DATA_HOME", "")
	lock := filepath.Join(env.Dotfiles, "nvim/lazy-lock.json")
	os.MkdirAll(filepath.Dir(lock), 0o755)
	os.WriteFile(lock, []byte(`{"plenary.nvim": {"branch": "master", "commit": "abc"}, "oil.nvim": {"commit": "def"}}`), 0o644)

	if plan, _ := restorePlugins(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("no plugins installed yet should be done: %+v", plan)
	}

	os.MkdirAll(env.HomePath(".local/share/nvim/lazy"), 0o755)
	heads := map[string]string{"plenary.nvim": "abc", "oil.nvim": "old"}
	runner.Handler = func(cmd string) (string, error) {
		for name, head := range heads {
			if strings.Contains(cmd, "/"+name+" ") {
				return head, nil
			}
		}
		return "", nil
	}
	plan, _ := restorePlugins(context.Background(), env)
	if len(plan.Actions) != 1 || plan.Actions[0].Desc != "Restore 1 plugin(s) to the versions in lazy-lock.json" {
		t.Fatalf("drift: %+v", plan)
	}

	heads["oil.nvim"] = "def"
	if plan, _ := restorePlugins(context.Background(), env); len(plan.Actions) != 0 {
		t.Fatalf("matching: %+v", plan)
	}
}
