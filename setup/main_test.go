package main

import (
	"context"
	"errors"
	"strings"
	"testing"

	"setup/internal/core"
	"setup/internal/fake"
	"setup/internal/managers"
)

func TestFreshMachinePlans(t *testing.T) {
	cases := []struct {
		name    string
		os      core.OS
		wsl     bool
		manager core.Manager
		want    []string
		wantNot []string
	}{
		{
			name: "macOS", os: core.Mac, manager: managers.Brew{},
			want:    []string{"Install neovim with brew", "Install ghostty, font-0xproto-nerd-font with brew", "Set KeyRepeat to 1"},
			wantNot: []string{"release", "apt"},
		},
		{
			name: "WSL", os: core.Linux, wsl: true, manager: managers.Apt{},
			want:    []string{"Install the latest neovim release", "Install the latest tree-sitter release", "Install the latest go release", "Clone https://github.com/rbenv/rbenv"},
			wantNot: []string{"ghostty", "KeyRepeat", "brew"},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, runner, _ := fake.Env(t)
			env.OS, env.WSL, env.Manager = tc.os, tc.wsl, tc.manager
			runner.Handler = func(string) (string, error) { return "", errors.New("not installed") }
			t.Setenv("SHELL", "/bin/bash")
			t.Setenv("XDG_DATA_HOME", "")

			plans := core.PlanAll(context.Background(), env, setupSteps)
			if failed := plans.Failed(); len(failed) > 0 {
				t.Fatalf("could not plan: %v", failed)
			}
			var descs []string
			for _, sp := range plans {
				for _, a := range sp.Plan.Actions {
					descs = append(descs, a.Desc)
				}
			}
			all := strings.Join(descs, "\n")
			for _, want := range tc.want {
				if !strings.Contains(all, want) {
					t.Errorf("missing %q in:\n%s", want, all)
				}
			}
			for _, unwanted := range tc.wantNot {
				if strings.Contains(all, unwanted) {
					t.Errorf("unexpected %q in:\n%s", unwanted, all)
				}
			}
		})
	}
}
