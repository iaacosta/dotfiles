#!/bin/bash

OS="$(uname -s)"

echo "=== Dotfiles Setup ==="
echo ""

# Symlinks (safe to run)
ln -sf ~/.config/.zshrc ~/.zshrc
ln -sf ~/.config/.gitconfig ~/.gitconfig
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
echo "[done] Symlinked .zshrc, .gitconfig, and .tmux.conf"
echo ""

echo "=== Manual steps ==="
echo ""

echo "1. Install zsh and set as default:"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install zsh"
else
  echo "   sudo apt install zsh"
fi
echo '   chsh -s $(which zsh)'
echo ""

echo "2. Install Oh My Zsh:"
echo '   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
echo ""

echo "3. Install zsh plugins:"
echo '   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
echo '   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
echo ""

echo "4. Install nodenv:"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install nodenv"
else
  echo "   git clone https://github.com/nodenv/nodenv.git ~/.nodenv"
  echo "   git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build"
  echo "   # Add to PATH: export PATH=\"\$HOME/.nodenv/bin:\$PATH\""
  echo "   # Then: eval \"\$(~/.nodenv/bin/nodenv init -)\""
fi
echo ""

echo "5. Install rbenv:"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install rbenv"
else
  echo "   git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
  echo "   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
  echo "   # Add to PATH: export PATH=\"\$HOME/.rbenv/bin:\$PATH\""
  echo "   # Then: eval \"\$(~/.rbenv/bin/rbenv init -)\""
fi
echo ""

echo "6. Install TPM (Tmux Plugin Manager):"
echo "   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
echo "   # Then in tmux, press: prefix + I (to install plugins)"
echo ""

echo "7. Install packages:"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install fzf neovim direnv tmux go"
else
  echo "   sudo apt install fzf direnv tmux golang-go fonts-noto-color-emoji"
  echo ""
  echo "   # Neovim (apt version is outdated, use one of these):"
  echo "   # Option 1 - Download appimage:"
  echo "   #   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
  echo "   #   chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/local/bin/nvim"
  echo "   # Option 2 - Build from source:"
  echo "   #   https://github.com/neovim/neovim/blob/master/BUILD.md"
fi
echo ""

echo "8. Install font (0xProto Nerd Font):"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install --cask font-0xproto-nerd-font"
else
  echo "   # WSL: Install on Windows side, download from:"
  echo "   # https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip"
  echo "   # Then set font in Windows Terminal settings"
fi
echo ""

echo "9. Install Ghostty:"
if [[ "$OS" == "Darwin" ]]; then
  echo "   brew install --cask ghostty"
else
  echo "   # WSL: Use Windows Terminal or Ghostty on Windows side"
fi
echo ""

echo "10. Install OpenCode:"
echo '   curl -fsSL https://opencode.ai/install | bash'
echo ""

echo "11. Open nvim and let Lazy install plugins automatically"
echo ""
echo "=== Done ==="
