package main

import (
	"bufio"
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"slices"
	"strings"

	"setup/internal/core"
	"setup/internal/managers"
)

func main() {
	keepGoing := flag.Bool("keep-going", false, "report failed steps and continue with the next ones")
	var only, skip []string
	flag.Func("only", "run only the step with this name, case-insensitive (repeatable)", func(name string) error {
		only = append(only, name)
		return nil
	})
	flag.Func("skip", "skip the step with this name, case-insensitive (repeatable)", func(name string) error {
		skip = append(skip, name)
		return nil
	})
	flag.Parse()

	if err := run(*keepGoing, only, skip); err != nil {
		fmt.Fprintln(os.Stderr, "setup:", err)
		os.Exit(1)
	}
}

func run(keepGoing bool, only, skip []string) error {
	steps, err := filterSteps(setupSteps, only, skip)
	if err != nil {
		return err
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}
	root, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		return fmt.Errorf("run setup from inside the dotfiles repo: %w", err)
	}
	manager, err := managers.Detect()
	if err != nil {
		return err
	}
	env := core.NewEnv(home, strings.TrimSpace(string(root)), manager)

	ctx := context.Background()
	fmt.Printf("\n=== Dotfiles setup (%s) ===\n\n", env)
	plans := core.PlanAll(ctx, env, steps)
	plans.Preview()

	if failed := plans.Failed(); len(failed) > 0 && !keepGoing {
		return fmt.Errorf("could not check %s (use --keep-going to skip)", strings.Join(failed, ", "))
	}
	if plans.Pending() == 0 {
		fmt.Println("Everything is already set up! Nothing to do.")
		return nil
	}
	if !confirm() {
		fmt.Println("Setup cancelled.")
		return nil
	}
	return plans.Apply(ctx, env, keepGoing)
}

func filterSteps(steps []core.Step, only, skip []string) ([]core.Step, error) {
	if len(only) > 0 && len(skip) > 0 {
		return nil, errors.New("use --only or --skip, not both")
	}
	named := map[string]bool{}
	for _, name := range slices.Concat(only, skip) {
		if !slices.ContainsFunc(steps, func(s core.Step) bool { return strings.EqualFold(s.Name, name) }) {
			var known []string
			for _, s := range steps {
				known = append(known, s.Name)
			}
			return nil, fmt.Errorf("unknown step %q (steps: %s)", name, strings.Join(known, ", "))
		}
		named[strings.ToLower(name)] = true
	}
	// With --only, drop the steps that weren't named; with --skip, drop the ones that were
	keepNamed := len(only) > 0
	return slices.DeleteFunc(slices.Clone(steps), func(s core.Step) bool {
		return len(named) > 0 && named[strings.ToLower(s.Name)] != keepNamed
	}), nil
}

func confirm() bool {
	fmt.Print("Proceed with setup? [y/N] ")
	answer, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	fmt.Println()
	answer = strings.ToLower(strings.TrimSpace(answer))
	return answer == "y" || answer == "yes"
}
