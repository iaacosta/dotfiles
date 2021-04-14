# theme 
ZSH_THEME="josh"

# Init rbenv and nodenv
eval "$(rbenv init -)"
eval "$(nodenv init -)"

# use openssl installed with brew
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# History settings
HISTFILE=~/.zhistory
HISTSIZE=100000
SAVEHIST=100000

# Don't show duplicate history entires
setopt hist_find_no_dups

# Remove unnecessary blanks from history
setopt hist_reduce_blanks

# Share history between instances
setopt share_history

setopt hist_ignore_space
