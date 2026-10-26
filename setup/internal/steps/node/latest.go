package node

import (
	"context"
	"encoding/json"
	"errors"
	"strings"

	"setup/internal/core"
)

func latestLTS(ctx context.Context, env *core.Env, _ string) (string, error) {
	index, err := env.Run.Output(ctx, "curl", "-fsSL", "https://nodejs.org/dist/index.json")
	if err != nil {
		return "", err
	}
	var releases []struct {
		Version string `json:"version"`
		LTS     any    `json:"lts"`
	}
	if err := json.Unmarshal([]byte(index), &releases); err != nil {
		return "", err
	}
	for _, r := range releases {
		if r.LTS != false {
			return strings.TrimPrefix(r.Version, "v"), nil
		}
	}
	return "", errors.New("no Node LTS release found")
}
