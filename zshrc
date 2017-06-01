# enable antigen
source /usr/local/share/antigen/antigen.zsh

# Load oh-my-zsh
antigen use oh-my-zsh

# Bundles
antigen bundles <<EOBUNDLES
  brew
  git
  gem
  heroku
  osx
  fasd
  mafredri/zsh-async
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  sindresorhus/pure
  # these should be at last!
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-history-substring-search
EOBUNDLES

antigen apply

# Init rbenv and nodenv
eval "$(rbenv init -)"
eval "$(nodenv init -)"

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases