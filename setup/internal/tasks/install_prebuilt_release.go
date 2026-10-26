package tasks

import (
	"archive/zip"
	"compress/gzip"
	"context"
	"fmt"
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
		if _, err := os.Stat(bin); err == nil {
			return core.Plan{Done: []string{r.installed(ctx, env, bin)}}, nil
		}
		return core.Plan{Actions: []core.Action{{
			Desc: "Install the latest " + r.Name + " release into ~/.local",
			Do: func(ctx context.Context, env *core.Env) error {
				return r.install(ctx, env)
			},
		}}}, nil
	}
}

func (r Release) installed(ctx context.Context, env *core.Env, bin string) string {
	if r.VersionArgs == nil {
		return r.Name + " installed"
	}
	out, err := env.Run.Output(ctx, bin, r.VersionArgs...)
	if err != nil || out == "" {
		return r.Name + " installed"
	}
	return r.Name + ": " + strings.Split(out, "\n")[0]
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
	switch {
	case strings.HasSuffix(archive, ".tar.gz"):
		err = env.Run.Run(ctx, "tar", "-xzf", archive, "-C", dir, "--strip-components=1")
	case strings.HasSuffix(archive, ".zip"):
		err = unzip(archive, dir)
	default:
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
		if err := os.Chmod(filepath.Join(dir, b), 0o755); err != nil {
			return err
		}
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

func unzip(src, dir string) error {
	archive, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer archive.Close()
	for _, f := range archive.File {
		path := filepath.Join(dir, f.Name)
		if !strings.HasPrefix(path, filepath.Clean(dir)+string(os.PathSeparator)) {
			return fmt.Errorf("unsafe path in archive: %s", f.Name)
		}
		if f.FileInfo().IsDir() {
			if err := os.MkdirAll(path, 0o755); err != nil {
				return err
			}
			continue
		}
		if err := extract(f, path); err != nil {
			return err
		}
	}
	return nil
}

func extract(f *zip.File, path string) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	in, err := f.Open()
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o644)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}
