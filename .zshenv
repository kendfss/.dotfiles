# Set important shell variables
  export EDITOR=hx                            # Set default editor
  export PAGER=less                           # Set default pager
  export LESS="-R"                            # Set the default options for less 
  export LANG="en_GB.UTF-8"                   # I'm not sure who looks at this, but I know it's good to set in general
  export GOFMT=gofumpt
  export CLONEDIR=$HOME/gitclone/clones
  export CLONES=$HOME/gitclone/clones
  export REPO_HOST=https://github.com
  export DEVELOPER=$USER
  export GOPATH="$HOME/go"
  export WORKSPACE="$HOME/workspace"
  export FLPROJECTS="$HOME/Documents/Image-Line/FL Studio/Projects"
  export VIDEOS=$HOME/$([[ $(uname) -eq Linux ]] && echo Videos || echo Movies)
  export MUSIC=$HOME/Music
  export NOTES=$HOME/self.notes
  export POSTS=$NOTES/posts
  export HARDWARECLOCK=localtime
  export DOTFILES=$HOME/.dotfiles
  export CONFIG=$HOME/.config
  if [ -x "$(command -v clang)" ]; then
    export CC="$(which clang)"
  fi

# Python/UV related
  VIRTUAL_ENV=$HOME/.venv
  [ -d $VIRTUAL_ENV ] && export VIRTUAL_ENV && source $VIRTUAL_ENV/bin/activate

export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.cache/dart-sdk/bin:$HOME/.cache/vscode/bin:$DOTFILES/scripts"
export DICTAPI="https://api.dictionaryapi.dev/api/v2/entries/en_GB"

dirof_() {
  for name in "$@"; do
    pth=$(dirname "$(command -v "$name")")
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

if [[ $(uname) -eq Linux ]]; then
  [[ -d "$HOME/Android/Sdk" ]] && ANDROID_STUDIO_HOME=$HOME/Android/Sdk/android-studio
  [[ -d "$ANDROID_STUDIO_HOME" ]] && alias anstu="$ANDROID_STUDIO_HOME/bin/studio.sh"
  [[ -d "$HOME/Android" ]] && export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  [[ -d "$ANDROID_SDK_ROOT" ]] && PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"
  export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/20.1.5948944"
fi

[ -d "$TERMUX__ROOTFS_DIR" ] && export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/bin:$TERMUX__ROOTFS_DIR/usr/bin"
[ -d "$HOME/.elan" ] && export PATH="$PATH:$HOME/.elan/bin"

export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"
PATH="$PATH:$HOME/dartsdk/dart-sdk/bin:$DOTFILES/scripts"
if [ -d "$TERMUX__PREFIX" ]; then
    export PLAYPATH="$HOME/storage/music"
else
    export PLAYPATH="$HOME/Music:$HOME/.local/share/nicotine/downloads:/music:/mnt/Elements/drive:/mnt/Elements/music"
fi
export MUSIC_FORMATS="mp3|m4a|wav|flac|ogg|aif|aiff|opus"

export WORDCHARS=${WORDCHARS//[&+;\-_\/=.]}



export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"
