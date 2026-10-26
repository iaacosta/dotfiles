package shell

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Shell", Tasks: []core.Task{
		tasks.Pkg("zsh", nil),
		tasks.GitClone("https://github.com/ohmyzsh/ohmyzsh", ".oh-my-zsh"),
		tasks.GitClone("https://github.com/zsh-users/zsh-autosuggestions", ".oh-my-zsh/custom/plugins/zsh-autosuggestions"),
		tasks.GitClone("https://github.com/zsh-users/zsh-syntax-highlighting", ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"),
		zshrcStub,
		loginShell,
	}}
}
