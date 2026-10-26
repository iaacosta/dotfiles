package core

import (
	"os"
	"path/filepath"
	"runtime"
	"strings"
)

type OS string

const (
	Mac   OS = "macOS"
	Linux OS = "Linux"
)

type Env struct {
	OS       OS
	WSL      bool
	Manager  Manager
	Home     string
	Dotfiles string
	Run      Runner
}

func NewEnv(home, dotfiles string, manager Manager) *Env {
	env := &Env{OS: Linux, Manager: manager, Home: home, Dotfiles: dotfiles, Run: ExecRunner{}}
	if runtime.GOOS == "darwin" {
		env.OS = Mac
	}
	version, _ := os.ReadFile("/proc/version")
	env.WSL = strings.Contains(strings.ToLower(string(version)), "microsoft")
	return env
}

func (e *Env) HomePath(rel string) string {
	return filepath.Join(e.Home, rel)
}

func (e *Env) DotfilesPath(rel string) string {
	return filepath.Join(e.Dotfiles, rel)
}

func (e *Env) String() string {
	s := string(e.OS) + ", " + e.Manager.Name()
	if e.WSL {
		s += ", WSL"
	}
	return s
}
