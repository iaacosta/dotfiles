#!/bin/bash

set -e

OS="$(uname -s)"
PREVIEW_ITEMS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
add_preview() {
  PREVIEW_ITEMS+=("$1")
}

check_command() {
  command -v "$1" &> /dev/null
}

check_file() {
  [[ -f "$1" ]]
}

check_dir() {
  [[ -d "$1" ]]
}

check_symlink() {
  [[ -L "$1" ]] && [[ "$(readlink "$1")" == "$2" ]]
}

has_preview() {
  [[ " ${PREVIEW_ITEMS[*]} " =~ " $1 " ]]
}

# target|link pairs, shared by the preview and the execution
SYMLINKS=(
  "$HOME/dotfiles/.gitconfig|$HOME/.gitconfig"
  "$HOME/dotfiles/tmux/tmux.conf|$HOME/.tmux.conf"
  "$HOME/dotfiles/nvim|$HOME/.config/nvim"
  "$HOME/dotfiles/ghostty|$HOME/.config/ghostty"
  "$HOME/dotfiles/claude/agents|$HOME/.claude/agents"
  "$HOME/dotfiles/claude/commands|$HOME/.claude/commands"
  "$HOME/dotfiles/claude/skills|$HOME/.claude/skills"
)

# Links created by older versions of this script whose targets were removed
STALE_LINKS=(
  "$HOME/.config/opencode"
)

is_stale_link() {
  [[ -L "$1" ]] && [[ "$(readlink "$1")" == "$HOME/dotfiles/"* ]]
}

LAZY_LOCK="$HOME/dotfiles/nvim/lazy-lock.json"
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"

# True when an installed plugin is missing or not at its lazy-lock.json commit
plugins_drifted() {
  local name commit
  while read -r name commit; do
    [[ "$(git -C "$LAZY_DIR/$name" rev-parse HEAD 2>/dev/null)" == "$commit" ]] || return 0
  done < <(sed -nE 's/^ *"([^"]+)": \{.*"commit": "([0-9a-f]+)".*/\1 \2/p' "$LAZY_LOCK")
  return 1
}

# === PREVIEW BUILDING ===

echo ""
echo "=== Dotfiles Setup Preview ==="
echo ""
echo "Analyzing current state..."
echo ""

# 1. macOS keyboard settings
if [[ "$OS" == "Darwin" ]]; then
  echo -e "${BLUE}[macOS Keyboard Settings]${NC}"
  
  KEYREPEAT=$(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo "not set")
  INITIALREPEAT=$(defaults read NSGlobalDomain InitialKeyRepeat 2>/dev/null || echo "not set")
  PRESSHOLD=$(defaults read NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || echo "not set")
  
  if [[ "$KEYREPEAT" == "1" ]] && [[ "$INITIALREPEAT" == "10" ]] && [[ "$PRESSHOLD" == "0" ]]; then
    echo -e "  ${GREEN}✓${NC} Keyboard settings already configured for fast Vim navigation"
  else
    echo -e "  ${YELLOW}•${NC} Will configure fast key repeat (KeyRepeat=1, InitialKeyRepeat=10)"
    echo -e "  ${YELLOW}•${NC} Will disable press-and-hold for accents"
    add_preview "macos_keyboard"
  fi
  echo ""
fi

# 2. Homebrew (macOS only)
if [[ "$OS" == "Darwin" ]]; then
  echo -e "${BLUE}[Homebrew]${NC}"
  
  if check_command brew; then
    echo -e "  ${GREEN}✓${NC} Already installed"
    
    # Check for packages to install
    if check_file "$(pwd)/Brewfile"; then
      # Only --verbose lists the packages; the exit code is what's reliable
      if ! brew bundle check --file="$(pwd)/Brewfile" &> /dev/null; then
        BREW_MISSING=$(brew bundle check --verbose --file="$(pwd)/Brewfile" 2>&1 | grep -c "needs to be installed" || true)
        echo -e "  ${YELLOW}•${NC} Will install or upgrade $BREW_MISSING package(s) from Brewfile"
        add_preview "brew_packages"
      else
        echo -e "  ${GREEN}✓${NC} All Brewfile packages already installed"
      fi
    fi
  else
    echo -e "  ${YELLOW}•${NC} Will install Homebrew"
    echo -e "  ${YELLOW}•${NC} Will install all packages from Brewfile"
    add_preview "brew_install"
    add_preview "brew_packages"
  fi
  echo ""
fi

# 3. Oh My Zsh + plugins
echo -e "${BLUE}[Oh My Zsh]${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if check_dir "$HOME/.oh-my-zsh"; then
  echo -e "  ${GREEN}✓${NC} Already installed"
else
  echo -e "  ${YELLOW}•${NC} Will install Oh My Zsh"
  add_preview "ohmyzsh"
fi

if check_dir "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
  echo -e "  ${GREEN}✓${NC} zsh-autosuggestions plugin installed"
else
  echo -e "  ${YELLOW}•${NC} Will install zsh-autosuggestions plugin"
  add_preview "zsh_autosuggestions"
fi

if check_dir "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
  echo -e "  ${GREEN}✓${NC} zsh-syntax-highlighting plugin installed"
else
  echo -e "  ${YELLOW}•${NC} Will install zsh-syntax-highlighting plugin"
  add_preview "zsh_highlighting"
fi
echo ""

# 4. nodenv + Node LTS
echo -e "${BLUE}[Node.js]${NC}"

if check_command nodenv; then
  echo -e "  ${GREEN}✓${NC} nodenv installed"
  
  # Check for nodenv-aliases plugin
  if check_dir "$(nodenv root)/plugins/nodenv-aliases"; then
    echo -e "  ${GREEN}✓${NC} nodenv-aliases plugin installed"
  else
    echo -e "  ${YELLOW}•${NC} Will install nodenv-aliases plugin"
    add_preview "nodenv_aliases"
  fi
  
  # Only bootstrap Node; upgrading versions is left to nodenv
  if [[ -n "$(nodenv versions --bare 2>/dev/null)" ]]; then
    echo -e "  ${GREEN}✓${NC} Node installed (global: $(nodenv global 2>/dev/null))"
  else
    echo -e "  ${YELLOW}•${NC} Will install Node LTS and set as global"
    add_preview "node_install"
  fi
else
  echo -e "  ${YELLOW}•${NC} nodenv not installed yet (will be installed with packages)"
  echo -e "  ${YELLOW}•${NC} Will configure nodenv and install Node LTS after package install"
  add_preview "nodenv_setup"
fi
echo ""

# 5. rbenv + Ruby
echo -e "${BLUE}[Ruby]${NC}"

if check_command rbenv; then
  echo -e "  ${GREEN}✓${NC} rbenv installed"
  
  # Check for rbenv-aliases plugin
  if check_dir "$(rbenv root)/plugins/rbenv-aliases"; then
    echo -e "  ${GREEN}✓${NC} rbenv-aliases plugin installed"
  else
    echo -e "  ${YELLOW}•${NC} Will install rbenv-aliases plugin"
    add_preview "rbenv_aliases"
  fi
  
  # Only bootstrap Ruby; upgrading versions is left to rbenv
  if [[ -n "$(rbenv versions --bare 2>/dev/null)" ]]; then
    echo -e "  ${GREEN}✓${NC} Ruby installed (global: $(rbenv global 2>/dev/null))"
  else
    echo -e "  ${YELLOW}•${NC} Will install latest Ruby and set as global"
    add_preview "ruby_install"
  fi
else
  echo -e "  ${YELLOW}•${NC} rbenv not installed yet (will be installed with packages)"
  echo -e "  ${YELLOW}•${NC} Will configure rbenv and install Ruby after package install"
  add_preview "rbenv_setup"
fi
echo ""

# 6. TPM
echo -e "${BLUE}[Tmux Plugin Manager]${NC}"

if check_dir "$HOME/.tmux/plugins/tpm"; then
  echo -e "  ${GREEN}✓${NC} TPM already installed"
else
  echo -e "  ${YELLOW}•${NC} Will install TPM"
  add_preview "tpm"
fi
echo ""

# 7. Symlinks
echo -e "${BLUE}[Dotfile Symlinks]${NC}"

if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then
  echo -e "  ${GREEN}✓${NC} ~/.zshrc (local stub already exists)"
else
  echo -e "  ${YELLOW}•${NC} Will create local stub: ~/.zshrc -> sources ~/dotfiles/.zshrc"
  add_preview "zshrc_stub"
fi
for pair in "${SYMLINKS[@]}"; do
  target="${pair%%|*}"
  link="${pair#*|}"
  if check_symlink "$link" "$target"; then
    echo -e "  ${GREEN}✓${NC} $link"
  elif [[ -e "$link" ]] && [[ ! -L "$link" ]]; then
    echo -e "  ${YELLOW}•${NC} Will back up existing $link and link it -> $target"
    add_preview "symlinks"
  else
    echo -e "  ${YELLOW}•${NC} Will link: $link -> $target"
    add_preview "symlinks"
  fi
done
for link in "${STALE_LINKS[@]}"; do
  if is_stale_link "$link"; then
    echo -e "  ${YELLOW}•${NC} Will remove stale link: $link"
    add_preview "stale_links"
  fi
done
echo ""

# 8. Neovim plugins
echo -e "${BLUE}[Neovim Plugins]${NC}"

if ! check_dir "$LAZY_DIR"; then
  echo -e "  ${GREEN}✓${NC} Not installed yet (lazy.nvim installs them on first launch)"
elif plugins_drifted; then
  echo -e "  ${YELLOW}•${NC} Will restore plugins to the versions in lazy-lock.json"
  add_preview "nvim_plugins"
else
  echo -e "  ${GREEN}✓${NC} Plugins match lazy-lock.json"
fi
echo ""

# === CONFIRMATION ===

if [[ ${#PREVIEW_ITEMS[@]} -eq 0 ]]; then
  echo -e "${GREEN}Everything is already set up! Nothing to do.${NC}"
  echo ""
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Proceed with setup? [y/N] " -n 1 -r
echo ""
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Setup cancelled."
  exit 0
fi

# === EXECUTION ===

echo "=== Running Setup ==="
echo ""

# 1. macOS keyboard settings
if has_preview macos_keyboard; then
  echo -e "${BLUE}Configuring macOS keyboard settings...${NC}"
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  echo -e "${GREEN}✓${NC} Keyboard settings configured"
  echo ""
fi

# 2. Install Homebrew
if has_preview brew_install; then
  echo -e "${BLUE}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add to current session PATH
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo -e "${GREEN}✓${NC} Homebrew installed"
  echo ""
fi

# 3. Install packages
if has_preview brew_packages && [[ "$OS" == "Darwin" ]]; then
  echo -e "${BLUE}Installing packages from Brewfile...${NC}"
  brew bundle --file="$(pwd)/Brewfile"
  echo -e "${GREEN}✓${NC} Packages installed"
  echo ""
fi

# For Linux, install packages with apt
if [[ "$OS" == "Linux" ]]; then
  echo -e "${BLUE}Installing packages (Linux)...${NC}"
  
  APT_PACKAGES=(zsh fzf direnv tmux ripgrep)
  
  for pkg in "${APT_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
      sudo apt install -y "$pkg"
    fi
  done
  
  # nodenv (manual install on Linux)
  if ! check_dir "$HOME/.nodenv"; then
    git clone https://github.com/nodenv/nodenv.git "$HOME/.nodenv"
    git clone https://github.com/nodenv/node-build.git "$HOME/.nodenv/plugins/node-build"
  fi
  
  # rbenv (manual install on Linux)
  if ! check_dir "$HOME/.rbenv"; then
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
    git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
  fi
  
  echo -e "${GREEN}✓${NC} Packages installed"
  echo ""
fi

# 4. Oh My Zsh
if has_preview ohmyzsh; then
  echo -e "${BLUE}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo -e "${GREEN}✓${NC} Oh My Zsh installed"
  echo ""
fi

# 5. Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if has_preview zsh_autosuggestions; then
  echo -e "${BLUE}Installing zsh-autosuggestions...${NC}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  echo -e "${GREEN}✓${NC} zsh-autosuggestions installed"
  echo ""
fi

if has_preview zsh_highlighting; then
  echo -e "${BLUE}Installing zsh-syntax-highlighting...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  echo -e "${GREEN}✓${NC} zsh-syntax-highlighting installed"
  echo ""
fi

# 6. nodenv plugins
if has_preview nodenv_aliases || has_preview nodenv_setup; then
  echo -e "${BLUE}Setting up nodenv plugins...${NC}"
  
  # Ensure nodenv is available
  if [[ -d "$HOME/.nodenv/bin" ]]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
  fi
  
  # nodenv-aliases
  if ! check_dir "$(nodenv root)/plugins/nodenv-aliases"; then
    git clone https://github.com/nodenv/nodenv-aliases.git "$(nodenv root)/plugins/nodenv-aliases"
  fi
  
  echo -e "${GREEN}✓${NC} nodenv plugins configured"
  echo ""
fi

# 7. Install Node LTS
if has_preview node_install || has_preview nodenv_setup; then
  echo -e "${BLUE}Installing Node.js LTS...${NC}"
  
  # Ensure nodenv is available
  if [[ -d "$HOME/.nodenv/bin" ]]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
  fi
  
  NODE_LTS=$(curl -s https://nodejs.org/dist/index.json 2>/dev/null | grep -o '"version":"v[0-9.]*".*"lts":"[A-Za-z]' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || echo "")
  
  if [[ -n "$NODE_LTS" ]]; then
    nodenv install --skip-existing "$NODE_LTS"
    nodenv global "$NODE_LTS"
    echo -e "${GREEN}✓${NC} Node $NODE_LTS (LTS) installed and set as global"
  else
    echo -e "${YELLOW}⚠${NC} Could not determine LTS version, skipping Node install"
  fi
  echo ""
fi

# 8. rbenv plugins
if has_preview rbenv_aliases || has_preview rbenv_setup; then
  echo -e "${BLUE}Setting up rbenv plugins...${NC}"
  
  # Ensure rbenv is available
  if [[ -d "$HOME/.rbenv/bin" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  
  # rbenv-aliases
  if ! check_dir "$(rbenv root)/plugins/rbenv-aliases"; then
    git clone https://github.com/tpope/rbenv-aliases.git "$(rbenv root)/plugins/rbenv-aliases"
  fi
  
  echo -e "${GREEN}✓${NC} rbenv plugins configured"
  echo ""
fi

# 9. Install Ruby
if has_preview ruby_install || has_preview rbenv_setup; then
  echo -e "${BLUE}Installing Ruby...${NC}"
  
  # Ensure rbenv is available
  if [[ -d "$HOME/.rbenv/bin" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  
  RUBY_LATEST=$(rbenv install -l 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 || echo "")
  
  if [[ -n "$RUBY_LATEST" ]]; then
    rbenv install --skip-existing "$RUBY_LATEST"
    rbenv global "$RUBY_LATEST"
    echo -e "${GREEN}✓${NC} Ruby $RUBY_LATEST installed and set as global"
  else
    echo -e "${YELLOW}⚠${NC} Could not determine Ruby version, skipping Ruby install"
  fi
  echo ""
fi

# 10. TPM
if has_preview tpm; then
  echo -e "${BLUE}Installing Tmux Plugin Manager...${NC}"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo -e "${GREEN}✓${NC} TPM installed"
  echo ""
fi

# 11a. Local ~/.zshrc stub
#
# We deliberately do NOT symlink ~/.zshrc into the dotfiles repo. Tools like
# Homebrew, SDKMAN, rustup, nvm, bun, etc. love to append lines to ~/.zshrc on
# install, and if it were a symlink those appends would dirty the dotfiles repo
# (and leak machine-specific PATH entries into shared config).
#
# Instead, ~/.zshrc is a tiny machine-local stub that sources the shared
# ~/dotfiles/.zshrc. Anything machine-specific lives in the local stub.
if has_preview zshrc_stub; then
  echo -e "${BLUE}Creating local ~/.zshrc stub...${NC}"

  if [[ -e "$HOME/.zshrc" ]] || [[ -L "$HOME/.zshrc" ]]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    mv "$HOME/.zshrc" "$BACKUP"
    echo -e "  ${YELLOW}•${NC} Existing ~/.zshrc moved to $BACKUP"
  fi

  cat > "$HOME/.zshrc" <<'EOF'
# Machine-local zshrc.
#
# Shared shell config lives in ~/dotfiles/.zshrc and is sourced below.
# Put anything machine-specific (PATH additions from brew, sdkman, nvm,
# bun, android sdk, etc.) AFTER the source line. Installers that append
# to ~/.zshrc will land here and won't dirty the dotfiles repo.
source "$HOME/dotfiles/.zshrc"
EOF

  echo -e "${GREEN}✓${NC} Created ~/.zshrc stub"
  echo ""
fi

# 11b. Symlinks
#
# Only wrong links are touched. `ln -n` replaces an existing link to a directory
# instead of creating a link inside it, and real files/folders are backed up first.
if has_preview symlinks; then
  echo -e "${BLUE}Creating symlinks...${NC}"

  for pair in "${SYMLINKS[@]}"; do
    target="${pair%%|*}"
    link="${pair#*|}"
    check_symlink "$link" "$target" && continue

    mkdir -p "$(dirname "$link")"
    if [[ -e "$link" ]] && [[ ! -L "$link" ]]; then
      BACKUP="$link.backup.$(date +%Y%m%d%H%M%S)"
      mv "$link" "$BACKUP"
      echo -e "  ${YELLOW}•${NC} Existing $link moved to $BACKUP"
    fi
    ln -sfn "$target" "$link"
    echo -e "  ${GREEN}✓${NC} $link -> $target"
  done
  echo ""
fi

# 11c. Stale links
if has_preview stale_links; then
  echo -e "${BLUE}Removing stale links...${NC}"
  for link in "${STALE_LINKS[@]}"; do
    if is_stale_link "$link"; then
      rm "$link"
      echo -e "  ${GREEN}✓${NC} Removed $link"
    fi
  done
  echo ""
fi

# 12. Neovim plugins
if has_preview nvim_plugins; then
  echo -e "${BLUE}Restoring Neovim plugins from lazy-lock.json...${NC}"
  nvim --headless "+Lazy! restore" +qa
  echo -e "${GREEN}✓${NC} Plugins restored"
  echo ""
fi

# === POST-INSTALL INSTRUCTIONS ===

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Restart your terminal (or run: exec zsh)"
if [[ "$OS" == "Darwin" ]] && has_preview macos_keyboard; then
  echo "  2. Log out and log back in for keyboard settings to take effect"
fi
echo "  3. Open nvim - plugins will install automatically"
echo "  4. In tmux, press prefix + I (capital i) to install plugins"
echo ""
echo "Enjoy your dotfiles! 🚀"
echo ""
