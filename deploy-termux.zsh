#!/usr/bin/env -S zsh

export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh


# [[ -L $ZDOTDIR ]] && rm $ZDOTDIR
# [[ -d $ZDOTDIR ]] && rm -rf $ZDOTDIR

[[ -z $ZDOTDIR ]] && echo "\$ZDOTDIR is undefined" && exit 1
[[ -z $DOTFILES ]] && echo "\$DOTFILES is undefined" && exit 1

if [ ! -d ~/.config ]; then
    if [ -e ~/.config ]; then
        echo "$HOME/.config exists and is not a directory" >&2
        exit 1
    else
        mkdir ~/.config
    fi
fi

source "$ZDOTDIR/functions.zsh"

symlinkDialogue "$DOTFILES" "$ZDOTDIR"

export PATH="$DOTFILES/scripts:$PATH:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin"

cd $ZDOTDIR

for name in "$DOTFILES"/scripts/*; do
    [ -x "$name" ] || continue
    target="/usr/bin/$(basename "$name")"
    symlinkDialogue "$name" "$target"
done

symlinkDialogue "$DOTFILES/glow" "$HOME/.config/glow"

symlinkDialogue "$DOTFILES/mpv" "$HOME/.config/mpv"

symlinkDialogue "$DOTFILES/helix" "$HOME/.config/helix"


[ ! -e "$HOME/.config/cheat/cheatsheets" ] && mkdir -p "$HOME/.config/cheat/cheatsheets"
symlinkDialogue "$DOTFILES/personal" "$HOME/.config/cheat/cheatsheets/personal"

for item in $ZDOTDIR/.*; do 
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

  pkg install -y tsu zsh tmux helix git gh golang{,-doc} shfmt direnv ripgrep jq || return 1
  gochain
	gh auth login
  _rm "$ZDOTDIR/fast-syntax-highlighting" && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZDOTDIR/zsh-syntax-highlighting" 
  _rm "$ZDOTDIR/zsh-autosuggestions" && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/zsh-autosuggestions" 
  # _rm "$HOME/.tmux/plugins" && git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  pkg install -y wget tree glow typst tinymist psmisc coreutils mpv lua-language-server StyLua taplo build-essential bat gcc && cd $HOME 

  type -p curl >/dev/null || pkg install -y curl

  # pkg install -y python3{,-{sqlparse,wheel,numpy,Pillow,PyAudio,attrs,audioread,binaryornot,bitarray,boolean.py,click,dill,google-{auth{-{httplib2,oauthlib},},api-{core,python-client}},httpx,requests,language-server,path,pandas,pathtools,pip,pipenv,pipx,platformdirs,re-assert,send2trash,scruffy,tabulate,virtualenv,argcomplete,click,jedi,parsing,parso,userpath,yaml}}
  
	# [[ -z "$(command -v npm)" ]] && pkg install -y nodejs && npm i -g {bash,awk,yaml}-language-server deno || return 1

  cd "$DOTFILES"

	# [[ ! -x "$(command -v rustup)" ]] && pkg install -y rustup rust-analyzer mdBook

	# source "$HOME/.cargo/env"

	# [[ ! -x "$(command -v tree-sitter-cli)" ]] && pkg install -y tree-sitter

else
  echo "pkg install is not available. Make sure you have the package manager for Void Linux installed." && return 1
fi
