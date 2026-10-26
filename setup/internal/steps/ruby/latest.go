package ruby

import (
	"context"
	"errors"
	"regexp"
	"strings"

	"setup/internal/core"
)

var stable = regexp.MustCompile(`^\d+\.\d+\.\d+$`)

func latestRuby(ctx context.Context, env *core.Env, rbenv string) (string, error) {
	list, err := env.Run.Output(ctx, rbenv, "install", "-l")
	if err != nil {
		return "", err
	}
	latest := ""
	for _, line := range strings.Split(list, "\n") {
		if line = strings.TrimSpace(line); stable.MatchString(line) {
			latest = line
		}
	}
	if latest == "" {
		return "", errors.New("no stable Ruby version found")
	}
	return latest, nil
}
