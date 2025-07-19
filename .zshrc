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
eval "$(/opt/homebrew/bin/brew shellenv)"

# Node
eval "$(nodenv init -)"

# Ruby
eval "$(rbenv init -)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Direnv
eval "$(direnv hook zsh)"

# Golang
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/bin"

# Sqlite
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

# Postgres
export PATH="/opt/homebrew/opt/postgresql@11/bin:$PATH"

# Custom configs
ulimit -n 8192
alias vim=nvim
export EDITOR=nvim
