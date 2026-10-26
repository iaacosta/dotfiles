package terminal

import (
	"archive/zip"
	"context"
	"io"
	"os"
	"path/filepath"
	"strings"

	"setup/internal/core"
)

const (
	fontZipURL  = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip"
	fontFile    = "0xProtoNerdFont-Regular.ttf"
	fontFace    = "0xProto Nerd Font"
	fontsRegKey = `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts`
)

// windowsFont installs the Nerd Font for the current Windows user, which
// needs no admin rights: copy the .ttf files into the per-user fonts folder
// and register each one under HKCU.
func windowsFont(ctx context.Context, env *core.Env) (core.Plan, error) {
	dir, err := windowsFontsDir(ctx, env)
	if err != nil {
		return core.Plan{Warnings: []string{
			"Couldn't find the Windows fonts folder, so 0xProto Nerd Font wasn't installed on Windows. Check that powershell.exe and wslpath work from WSL",
		}}, nil
	}
	if _, err := os.Stat(filepath.Join(dir, fontFile)); err == nil {
		return core.Plan{Done: []string{"0xProto Nerd Font installed on Windows"}}, nil
	}
	return core.Plan{Actions: []core.Action{{
		Desc: "Install 0xProto Nerd Font for the Windows user",
		Do: func(ctx context.Context, env *core.Env) error {
			return installWindowsFont(ctx, env, dir)
		},
	}}, Warnings: []string{
		"Windows Terminal sets the font per profile: once installed, pick " + fontFace + " under Settings > your distro's profile > Appearance > Font face, then restart Terminal",
	}}, nil
}

func windowsFontsDir(ctx context.Context, env *core.Env) (string, error) {
	local, err := env.Run.Output(ctx, "powershell.exe", "-NoProfile", "-Command", "[Environment]::GetFolderPath('LocalApplicationData')")
	if err != nil {
		return "", err
	}
	return env.Run.Output(ctx, "wslpath", "-u", strings.TrimSpace(local)+`\Microsoft\Windows\Fonts`)
}

func installWindowsFont(ctx context.Context, env *core.Env, dir string) error {
	archive := filepath.Join(os.TempDir(), "0xProto.zip")
	if err := env.Run.Run(ctx, "curl", "-fsSL", "-o", archive, fontZipURL); err != nil {
		return err
	}
	defer os.Remove(archive)

	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	fonts, err := extractFonts(archive, dir)
	if err != nil {
		return err
	}
	for _, font := range fonts {
		winPath, err := env.Run.Output(ctx, "wslpath", "-w", font)
		if err != nil {
			return err
		}
		name := strings.TrimSuffix(filepath.Base(font), ".ttf") + " (TrueType)"
		if err := env.Run.Run(ctx, "reg.exe", "add", fontsRegKey, "/v", name, "/t", "REG_SZ", "/d", winPath, "/f"); err != nil {
			return err
		}
	}
	return nil
}

func extractFonts(archive, dir string) ([]string, error) {
	r, err := zip.OpenReader(archive)
	if err != nil {
		return nil, err
	}
	defer r.Close()

	var fonts []string
	for _, f := range r.File {
		if !strings.HasSuffix(f.Name, ".ttf") {
			continue
		}
		dest := filepath.Join(dir, filepath.Base(f.Name))
		if err := extractFile(f, dest); err != nil {
			return nil, err
		}
		fonts = append(fonts, dest)
	}
	return fonts, nil
}

func extractFile(f *zip.File, dest string) error {
	in, err := f.Open()
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}
