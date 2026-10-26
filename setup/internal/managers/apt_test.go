package managers_test

import (
	"context"
	"slices"
	"testing"

	"setup/internal/fake"
	"setup/internal/managers"
)

func TestAptUpdatesOnce(t *testing.T) {
	env, runner, _ := fake.Env(t)
	apt := managers.Apt{}
	apt.Install(context.Background(), env, "zsh")
	apt.Install(context.Background(), env, "fzf", "gh")

	want := []string{"sudo apt-get update", "sudo apt-get install -y zsh", "sudo apt-get install -y fzf gh"}
	if !slices.Equal(runner.Calls, want) {
		t.Fatalf("calls %v, want %v", runner.Calls, want)
	}
}

func TestAptInstalled(t *testing.T) {
	env, runner, _ := fake.Env(t)
	runner.Handler = func(cmd string) (string, error) {
		if cmd == "dpkg-query -W -f=${Status} zsh" {
			return "install ok installed", nil
		}
		return "", nil
	}
	if !(managers.Apt{}).Installed(context.Background(), env, "zsh") || (managers.Apt{}).Installed(context.Background(), env, "fzf") {
		t.Fatal("wrong installed status")
	}
}
