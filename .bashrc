echo running $0
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
[[ ! -d $ZDOTDIR ]] && ln -fs $DOTFILES $ZDOTDIR

[[ -d $HOME/.cargo ]] && . "$HOME/.cargo/env"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
