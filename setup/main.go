package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"setup/internal/core"
	"setup/internal/managers"
)

func main() {
	keepGoing := flag.Bool("keep-going", false, "report failed steps and continue with the next ones")
	flag.Parse()

	if err := run(*keepGoing); err != nil {
		fmt.Fprintln(os.Stderr, "setup:", err)
		os.Exit(1)
	}
}

func run(keepGoing bool) error {
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
	plans := core.PlanAll(ctx, env, setupSteps)
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

func confirm() bool {
	fmt.Print("Proceed with setup? [y/N] ")
	answer, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	fmt.Println()
	answer = strings.ToLower(strings.TrimSpace(answer))
	return answer == "y" || answer == "yes"
}
