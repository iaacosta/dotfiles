package tasks_test

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"setup/internal/fake"
	"setup/internal/tasks"
)

func TestSymlink(t *testing.T) {
	cases := []struct {
		name     string
		existing func(t *testing.T, path string)
		backup   bool
	}{
		{"missing", func(*testing.T, string) {}, false},
		{"real file in the way", func(t *testing.T, path string) { write(t, path, "mine") }, true},
		{"real folder in the way", func(t *testing.T, path string) { write(t, filepath.Join(path, "x"), "mine") }, true},
		{"link to somewhere else", func(t *testing.T, path string) { os.Symlink("/elsewhere", path) }, false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, _, _ := fake.Env(t)
			path, target := filepath.Join(env.Home, ".config/nvim"), filepath.Join(env.Dotfiles, "nvim")
			os.MkdirAll(filepath.Dir(path), 0o755)
			tc.existing(t, path)

			task := tasks.Symlink("nvim", ".config/nvim")
			plan, _ := task(context.Background(), env)
			fake.Apply(t, env, plan)

			if got, _ := os.Readlink(path); got != target {
				t.Fatalf("link points to %q", got)
			}
			backups, _ := filepath.Glob(path + ".backup.*")
			if (len(backups) == 1) != tc.backup {
				t.Fatalf("backups: %v", backups)
			}
			if plan, _ := task(context.Background(), env); len(plan.Actions) > 0 {
				t.Fatalf("second run still has actions: %+v", plan)
			}
			if _, err := os.Lstat(filepath.Join(target, "nvim")); err == nil {
				t.Fatal("linked inside the target directory")
			}
		})
	}
}

func write(t *testing.T, path, content string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
}
