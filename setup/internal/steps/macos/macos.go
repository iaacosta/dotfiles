package macos

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "macOS defaults", Tasks: []core.Task{
		tasks.OnlyMac(
			setting("NSGlobalDomain", "KeyRepeat", "int", "1"),
			setting("NSGlobalDomain", "InitialKeyRepeat", "int", "10"),
			setting("NSGlobalDomain", "ApplePressAndHoldEnabled", "bool", "false"),
		),
	}}
}
