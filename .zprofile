export DOTFILES=$HOME/.dotfiles

[[ -d "$HOME/.cargo" ]] && . "$HOME/.cargo/env"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export GOPATH="$HOME/go"

if [[ -x "$(command -v go)" ]]; then
  export GOS=$(go env GOROOT)
  export GOP=$(go env GOPATH)
fi

if [[ -z $(command -v set_title) ]]; then
  source "$DOTFILES/termsupport.zsh" 
  source "$DOTFILES/functions.zsh" 
  export SKIPPROFILE=1 # prevent re-sourcing this file if/when the .zshrc is sourced
fi

# set_title

[ -d "$HOME/.elan" ] && export PATH="$PATH:$HOME/.elan/bin"
