[ -d "$DOTFILES/ble.sh" ] && source "$DOTFILES/ble.sh/out/ble.sh"
# [[ $- == *i* ]] && source -- "$DOTFILES/ble.sh/out/ble.sh" --attach=none

export DOTFILES="$HOME/.dotfiles"


source "$DOTFILES/prompts.bash"
export SHELL=bash
reload() {
  exec $SHELL -l
}
source "$DOTFILES/keybindings.zsh"
source "$DOTFILES/aliases.zsh"

[ -d $HOME/.cargo ] && . "$HOME/.cargo/env"
[ -x "$(command -v direnv)" ] && eval "$(direnv hook bash)"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# [[ !${BLE_VERSION-} ]] || ble-attach

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"


[[ $- != *i* ]] && return
if [ -z "$TMUX" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ]; then
    exec tmux
fi
