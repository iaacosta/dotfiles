package ruby

import (
	"setup/internal/core"
	"setup/internal/managers"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Ruby", Tasks: []core.Task{
		tasks.Pkg("rbenv", tasks.Overrides{managers.Apt{}: tasks.GitClone("https://github.com/rbenv/rbenv", ".rbenv")}),
		tasks.Pkg("ruby-build", tasks.Overrides{managers.Apt{}: tasks.GitClone("https://github.com/rbenv/ruby-build", ".rbenv/plugins/ruby-build")}),
		tasks.GitClone("https://github.com/tpope/rbenv-aliases", ".rbenv/plugins/rbenv-aliases"),
		tasks.ByManager(tasks.Overrides{
			managers.Brew{}: tasks.Pkgs("openssl@3", "libyaml"),
			managers.Apt{}:  tasks.Pkgs("build-essential", "libssl-dev", "libyaml-dev", "zlib1g-dev", "libffi-dev", "libreadline-dev"),
		}),
		tasks.InstallLatest("Ruby", "rbenv", latestRuby),
	}}
}
