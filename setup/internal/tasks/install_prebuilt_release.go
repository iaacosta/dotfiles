package tasks

import (
	"compress/gzip"
	"context"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"setup/internal/core"
)

type Release struct {
	Name        string
	URL         string
	Arch        map[string]string
	Version     func(ctx context.Context, env *core.Env) (string, error)
	Bins        []string
	VersionArgs []string
}

func InstallPrebuiltRelease(r Release) core.Task {
	return func(ctx context.Context, env *core.Env) (core.Plan, error) {
		bin := env.HomePath(filepath.Join(".local/bin", filepath.Base(r.Bins[0])))
		args := r.VersionArgs
		if args == nil {
			args = []string{"--version"}
		}
		if out, err := env.Run.Output(ctx, bin, args...); err == nil {
			return core.Plan{Done: []string{r.Name + ": " + strings.Split(out, "\n")[0]}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Install the latest " + r.Name + " release into ~/.local",
			Do: func(ctx context.Context, env *core.Env) error {
				return r.install(ctx, env)
			},
		}}}, nil
	}
}

func (r Release) install(ctx context.Context, env *core.Env) error {
	url, err := r.url(ctx, env)
	if err != nil {
		return err
	}
	archive := filepath.Join(os.TempDir(), filepath.Base(url))
	if err := env.Run.Run(ctx, "curl", "-fsSL", "-o", archive, url); err != nil {
		return err
	}
	defer os.Remove(archive)

	dir := env.HomePath(filepath.Join(".local", r.Name))
	if err := os.RemoveAll(dir); err != nil {
		return err
	}
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	if strings.HasSuffix(archive, ".tar.gz") {
		err = env.Run.Run(ctx, "tar", "-xzf", archive, "-C", dir, "--strip-components=1")
	} else {
		err = gunzip(archive, filepath.Join(dir, r.Bins[0]))
	}
	if err != nil {
		return err
	}

	binDir := env.HomePath(".local/bin")
	if err := os.MkdirAll(binDir, 0o755); err != nil {
		return err
	}
	for _, b := range r.Bins {
		link := filepath.Join(binDir, filepath.Base(b))
		os.Remove(link)
		if err := os.Symlink(filepath.Join(dir, b), link); err != nil {
			return err
		}
	}
	return nil
}

func (r Release) url(ctx context.Context, env *core.Env) (string, error) {
	version := ""
	if r.Version != nil {
		v, err := r.Version(ctx, env)
		if err != nil {
			return "", err
		}
		version = v
	}
	arch := runtime.GOARCH
	if name, ok := r.Arch[arch]; ok {
		arch = name
	}
	return strings.NewReplacer("{arch}", arch, "{version}", version).Replace(r.URL), nil
}

func gunzip(src, dest string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	gz, err := gzip.NewReader(in)
	if err != nil {
		return err
	}
	out, err := os.OpenFile(dest, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o755)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, gz)
	return err
}
