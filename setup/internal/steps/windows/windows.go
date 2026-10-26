package windows

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

const keyboardKey = `HKCU\Control Panel\Keyboard`

func New() core.Step {
	return core.Step{Name: "Windows settings", Tasks: []core.Task{
		tasks.OnlyWSL(
			setting(keyboardKey, "KeyboardDelay", "0"),
			setting(keyboardKey, "KeyboardSpeed", "31"),
		),
	}}
}
