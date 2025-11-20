#!/usr/bin/env zsh
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"
PATH="$PATH:$DOTFILES/scripts:$HOME/.local/bin:$HOME/go/bin"
[ -z "$CLONEDIR" ] && export CLONEDIR=$HOME/gitclone/clones


[ -z "$DOTFILES" ] && echo "\$DOTFILES is undefined" && exit 1

source "$DOTFILES/functions.zsh" || { echo "couldn't source functions" && exit 1; }

symlinkDialogue $HOME/.{dotfiles,config}/helix
symlinkDialogue $HOME/.{dotfiles,config}/glow
symlinkDialogue $HOME/.{dotfiles,termux}/boot

[ ! -e "$HOME/.config/cheat/cheatsheets" ] && mkdir -p "$HOME/.config/cheat/cheatsheets"
symlinkDialogue ~/.{dotfiles,config/cheat/cheatsheets}/personal

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

  pkg install -y openssh fzf zsh tmux helix direnv ripgrep jq termux-services perl glow bat clang fd mpv mandoc iproute2 || return 1

  export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
  mkdir -p "$ZSH_PLUGINS"
  symlinkDialogue "$ZSH_PLUGINS" "$TERMUX__ROOTFS_DIR/usr/share/zsh/plugins"
  for name in zsh-{autosuggestions,syntax-highlighting}; do
    [ ! -e "$DOTFILES/$name" ] && git clone --depth=1 "https://github.com/zsh-users/$name" "$ZSH_PLUGINS/$name" && source "$ZSH_PLUGINS/$name/$name.zsh"
  done

  export TMUX_PLUGINS="$HOME/.tmux/plugins"
  local origin="$(pwd)"
  mkdir -p "$TMUX_PLUGINS"
  if clone tmux-plugins/tpm; then
    symlinkDialogue "$(pwd)" "$TMUX_PLUGINS/tpm"
    cd "$origin"
  else
    echo "couldn't clone tmux-plugins/tpm"
    cd "$origin"
    exit 1
  fi
  # [ ! -e "$TMUX_PLUGINS" ] && git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$TMUX_PLUGINS/tpm"

else
  echo "pkg is not available. Make sure you have the package manager for termux installed." && return 1
fi

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

echo reloading shell
reload
