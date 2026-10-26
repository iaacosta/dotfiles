package claude

import (
	"setup/internal/core"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Claude", Tasks: []core.Task{
		tasks.Symlink("claude/agents", ".claude/agents"),
		tasks.Symlink("claude/commands", ".claude/commands"),
		tasks.Symlink("claude/skills", ".claude/skills"),
	}}
}
