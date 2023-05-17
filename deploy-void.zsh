export SRC=/media/$USER/OLLA
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh

[[ -L $ZDOTDIR ]] && rm $ZDOTDIR
[[ -d $ZDOTDIR ]] && rm -rf $ZDOTDIR

[[ -z $SRC ]] && echo "\$SRC is undefined" && exit 1
[[ -z $ZDOTDIR ]] && echo "\$ZDOTDIR is undefined" && exit 1
[[ -z $DOTFILES ]] && echo "\$DOTFILES is undefined" && exit 1

[[ ! -d $DOTFILES ]] && cp -r $SRC/.dotfiles "$(dirname $DOTFILES)"
ln -fs $DOTFILES $ZDOTDIR

# cp -r $SRC/.zsh $HOME
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
  sudo xbps-install -Syu
  sudo xbps-install -y tree pandoc

  type -p curl >/dev/null || (sudo xbps-install -Syu && sudo xbps-install -y curl)

  sudo xbps-install -y zsh zsh-doc wget htop tmux zsh-syntax-highlighting zsh-autosuggestions
  chsh -s `command -v zsh`
  _rm $ZDOTDIR/fast-syntax-highlighting && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZDOTDIR/zsh-syntax-highlighting 
  _rm $ZDOTDIR/zsh-autosuggestions && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions  $ZDOTDIR/zsh-autosuggestions 
  _rm $HOME/.tmux/plugins && git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  sudo xbps-install -y coreutils build-essential gcc bat git tmux
  sudo xbps-install -y make build-essential libssl-devel zlib-devel libbz2-devel readline-devel sqlite-devel wget curl llvm git ncurses-devel xz-utils tk-devel libxml2-devel libxmlsec1-devel libffi-devel xz

	[[ ! -d $HOME/.pyenv ]] && curl https://pyenv.run | bash 
	pyenv install 3.11-dev > /dev/stdout
	eval "$(pyenv init -)"
	pyenv global 3.11-dev && pip install "python-lsp-server[all]"

	[[ ! -x $(command -v bat) ]] && sudo ln -s $(command -v batcat) /usr/local/bin/bat &> /dev/null
	[[ ! -x $(command -v node) ]] && take $CLONEDIR/nodejs && git clone --depth=1 https://github.com/nodejs/node && cd node && ./configure && make -j4 && sudo make install && make test-only && make doc && ./node -e "console.log('Hello from Node.js ' + process.version)"
	[[ ! -x $(command -v typescript-language-server) ]] && sudo $(command -v npm) i -g typescript-language-server
	[[ ! -x $(command -v bash-language-server) ]] && sudo $(command -v npm) i -g bash-language-server

	export PATH="$PATH:/usr/local/go/bin"
	gov=go1.20.4.linux-amd64
	wget -O $gov.tar.gz  https://go.dev/dl/$gov.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf $gov.tar.gz && go version
	source $ZDOTDIR/functions.zsh
	go install github.com/mgechev/revive@latest
	go install github.com/cli/cli@latest
	gh auth login
	clone cheat/cheat && go install ./...

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

	source $HOME/.cargo/env

	cargo install tree-sitter-cli

	# The next option is to download the .deb file of Google Chrome:
	# please fetch https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	# Once downloaded, you can install the deb file in the terminal with xbps-install command like this:
	# sudo xbps-install -y ./google-chrome-stable_current_amd64.deb

else
  echo "xbps-install is not available. Make sure you have the package manager for Void Linux installed." && return 1
fi
