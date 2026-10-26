package tasks_test

import (
	"archive/zip"
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/core"
	"setup/internal/fake"
	"setup/internal/tasks"
)

func TestInstallPrebuiltRelease(t *testing.T) {
	cases := []struct {
		name    string
		release tasks.Release
		archive func(t *testing.T, content string) []byte
		extract func(t *testing.T, cmd string)
		done    string
	}{
		{
			name:    "single gzipped binary",
			release: tasks.Release{Name: "tool", URL: "https://example.com/tool-{arch}.gz", Bins: []string{"tool"}, VersionArgs: []string{"--version"}},
			archive: gzipped,
		},
		{
			name:    "zip without a version command",
			release: tasks.Release{Name: "tool", URL: "https://example.com/tool-{arch}.zip", Bins: []string{"tool"}},
			archive: zipped,
			done:    "tool installed",
		},
		{
			name:    "tarball with a bin folder",
			release: tasks.Release{Name: "tool", URL: "https://example.com/{version}/tool-{arch}.tar.gz", Bins: []string{"bin/tool"}, VersionArgs: []string{"--version"}, Version: func(context.Context, *core.Env) (string, error) { return "v1", nil }},
			archive: gzipped,
			extract: func(t *testing.T, cmd string) {
				write(t, filepath.Join(strings.Fields(cmd)[4], "bin/tool"), "binary")
			},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			env, runner, _ := fake.Env(t)
			installed := false
			var url string
			runner.Handler = func(cmd string) (string, error) {
				args := strings.Fields(cmd)
				switch {
				case strings.HasSuffix(cmd, "--version"):
					if !installed {
						return "", errors.New("not found")
					}
					return "tool 1.0", nil
				case args[0] == "curl":
					url = args[4]
					return "", os.WriteFile(args[3], tc.archive(t, "binary"), 0o644)
				case args[0] == "tar":
					tc.extract(t, cmd)
				}
				return "", nil
			}
			task := tasks.InstallPrebuiltRelease(tc.release)

			plan, _ := task(context.Background(), env)
			fake.Apply(t, env, plan)
			installed = true

			if strings.Contains(url, "{") {
				t.Fatalf("unresolved placeholder in %s", url)
			}
			link := env.HomePath(".local/bin/tool")
			if content, err := os.ReadFile(link); err != nil || string(content) != "binary" {
				t.Fatalf("~/.local/bin/tool: %q, %v", content, err)
			}
			if info, _ := os.Stat(link); info.Mode()&0o111 == 0 {
				t.Fatal("binary isn't executable")
			}
			want := tc.done
			if want == "" {
				want = "tool: tool 1.0"
			}
			if plan, _ := task(context.Background(), env); len(plan.Actions) != 0 || plan.Done[0] != want {
				t.Fatalf("second run: %+v", plan)
			}
		})
	}
}

func gzipped(t *testing.T, content string) []byte {
	t.Helper()
	var buf bytes.Buffer
	gz := gzip.NewWriter(&buf)
	gz.Write([]byte(content))
	gz.Close()
	return buf.Bytes()
}

func zipped(t *testing.T, content string) []byte {
	t.Helper()
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("tool")
	w.Write([]byte(content))
	zw.Create("LICENSE")
	zw.Close()
	return buf.Bytes()
}
