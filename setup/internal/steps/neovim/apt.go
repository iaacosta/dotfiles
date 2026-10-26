package neovim

import "setup/internal/tasks"

var neovimRelease = tasks.Release{
	Name: "neovim",
	URL:  "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-{arch}.tar.gz",
	Arch: map[string]string{"amd64": "x86_64"},
	Bins: []string{"bin/nvim"},
}

var treeSitterRelease = tasks.Release{
	Name: "tree-sitter",
	URL:  "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-{arch}.gz",
	Arch: map[string]string{"amd64": "x64"},
	Bins: []string{"tree-sitter"},
}
