package core

import (
	"context"
	"errors"
	"fmt"
	"strings"
)

const (
	red    = "\033[0;31m"
	green  = "\033[0;32m"
	yellow = "\033[1;33m"
	blue   = "\033[0;34m"
	reset  = "\033[0m"
)

type StepPlan struct {
	Step Step
	Plan Plan
	Err  error
}

type Plans []StepPlan

func PlanAll(ctx context.Context, env *Env, steps []Step) Plans {
	plans := make(Plans, 0, len(steps))
	for _, step := range steps {
		plan, err := step.Plan(ctx, env)
		plans = append(plans, StepPlan{Step: step, Plan: plan, Err: err})
	}
	return plans
}

func (plans Plans) Pending() int {
	n := 0
	for _, sp := range plans {
		n += len(sp.Plan.Actions)
	}
	return n
}

func (plans Plans) Failed() []string {
	var names []string
	for _, sp := range plans {
		if sp.Err != nil {
			names = append(names, sp.Step.Name)
		}
	}
	return names
}

func (plans Plans) Preview() {
	for _, sp := range plans {
		p := sp.Plan
		if sp.Err == nil && len(p.Done)+len(p.Actions)+len(p.Warnings) == 0 {
			continue
		}
		fmt.Printf("%s[%s]%s\n", blue, sp.Step.Name, reset)
		for _, line := range p.Done {
			fmt.Printf("  %s✓%s %s\n", green, reset, line)
		}
		for _, action := range p.Actions {
			fmt.Printf("  %s•%s %s\n", yellow, reset, action.Desc)
		}
		for _, line := range p.Warnings {
			fmt.Printf("  %s⚠%s %s\n", yellow, reset, line)
		}
		if sp.Err != nil {
			fmt.Printf("  %s✗%s could not check: %v\n", red, reset, sp.Err)
		}
		fmt.Println()
	}
}

func (plans Plans) Apply(ctx context.Context, env *Env, keepGoing bool) error {
	failed := plans.Failed()
	for _, sp := range plans {
		if sp.Err != nil || len(sp.Plan.Actions) == 0 {
			continue
		}
		fmt.Printf("%s%s%s\n", blue, sp.Step.Name, reset)
		for _, action := range sp.Plan.Actions {
			fmt.Printf("  %s•%s %s\n", yellow, reset, action.Desc)
			if err := action.Do(ctx, env); err != nil {
				fmt.Printf("  %s✗%s %v\n", red, reset, err)
				if !keepGoing {
					return fmt.Errorf("%s: %w", sp.Step.Name, err)
				}
				failed = append(failed, sp.Step.Name)
				break
			}
		}
		fmt.Println()
	}

	if len(failed) > 0 {
		fmt.Printf("%s✗ Finished with failures:%s %s\n\n", red, reset, strings.Join(failed, ", "))
		return errors.New("some steps failed")
	}
	fmt.Printf("%s✓ Setup complete!%s\n\n", green, reset)
	return nil
}
