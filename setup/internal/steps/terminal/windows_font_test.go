package terminal

import (
	"archive/zip"
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"setup/internal/fake"
)

func TestWindowsFont(t *testing.T) {
	env, runner, _ := fake.Env(t)
	fontsDir := filepath.Join(env.Home, "Fonts")
	runner.Handler = func(cmd string) (string, error) {
		switch {
		case strings.HasPrefix(cmd, "wslpath -u"):
			return fontsDir, nil
		case strings.HasPrefix(cmd, "wslpath -w"):
			return `C:\Fonts\` + filepath.Base(cmd), nil
		case strings.HasPrefix(cmd, "curl"):
			writeFontZip(t, strings.Fields(cmd)[3])
		}
		return "", nil
	}

	plan, err := windowsFont(context.Background(), env)
	if err != nil || len(plan.Actions) != 1 || len(plan.Warnings) != 1 {
		t.Fatalf("missing font: %+v, %v", plan, err)
	}
	fake.Apply(t, env, plan)

	if _, err := os.Stat(filepath.Join(fontsDir, fontFile)); err != nil {
		t.Fatal("font wasn't copied")
	}
	if _, err := os.Stat(filepath.Join(fontsDir, "README.md")); err == nil {
		t.Fatal("non-font file was copied")
	}
	want := `reg.exe add ` + fontsRegKey + ` /v 0xProtoNerdFont-Regular (TrueType) /t REG_SZ /d C:\Fonts\` + fontFile + ` /f`
	if last := runner.Calls[len(runner.Calls)-1]; last != want {
		t.Fatalf("registry call:\n%s\nwant:\n%s", last, want)
	}
	if plan, _ := windowsFont(context.Background(), env); len(plan.Actions) != 0 || len(plan.Warnings) != 0 {
		t.Fatalf("second run: %+v", plan)
	}
}

func writeFontZip(t *testing.T, path string) {
	t.Helper()
	f, err := os.Create(path)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	w := zip.NewWriter(f)
	for _, name := range []string{fontFile, "README.md"} {
		fw, _ := w.Create(name)
		fw.Write([]byte("data"))
	}
	w.Close()
}
