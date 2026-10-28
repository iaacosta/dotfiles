package neovim

import (
	"setup/internal/core"
	"setup/internal/managers"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Neovim", Tasks: []core.Task{
		tasks.Pkg("neovim", tasks.Overrides{managers.Apt{}: tasks.InstallPrebuiltRelease(neovimRelease)}),
		tasks.Pkg("tree-sitter-cli", tasks.Overrides{managers.Apt{}: tasks.InstallPrebuiltRelease(treeSitterRelease)}),
		// nvim-treesitter compiles parsers with cc; brew already needs the Xcode CLI tools
		tasks.ByManager(tasks.Overrides{managers.Apt{}: tasks.Pkgs("build-essential")}),
		tasks.OnlyWSL(tasks.InstallPrebuiltRelease(win32yankRelease)),
		tasks.Symlink("nvim", ".config/nvim"),
		restorePlugins,
	}}
}
