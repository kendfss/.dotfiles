#!/bin/env zsh
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"

mkdir -p "$HOME/.config" || { echo "couldn't make ~/.config directory" && exit 1; }

source "$DOTFILES/functions.zsh" || { echo "couldn't source functions" && exit 1; }

([ -z "$(which xbps)" ] && curl -sL "https://github.com/kendfss/xbps/releases/latest/download/xbps_linux_$(uname -m).tar.gz" | tar -xz -O xbps | sudo tee /usr/bin/xbps >/dev/null && sudo chmod +x /usr/bin/xbps && echo "personal xbps successfully installed") || echo personal xbps already installed

if [ ! -d ~/.config ]; then
    if [ -e ~/.config ]; then
        echo "$HOME/.config exists and is not a directory" >&2
        exit 1
    else
        mkdir ~/.config
    fi
fi

source "$DOTFILES/functions.zsh"

cd $DOTFILES

linkToHome() {
  for arg in "$@"; do
    [[ -f $DOTFILES/$arg ]] && ln -f "$DOTFILES/$arg" "$HOME/$arg"
    [[ -d $DOTFILES/$arg ]] && ln -fs "$DOTFILES/$arg" "$HOME/$arg"
  done
}


PATH="$DOTFILES/scripts:$PATH:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin"
for name in "$DOTFILES"/scripts/*; do
    [ -x "$name" ] || continue
    target="/usr/bin/$(basename "$name")"
    symlinkDialogue "$name" "$target"
done
for name in "$DOTFILES"/services/*; do
    [ -d "$name" ] || continue
    local base="$(basename "$name")"
    symlinkDialogue "$name" "/etc/sv/$base"
    symlinkDialogue "$name" "/var/service/$base"
done
symlinkDialogue "$DOTFILES/glow" "$HOME/.config/glow"

symlinkDialogue "$DOTFILES/mpv" "$HOME/.config"

mkdir -p "$HOME/.config/cheat/cheatsheets"
symlinkDialogue "$DOTFILES/personal" "$HOME/.config/cheat/cheatsheets"

for item in $DOTFILES/.*; do 
  [ -f "$item" ] || continue
  local target="$HOME/$(basename "$item")"
  symlinkDialogue "$item" "$target"
done

symlinkDialogue "$DOTFILES/helix" "$HOME/.config/helix"

symlinkDialogue "$DOTFILES/kitty" "$HOME/.config/kitty"

[[ -z "$CLONEDIR" ]] && export CLONEDIR=$HOME/gitclone/clones && mkdir -p $CLONEDIR

if [[ -n "$(command -v xbps-install)" ]]; then

  sudo xbps-install -Syu

  sudo xbps-install -y git zsh acl-progs rsync zsh zsh-doc tmux kitty helix git git-filter-repo github-cli go shfmt flac direnv ripgrep jq clang clang-analyzer skim clang-tools-extra lldb shellcheck || exit 1
  gochain

  export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
  mkdir -p "$ZSH_PLUGINS"
  for name in zsh-{autosuggestions,syntax-highlighting}; do
    [ ! -e "$DOTFILES/$name" ] && git clone --depth=1 "https://github.com/zsh-users/$name" "$ZSH_PLUGINS/$name" && source "$ZSH_PLUGINS/$name/$name.zsh"
  done
  symlinkDialogue "$ZSH_PLUGINS" "/usr/share/zsh/plugins"

  export TMUX_PLUGINS="$HOME/.tmux/plugins"
  mkdir -p "$TMUX_PLUGINS"
  [ ! -e "$TMUX_PLUGINS" ] && git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$TMUX_PLUGINS/tpm"

	gh auth login

  

  sudo xbps-install -y wget htop rlwrap tree glow typst tinymist zathura{,-pdf-mupdf} pandoc psmisc lf coreutils mpv mpv-mpris playerctl nicotine+ lua-language-server StyLua taplo build-essential bat gcc llvm && cd $HOME 

  symlinkDialogue {/usr/lib/mpv-mpris,~/.config/mpv/scripts}/mpris.so

  type -p curl >/dev/null || (sudo xbps-install -y curl)

  sudo xbps-install -y python3{,-{sqlparse,wheel,numpy,Pillow,PyAudio,attrs,audioread,binaryornot,bitarray,boolean.py,click,dill,google-{auth{-{httplib2,oauthlib},},api-{core,python-client}},httpx,requests,language-server,path,pandas,pathtools,pip,pipenv,pipx,platformdirs,re-assert,send2trash,scruffy,tabulate,virtualenv,argcomplete,click,jedi,parsing,parso,userpath,yaml}}
  
	[[ -z "$(command -v npm)" ]] && sudo xbps-install -y nodejs && sudo npm i -g {bash,awk,yaml}-language-server deno || { echo "couldn't install node and npm isn't available" && exit 1; }

  cd "$DOTFILES"

	# cd ~/.config && git clone --depth=1 https://github.com/kendfss/cheat
	# [[ ! -x "$(command -v cheat)" ]] && clone cheat/cheat && go install ./...

	[[ ! -x "$(command -v rustup)" ]] && sudo xbps-install -y rustup rust-analyzer mdBook

	source "$HOME/.cargo/env"

	[[ ! -x "$(command -v tree-sitter-cli)" ]] && sudo xbps-install -y tree-sitter

else
  echo "xbps-install is not available. Make sure you have the package manager for Void Linux installed." && return 1
fi

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

