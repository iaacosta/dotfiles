package neovim

import "setup/internal/tasks"

var win32yankRelease = tasks.Release{
	Name: "win32yank",
	URL:  "https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-{arch}.zip",
	Arch: map[string]string{"amd64": "x64"},
	Bins: []string{"win32yank.exe"},
}
