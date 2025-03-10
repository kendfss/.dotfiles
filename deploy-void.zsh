#!/usr/bin/env -S zsh
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh

[[ -L $ZDOTDIR ]] && rm $ZDOTDIR
[[ -d $ZDOTDIR ]] && rm -rf $ZDOTDIR

[[ -z $ZDOTDIR ]] && echo "\$ZDOTDIR is undefined" && exit 1
[[ -z $DOTFILES ]] && echo "\$DOTFILES is undefined" && exit 1

ln -fs $DOTFILES $ZDOTDIR

cd $ZDOTDIR

_link() {
  for arg in "$@"; do
    [[ -f $ZDOTDIR/$arg ]] && ln -f "$ZDOTDIR/$arg" "$HOME/$arg"
    [[ -d $ZDOTDIR/$arg ]] && ln -fs "$ZDOTDIR/$arg" "$HOME/$arg"
  done
}

_rm() {
  for arg in "$@"; do 
    [[ -d "$arg" ]] && rm -rf "$arg"
    [[ -L "$arg" ]] && rm "$arg"
  done
}

[[ -z $CLONEDIR ]] && export CLONEDIR=$HOME/gitclone/clones && mkdir -p $CLONEDIR

for item in $ZDOTDIR/.*; do 
  ([[ -f $item ]] && (name=$(basename "$item"); [[ -f "$HOME/$name" ]] && rm "$HOME/$name"; ln -f "$item" "$HOME/$name")) || continue;
done

if [[ -n $(command -v xbps-install) ]]; then

	export PATH="$PATH:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin"
	source $ZDOTDIR/functions.zsh

  sudo xbps-install -Syu
  sudo xbps-install -y tree pass git pandoc psmisc lf coreutils && cd $HOME 
	gh auth login
  sudo git clone https://github.com/kendfss/.password-store

  type -p curl >/dev/null || (sudo xbps-install -y curl)

  sudo xbps-install -y zsh zsh-doc wget htop tmux zsh-syntax-highlighting zsh-autosuggestions kitty
  _rm $ZDOTDIR/fast-syntax-highlighting && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZDOTDIR/zsh-syntax-highlighting 
  _rm $ZDOTDIR/zsh-autosuggestions && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions  $ZDOTDIR/zsh-autosuggestions 
  _rm $HOME/.tmux/plugins && git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  sudo xbps-install -y coreutils build-essential gcc bat git tmux helix llvm

  sudo xbps-install -y python3{,-{wheel,numpy,Pillow,PyAudio,attrs,audioread,binaryornot,bitarray,boolean.py,click,dill,google-{auth{-{httplib2,oauthlib},},api-{core,python-client}},httpx,requests,language-server,path,pandas,pathtools,pip,pipenv,pipx,platformdirs,re-assert,send2trash,scruffy,tabulate,virtualenv,argcomplete,click,jedi,parsing,parso,userpath,yaml}}
  
	# [[ -z $(command -v node) ]] && take $CLONEDIR/nodejs && git clone --depth=1 https://github.com/nodejs/node && cd node && ./configure && make -j4 && sudo make install && make test-only && make doc && ./node -e "console.log('Hello from Node.js ' + process.version)"
	[[ -z $(command -v npm) ]] && sudo xbps-install -y nodejs
	[[ -z $(command -v typescript-language-server) ]] && sudo $(command -v npm) i -g typescript-language-server
	[[ -z $(command -v bash-language-server) ]] && sudo $(command -v npm) i -g bash-language-server

  cd $DOTFILES

	cd ~/.config && git clone https://github.com/kendfss/cheat
	[[ ! -x $(command -v cheat) ]] && clone cheat/cheat && go install ./...

	# [[ ! -x $(command -v rustup) ]] && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	[[ ! -x $(command -v rustup) ]] && sudo xbps-install -y rustup rust-analyzer mdBook

	source $HOME/.cargo/env

	[[ ! -x $(command -v tree-sitter-cli) ]] && sudo xbps-install -y tree-sitter

else
  echo "xbps-install is not available. Make sure you have the package manager for Void Linux installed." && return 1
fi
