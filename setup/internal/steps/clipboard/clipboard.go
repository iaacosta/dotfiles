package clipboard

import (
	"context"
	"os/exec"

	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Clipboard", Tasks: []core.Task{
		tasks.OnlyWSL(win32yank),
	}}
}

func win32yank(context.Context, *core.Env) (core.Plan, error) {
	if _, err := exec.LookPath("win32yank.exe"); err == nil {
		return core.Plan{Done: []string{"win32yank.exe found"}}, nil
	}
	return core.Plan{Warnings: []string{
		"win32yank.exe not found, so nvim can't use the Windows clipboard. Download it from https://github.com/equalsraf/win32yank/releases and put it on PATH",
	}}, nil
}
