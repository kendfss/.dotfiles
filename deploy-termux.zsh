#!/bin/env zsh
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"
PATH="$PATH:$DOTFILES/scripts:$HOME/.local/bin:$HOME/go/bin"
[ -z "$CLONEDIR" ] && export CLONEDIR=$HOME/gitclone/clones
[ -z "$REPO_HOST" ] && export REPO_HOST=https://github.com


[ -z "$DOTFILES" ] && echo "\$DOTFILES is undefined" && exit 1

source "$DOTFILES/functions.zsh" || { echo "couldn't source functions" && exit 1; }

symlinkDialogue $HOME/.{dotfiles,config}/helix
symlinkDialogue $HOME/.{dotfiles,config}/glow
symlinkDialogue $HOME/.{dotfiles,config}/mpv
symlinkDialogue $HOME/.{dotfiles,config}/cheat
symlinkDialogue $HOME/.{dotfiles,termux}/boot

for item in $DOTFILES/.*; do 
  [ -f "$item" ] || continue
  target="$HOME/$(basename "$item")"
  symlinkDialogue "$item" "$target"
done

for name in "$DOTFILES/scripts"/*; do
    [ -x "$name" ] || continue
    target="$TERMUX__PREFIX/bin/$(basename "$name")"
    symlinkDialogue "$name" "$target"
done

if [[ -n "$(command -v pkg)" ]]; then
  pkg update && pkg upgrade

  pkg install -y openssh fzf zsh tmux helix direnv ripgrep jq termux-services perl glow bat clang fd mpv mandoc iproute2 tree shellcheck || return 1

  export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
  mkdir -p "$ZSH_PLUGINS"
  symlinkDialogue "$ZSH_PLUGINS" "$TERMUX__ROOTFS_DIR/usr/share/zsh/plugins"
  for name in zsh-{autosuggestions,syntax-highlighting}; do
    [[ ! -e "$ZSH_PLUGINS/$name" ]] && { git clone --depth=1 "https://github.com/zsh-users/$name" "$ZSH_PLUGINS/$name" && source "$ZSH_PLUGINS/$name/$name.zsh"; }
  done
  [[ ! -e "$ZSH_PLUGINS/zsh-sweep" ]] && { git clone https://github.com/psprint/zsh-sweep "$ZSH_PLUGINS/zsh-sweep" && source "$DOTFILES/.zshrc"; }

  export TMUX_PLUGINS="$HOME/.tmux/plugins"
  local origin="$(pwd)"
  mkdir -p "$TMUX_PLUGINS"
  { [ ! -e "$CLONEDIR/tmux-plugins/tpm" ] && { clone tmux-plugins/tpm || { echo "couldn't clone tmux-plugins/tpm"; exit 1; }; }; } || cd "$CLONEDIR/tmux-plugins/tpm"
  { symlinkDialogue "$(pwd)" "$TMUX_PLUGINS/tpm" && cd "$origin"; } || exit 1

  export BASH_PLUGINS="$DOTFILES/bash-plugins"
  mkdir -p "$BASH_PLUGINS"
  { [[ ! -e "$BASH_PLUGINS/ble.sh" ]] && { git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$BASH_PLUGINS/ble.sh" && make -C "$BASH_PLUGINS/ble.sh" && source "$BASH_PLUGINS/ble.sh/out/ble.sh"; }; } || echo "couldn't find, or clone, akinomyoga/ble.sh" && exit 1

else
  echo "pkg is not available. Make sure you have the package manager for termux installed." && return 1
fi

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

echo reloading shell
reload
