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
