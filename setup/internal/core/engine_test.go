package core

import (
	"context"
	"errors"
	"slices"
	"testing"
)

func action(desc string, ran *[]string, err error) Task {
	return func(context.Context, *Env) (Plan, error) {
		return Plan{Actions: []Action{{Desc: desc, Do: func(context.Context, *Env) error {
			*ran = append(*ran, desc)
			return err
		}}}}, nil
	}
}

func done(line string) Task {
	return func(context.Context, *Env) (Plan, error) { return Plan{Done: []string{line}}, nil }
}

func TestStepPlanMergesTasksInOrder(t *testing.T) {
	var ran []string
	plan, err := Step{Tasks: []Task{done("a"), action("b", &ran, nil), done("c")}}.Plan(context.Background(), &Env{})
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(plan.Done, []string{"a", "c"}) || len(plan.Actions) != 1 || plan.Actions[0].Desc != "b" {
		t.Fatalf("got %+v", plan)
	}
}

func TestStepPlanStopsAtFailingTask(t *testing.T) {
	failing := func(context.Context, *Env) (Plan, error) { return Plan{}, errors.New("boom") }
	var ran []string
	_, err := Step{Tasks: []Task{failing, action("after", &ran, nil)}}.Plan(context.Background(), &Env{})
	if err == nil {
		t.Fatal("want error")
	}
}

func TestPendingAndFailed(t *testing.T) {
	var ran []string
	failing := func(context.Context, *Env) (Plan, error) { return Plan{}, errors.New("boom") }
	plans := PlanAll(context.Background(), &Env{}, []Step{
		{Name: "ok", Tasks: []Task{action("x", &ran, nil), action("y", &ran, nil)}},
		{Name: "broken", Tasks: []Task{failing}},
	})
	if plans.Pending() != 2 {
		t.Errorf("pending = %d", plans.Pending())
	}
	if !slices.Equal(plans.Failed(), []string{"broken"}) {
		t.Errorf("failed = %v", plans.Failed())
	}
}

func TestApply(t *testing.T) {
	cases := []struct {
		name      string
		keepGoing bool
		want      []string
	}{
		{"stops at the first error", false, []string{"first", "fails"}},
		{"keeps going past a failed step", true, []string{"first", "fails", "last"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var ran []string
			plans := PlanAll(context.Background(), &Env{}, []Step{
				{Name: "one", Tasks: []Task{action("first", &ran, nil)}},
				{Name: "two", Tasks: []Task{action("fails", &ran, errors.New("boom")), action("skipped", &ran, nil)}},
				{Name: "three", Tasks: []Task{action("last", &ran, nil)}},
			})
			if err := plans.Apply(context.Background(), &Env{}, tc.keepGoing); err == nil {
				t.Fatal("want error")
			}
			if !slices.Equal(ran, tc.want) {
				t.Fatalf("ran %v, want %v", ran, tc.want)
			}
		})
	}
}
