package tmux

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Tmux", Tasks: []core.Task{
		tasks.Pkg("tmux", nil),
		tasks.GitClone("https://github.com/tmux-plugins/tpm", ".tmux/plugins/tpm"),
		tasks.Symlink("tmux/tmux.conf", ".tmux.conf"),
	}}
}
