package main

import (
	"bufio"
	"context"
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
	var skip []string
	flag.Func("skip", "skip the step with this name, case-insensitive (repeatable)", func(name string) error {
		skip = append(skip, name)
		return nil
	})
	flag.Parse()

	if err := run(*keepGoing, skip); err != nil {
		fmt.Fprintln(os.Stderr, "setup:", err)
		os.Exit(1)
	}
}

func run(keepGoing bool, skip []string) error {
	steps, err := skipSteps(setupSteps, skip)
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

func skipSteps(steps []core.Step, skip []string) ([]core.Step, error) {
	skipped := map[string]bool{}
	for _, name := range skip {
		if !slices.ContainsFunc(steps, func(s core.Step) bool { return strings.EqualFold(s.Name, name) }) {
			return nil, fmt.Errorf("unknown step %q to skip", name)
		}
		skipped[strings.ToLower(name)] = true
	}
	return slices.DeleteFunc(slices.Clone(steps), func(s core.Step) bool { return skipped[strings.ToLower(s.Name)] }), nil
}

func confirm() bool {
	fmt.Print("Proceed with setup? [y/N] ")
	answer, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	fmt.Println()
	answer = strings.ToLower(strings.TrimSpace(answer))
	return answer == "y" || answer == "yes"
}
