package core

import "context"

type Step struct {
	Name  string
	Tasks []Task
}

type Task func(ctx context.Context, env *Env) (Plan, error)

type Plan struct {
	Done     []string
	Actions  []Action
	Warnings []string
}

type Action struct {
	Desc string
	Do   func(ctx context.Context, env *Env) error
}

func (s Step) Plan(ctx context.Context, env *Env) (Plan, error) {
	var plan Plan
	for _, task := range s.Tasks {
		p, err := task(ctx, env)
		if err != nil {
			return plan, err
		}
		plan.Done = append(plan.Done, p.Done...)
		plan.Actions = append(plan.Actions, p.Actions...)
		plan.Warnings = append(plan.Warnings, p.Warnings...)
	}
	return plan, nil
}
