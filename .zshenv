export HARDWARECLOCK=localtime
export DOTFILES=$HOME/.dotfiles
export CONFIG=$HOME/.config
if [ -x "$(command -v clang)" ]; then
  export CC="$(which clang)"
fi
VIRTUAL_ENV=$HOME/.venv
[ -d $VIRTUAL_ENV ] && export VIRTUAL_ENV && source $VIRTUAL_ENV/bin/activate
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.cache/dart-sdk/bin:$HOME/.cache/vscode/bin:$DOTFILES/scripts"
export DICTAPI="https://api.dictionaryapi.dev/api/v2/entries/en_GB"

dirof_() {
  for name in "$@"; do
    pth=$(dirname `command -v "$name"`)
    echo "$pth"
  done
}

export RUST_BACKTRACE=1

export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/bin:$TERMUX__ROOTFS_DIR/bin:$TERMUX__ROOTFS_DIR/usr/sbin:$TERMUX__ROOTFS_DIR/sbin:$TERMUX__ROOTFS_DIR/usr/local/bin"

if [[ $(uname) = Darwin ]]; then
    export PATH="$PATH:/Library/TeX/texbin:/Library/Apple/usr/bin"
    export PATH="$PATH:/Library/Frameworks/Python.framework/Versions/3.10/bin"
fi

if [[ -x $(command -v node) ]]; then
    export PATH="$PATH:$(dirof_ node)"
    export PATH="$PATH:$(dirof_ npm)"
fi

[ -d /usr/local/go/bin ] && export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/go/bin"


[ -x "$(command -v go)" ] && export PATH="$PATH:$HOME/go/bin"


export PROFILE=$DOTFILES/.zprofile
export RC=$DOTFILES/.zshrc
export ENV=$DOTFILES/.zshenv
[ -d "$HOME/.cargo" ] && . "$HOME/.cargo/env"

export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/kendfss/.local/share/flatpak/exports/share"
export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"
