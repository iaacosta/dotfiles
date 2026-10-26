package clitools

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "CLI tools", Tasks: []core.Task{
		tasks.Pkgs("fzf", "ripgrep", "direnv", "gh", "sqlite3"),
	}}
}
