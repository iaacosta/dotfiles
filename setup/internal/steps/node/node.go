package node

import (
	"setup/internal/core"
	"setup/internal/managers"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Node", Tasks: []core.Task{
		tasks.Pkg("nodenv", tasks.Overrides{managers.Apt{}: tasks.GitClone("https://github.com/nodenv/nodenv", ".nodenv")}),
		tasks.Pkg("node-build", tasks.Overrides{managers.Apt{}: tasks.GitClone("https://github.com/nodenv/node-build", ".nodenv/plugins/node-build")}),
		tasks.GitClone("https://github.com/nodenv/nodenv-aliases", ".nodenv/plugins/nodenv-aliases"),
		tasks.InstallLatest("Node", "nodenv", latestLTS),
	}}
}
