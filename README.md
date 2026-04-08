# Dotfiles

Personal development environment configuration for macOS and Linux/WSL.

## Quick Setup on New Machine

### 1. Generate SSH Key for GitHub

```bash
ssh-keygen -t ed25519 -C "ignacioacostaj@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Then add the public key to GitHub: https://github.com/settings/keys

### 2. Clone This Repo

```bash
git clone git@github.com:iaacosta/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Run Setup

```bash
bash ./setup.sh
```

Follow the manual steps printed by the script.

## What's Included

- **Shell**: zsh with Oh My Zsh, autosuggestions, and syntax highlighting
- **Editor**: neovim with Lazy plugin manager
- **Tools**: fzf, ripgrep, direnv, tmux, gh
- **Languages**: Node.js (nodenv), Ruby (rbenv), Go
- **Terminal**: Ghostty with 0xProto Nerd Font

## Platform Support

- macOS (via Homebrew)
- Linux/WSL (via apt)

## How `.zshrc` Works

`~/.zshrc` is **not** a symlink into this repo. It is a tiny machine-local
stub that sources the shared config:

```zsh
# ~/.zshrc (machine-local, created by setup.sh)
source "$HOME/dotfiles/.zshrc"

# machine-specific stuff goes below...
```

The actual shared shell config lives in `~/dotfiles/.zshrc` and is the same
on every machine.

### Why not symlink `~/.zshrc` directly?

Lots of installers (Homebrew, SDKMAN, rustup, nvm, bun, the Postgres.app
hint, `nodenv init`, etc.) append lines to `~/.zshrc` when you run them.
If `~/.zshrc` were a symlink into this repo, every install would dirty the
dotfiles repo and leak machine-specific PATH entries into shared config.

By keeping `~/.zshrc` as a real local file, those appends land in the local
stub and the dotfiles repo stays clean.

### Where things go

- **Shared, portable config** (aliases, prompt, plugins, language version
  managers, generic PATH like `~/go/bin`) → `~/dotfiles/.zshrc`
- **Machine-specific config** (Android SDK, libpq, Bun, SDKMAN, anything an
  installer appends) → `~/.zshrc` (local stub, after the `source` line)

### Bootstrapping on a new machine

`setup.sh` creates the stub automatically the first time you run it.
If a `~/.zshrc` already exists at that point, it is moved aside to
`~/.zshrc.backup.<timestamp>` before the stub is written.
