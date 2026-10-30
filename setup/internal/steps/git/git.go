package git

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Git", Tasks: []core.Task{
		tasks.Symlink(".gitconfig", ".gitconfig"),
	}}
}
