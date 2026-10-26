package ruby

import (
	"context"
	"testing"

	"setup/internal/fake"
)

func TestLatestRuby(t *testing.T) {
	env, runner, _ := fake.Env(t)
	runner.Handler = func(string) (string, error) {
		return "3.3.9\n3.4.7\njruby-10.0.2.0\ntruffleruby-24.1.1\n", nil
	}
	if v, err := latestRuby(context.Background(), env, "rbenv"); v != "3.4.7" || err != nil {
		t.Fatalf("got %q, %v", v, err)
	}
}
