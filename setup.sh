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
      BREW_MISSING=$(brew bundle check --file="$(pwd)/Brewfile" 2>&1 | grep -c "needs to be installed" || true)
      if [[ "$BREW_MISSING" -gt 0 ]]; then
        echo -e "  ${YELLOW}•${NC} Will install $BREW_MISSING package(s) from Brewfile"
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
  
  # Get latest LTS version
  echo -e "  ${YELLOW}...${NC} Checking for latest Node LTS version..."
  NODE_LTS=$(curl -s https://nodejs.org/dist/index.json 2>/dev/null | grep -o '"version":"v[0-9.]*".*"lts":"[A-Za-z]' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || echo "")
  
  if [[ -n "$NODE_LTS" ]]; then
    if nodenv versions 2>/dev/null | grep -q "$NODE_LTS"; then
      echo -e "  ${GREEN}✓${NC} Node $NODE_LTS (LTS) already installed"
      
      CURRENT_GLOBAL=$(nodenv global 2>/dev/null || echo "")
      if [[ "$CURRENT_GLOBAL" == "$NODE_LTS" ]]; then
        echo -e "  ${GREEN}✓${NC} Node $NODE_LTS is set as global"
      else
        echo -e "  ${YELLOW}•${NC} Will set Node $NODE_LTS as global (currently: $CURRENT_GLOBAL)"
        add_preview "node_global"
      fi
    else
      echo -e "  ${YELLOW}•${NC} Will install Node $NODE_LTS (LTS) and set as global"
      add_preview "node_install"
    fi
  else
    echo -e "  ${YELLOW}•${NC} Could not determine LTS version (will install latest available)"
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
  
  # Get latest stable Ruby
  RUBY_LATEST=$(rbenv install -l 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 || echo "")
  
  if [[ -n "$RUBY_LATEST" ]]; then
    if rbenv versions 2>/dev/null | grep -q "$RUBY_LATEST"; then
      echo -e "  ${GREEN}✓${NC} Ruby $RUBY_LATEST already installed"
      
      CURRENT_GLOBAL=$(rbenv global 2>/dev/null || echo "")
      if [[ "$CURRENT_GLOBAL" == "$RUBY_LATEST" ]]; then
        echo -e "  ${GREEN}✓${NC} Ruby $RUBY_LATEST is set as global"
      else
        echo -e "  ${YELLOW}•${NC} Will set Ruby $RUBY_LATEST as global (currently: $CURRENT_GLOBAL)"
        add_preview "ruby_global"
      fi
    else
      echo -e "  ${YELLOW}•${NC} Will install Ruby $RUBY_LATEST and set as global"
      add_preview "ruby_install"
    fi
  else
    echo -e "  ${YELLOW}•${NC} Will install latest Ruby version"
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

check_and_add_symlink() {
  local target="$1"
  local link="$2"
  
  if check_symlink "$link" "$target"; then
    echo -e "  ${GREEN}✓${NC} $link"
  else
    echo -e "  ${YELLOW}•${NC} Will link: $link -> $target"
    add_preview "symlink_$link"
  fi
}

if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then
  echo -e "  ${GREEN}✓${NC} ~/.zshrc (local stub already exists)"
else
  echo -e "  ${YELLOW}•${NC} Will create local stub: ~/.zshrc -> sources ~/dotfiles/.zshrc"
  add_preview "zshrc_stub"
fi
check_and_add_symlink "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
check_and_add_symlink "$HOME/dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
check_and_add_symlink "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
check_and_add_symlink "$HOME/dotfiles/ghostty" "$HOME/.config/ghostty"
check_and_add_symlink "$HOME/dotfiles/opencode" "$HOME/.config/opencode"
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " macos_keyboard " ]]; then
  echo -e "${BLUE}Configuring macOS keyboard settings...${NC}"
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  echo -e "${GREEN}✓${NC} Keyboard settings configured"
  echo ""
fi

# 2. Install Homebrew
if [[ " ${PREVIEW_ITEMS[@]} " =~ " brew_install " ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " brew_packages " ]] && [[ "$OS" == "Darwin" ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " ohmyzsh " ]]; then
  echo -e "${BLUE}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo -e "${GREEN}✓${NC} Oh My Zsh installed"
  echo ""
fi

# 5. Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ " ${PREVIEW_ITEMS[@]} " =~ " zsh_autosuggestions " ]]; then
  echo -e "${BLUE}Installing zsh-autosuggestions...${NC}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  echo -e "${GREEN}✓${NC} zsh-autosuggestions installed"
  echo ""
fi

if [[ " ${PREVIEW_ITEMS[@]} " =~ " zsh_highlighting " ]]; then
  echo -e "${BLUE}Installing zsh-syntax-highlighting...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  echo -e "${GREEN}✓${NC} zsh-syntax-highlighting installed"
  echo ""
fi

# 6. nodenv plugins
if [[ " ${PREVIEW_ITEMS[@]} " =~ " nodenv_aliases " ]] || [[ " ${PREVIEW_ITEMS[@]} " =~ " nodenv_setup " ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " node_install " ]] || [[ " ${PREVIEW_ITEMS[@]} " =~ " node_global " ]]; then
  echo -e "${BLUE}Installing Node.js LTS...${NC}"
  
  # Ensure nodenv is available
  if [[ -d "$HOME/.nodenv/bin" ]]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
  fi
  
  NODE_LTS=$(curl -s https://nodejs.org/dist/index.json 2>/dev/null | grep -o '"version":"v[0-9.]*".*"lts":"[A-Za-z]' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || echo "")
  
  if [[ -n "$NODE_LTS" ]]; then
    if ! nodenv versions 2>/dev/null | grep -q "$NODE_LTS"; then
      nodenv install "$NODE_LTS"
    fi
    nodenv global "$NODE_LTS"
    echo -e "${GREEN}✓${NC} Node $NODE_LTS (LTS) installed and set as global"
  else
    echo -e "${YELLOW}⚠${NC} Could not determine LTS version, skipping Node install"
  fi
  echo ""
fi

# 8. rbenv plugins
if [[ " ${PREVIEW_ITEMS[@]} " =~ " rbenv_aliases " ]] || [[ " ${PREVIEW_ITEMS[@]} " =~ " rbenv_setup " ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " ruby_install " ]] || [[ " ${PREVIEW_ITEMS[@]} " =~ " ruby_global " ]]; then
  echo -e "${BLUE}Installing Ruby...${NC}"
  
  # Ensure rbenv is available
  if [[ -d "$HOME/.rbenv/bin" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  
  RUBY_LATEST=$(rbenv install -l 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 || echo "")
  
  if [[ -n "$RUBY_LATEST" ]]; then
    if ! rbenv versions 2>/dev/null | grep -q "$RUBY_LATEST"; then
      rbenv install "$RUBY_LATEST"
    fi
    rbenv global "$RUBY_LATEST"
    echo -e "${GREEN}✓${NC} Ruby $RUBY_LATEST installed and set as global"
  else
    echo -e "${YELLOW}⚠${NC} Could not determine Ruby version, skipping Ruby install"
  fi
  echo ""
fi

# 10. TPM
if [[ " ${PREVIEW_ITEMS[@]} " =~ " tpm " ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " zshrc_stub " ]]; then
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
if [[ " ${PREVIEW_ITEMS[@]} " =~ " symlink_ " ]]; then
  echo -e "${BLUE}Creating symlinks...${NC}"
  
  mkdir -p ~/.config
  
  ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
  ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
  ln -sf ~/dotfiles/nvim ~/.config/nvim
  ln -sf ~/dotfiles/ghostty ~/.config/ghostty
  ln -sf ~/dotfiles/opencode ~/.config/opencode
  ln -sf ~/dotfiles/.global-gitignore ~/.gitignore
  
  echo -e "${GREEN}✓${NC} Symlinks created"
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
if [[ "$OS" == "Darwin" ]] && [[ " ${PREVIEW_ITEMS[@]} " =~ " macos_keyboard " ]]; then
  echo "  2. Log out and log back in for keyboard settings to take effect"
fi
echo "  3. Open nvim - plugins will install automatically"
echo "  4. In tmux, press prefix + I (capital i) to install plugins"
echo ""
echo "Enjoy your dotfiles! 🚀"
echo ""
