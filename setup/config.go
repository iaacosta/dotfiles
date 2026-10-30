package main

import (
	"setup/internal/core"
	"setup/internal/steps/claude"
	"setup/internal/steps/clitools"
	"setup/internal/steps/git"
	"setup/internal/steps/golang"
	"setup/internal/steps/macos"
	"setup/internal/steps/neovim"
	"setup/internal/steps/node"
	"setup/internal/steps/packagemanager"
	"setup/internal/steps/ruby"
	"setup/internal/steps/shell"
	"setup/internal/steps/terminal"
	"setup/internal/steps/tmux"
	"setup/internal/steps/windows"
)

var setupSteps = []core.Step{
	packagemanager.New(),
	shell.New(),
	clitools.New(),
	git.New(),
	tmux.New(),
	neovim.New(),
	golang.New(),
	ruby.New(),
	node.New(),
	claude.New(),
	terminal.New(),
	macos.New(),
	windows.New(),
}
