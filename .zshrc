# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# Oh my zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="simple"

plugins=(
	docker-compose
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# zsh highlight / autosuggestions
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
zle_highlight+=(paste:none)

# Brew
if [[ "$(uname -s)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Node (nodenv)
if [[ -d "$HOME/.nodenv" ]]; then
  export PATH="$HOME/.nodenv/bin:$PATH"
fi
if command -v nodenv &> /dev/null; then
  eval "$(nodenv init -)"
fi

# Ruby (rbenv)
if [[ -d "$HOME/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
fi
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init -)"
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Direnv
eval "$(direnv hook zsh)"

# Golang
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/bin"

# Sqlite
if [[ "$(uname -s)" == "Darwin" ]]; then
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
fi

# Custom configs
ulimit -n 8192
alias vim=nvim
export EDITOR=nvim
alias glo="git log --oneline -n 20"
