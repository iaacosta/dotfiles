package terminal

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Terminal", Tasks: []core.Task{
		tasks.OnlyMac(
			tasks.Pkgs("ghostty", "font-0xproto-nerd-font"),
			tasks.Symlink("ghostty", ".config/ghostty"),
		),
	}}
}
