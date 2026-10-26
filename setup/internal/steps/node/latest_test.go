package node

import (
	"context"
	"testing"

	"setup/internal/fake"
)

func TestLatestLTS(t *testing.T) {
	env, runner, _ := fake.Env(t)
	runner.Handler = func(string) (string, error) {
		return `[{"version":"v25.1.0","lts":false},{"version":"v24.11.0","lts":"Krypton"},{"version":"v24.10.0","lts":"Krypton"}]`, nil
	}
	if v, err := latestLTS(context.Background(), env, ""); v != "24.11.0" || err != nil {
		t.Fatalf("got %q, %v", v, err)
	}
}
