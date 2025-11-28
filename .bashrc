export DOTFILES="$HOME/.dotfiles"
export BASH_PLUGINS="$DOTFILES/bash-plugins"


[ -d "$BASH_PLUGINS/ble.sh" ] && source "$BASH_PLUGINS/ble.sh/out/ble.sh"

source "$DOTFILES/prompts.bash"
export SHELL=bash
reload() {
  exec $SHELL -l
}
source "$DOTFILES/keybindings.zsh"
source "$DOTFILES/aliases.zsh"

[ -d "$HOME/.cargo" ] && . "$HOME/.cargo/env"
[ -x "$(command -v direnv)" ] && eval "$(direnv hook bash)"

PATH="$(echo "$PATH" | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"
export PATH


[[ $- != *i* ]] && return
if [ -z "$TMUX" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ]; then
    exec tmux
fi
