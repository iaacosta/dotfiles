package golang

import (
	"setup/internal/core"
	"setup/internal/managers"
	"setup/internal/tasks"
)

func New() core.Step {
	return core.Step{Name: "Go", Tasks: []core.Task{
		tasks.Pkg("go", tasks.Overrides{managers.Apt{}: tasks.InstallPrebuiltRelease(goRelease)}),
	}}
}
