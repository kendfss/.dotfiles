#!/usr/bin/env -S zsh

export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh


[[ -z $ZDOTDIR ]] && echo "\$ZDOTDIR is undefined" && exit 1
[[ -z $DOTFILES ]] && echo "\$DOTFILES is undefined" && exit 1

if [ ! -d ~/.config ]; then
    if [ -e ~/.config ]; then
        echo "$HOME/.config exists and is not a directory" >&2
        exit 1
    else
        mkdir $HOME/.config
    fi
fi

source "$DOTFILES/functions.zsh"

symlinkDialogue "$DOTFILES" "$ZDOTDIR"

export PATH="$DOTFILES/scripts:$PATH:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin"

for name in "$DOTFILES/scripts"/*; do
    [ -x "$name" ] || continue
    target="/usr/bin/$(basename "$name")"
    symlinkDialogue "$name" "$target"
done

symlinkDialogue "$DOTFILES/glow" "$HOME/.config/glow"

symlinkDialogue "$DOTFILES/mpv" "$HOME/.config/mpv"

symlinkDialogue "$DOTFILES/helix" "$HOME/.config/helix"


[ ! -e "$HOME/.config/cheat/cheatsheets" ] && mkdir -p "$HOME/.config/cheat/cheatsheets"
symlinkDialogue "$DOTFILES/personal" "$HOME/.config/cheat/cheatsheets/personal"

for item in $DOTFILES/.*; do 
  [ -f "$item" ] || continue
  local target="$HOME/$(basename "$item")"
  symlinkDialogue "$item" "$target"
done

_rm() {
  for arg in "$@"; do 
    [[ -d "$arg" ]] && rm -rf "$arg"
    [[ -L "$arg" ]] && rm "$arg"
  done
}

[[ -z "$CLONEDIR" ]] && export CLONEDIR=$HOME/gitclone/clones && mkdir -p $CLONEDIR

if [[ -n "$(command -v pkg)" ]]; then
  pkg update && pkg upgrade

  pkg install -y openssh tmux helix direnv ripgrep jq termux-services perl || return 1
  _rm "$ZDOTDIR/fast-syntax-highlighting" && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZDOTDIR/zsh-syntax-highlighting" 
  _rm "$ZDOTDIR/zsh-autosuggestions" && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/zsh-autosuggestions" 
  # _rm "$HOME/.tmux/plugins" && git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

else
  echo "pkg is not available. Make sure you have the package manager for termux installed." && return 1
fi

echo reloading shell
reload
