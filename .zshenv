export HARDWARECLOCK=localtime
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
export CONFIG=$HOME/.config
export VIRTUAL_ENV=$HOME/.venv
source $VIRTUAL_ENV/bin/activate
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.cache/dart-sdk/bin:$HOME/.cache/vscode/bin:$DOTFILES/scripts"
[[ ! -d $ZDOTDIR ]] && ln -fs $DOTFILES $ZDOTDIR

dirof_() {
  for name in "$@"; do
    pth=$(dirname `command -v "$name"`)
    echo "$pth"
  done
}

# export HELIX_RUNTIME=$CLONES/helix-editor/helix/runtime

# export NVIM=$HOME/.config/nvim
export CMAKE_ROOT=/usr/local/share/cmake-3.24
export IPDATAKEY=22c8e4ddd882816537eb93039043f10c552da195d7f4625928cf51bb

# export VIMRUNTIME=/usr/share/vim/vim81
export SUBLIME_CONFIG=$HOME/.config/sublime-text
export RUST_BACKTRACE=1
# export GOEXPERIMENT=unified

PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
[[ -x "$(command -v manpath)" ]] && PATH="$PATH:$(manpath -q)"
# if [[ $(uname) = Linux ]]; then
#     # PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
#     # export PKG_CONFIG_LIBDIR=/usr/lib
# fi

if [[ $(uname) = Darwin ]]; then
    PATH="$PATH:/Library/TeX/texbin:/Library/Apple/usr/bin"
    PATH="$PATH:/Library/Frameworks/Python.framework/Versions/3.10/bin"
fi

if [[ -x $(command -v node) ]]; then
    PATH="$PATH:$(dirof_ node)"
    PATH="$PATH:$(dirof_ npm)"
fi

# if [[ -d $GOPATH ]]; then
if [[ -d /usr/local/go ]]; then
    # PATH="$PATH:$(go env GOROOT)"
    # PATH="$PATH:$(go env GOPATH)"
    PATH="$PATH:/usr/local/go/bin"
fi


PATH="$PATH:$HOME/programs/scripts:$HOME/go/bin"
export PATH

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

export ZDOTDIR=$HOME/.zsh
export PROFILE=$ZDOTDIR/.zprofile
export RC=$ZDOTDIR/.zshrc
export ENV=$ZDOTDIR/.zshenv
[[ -d $HOME/.cargo ]] && . "$HOME/.cargo/env"

export UNSPLASH_ID="680402"
export UNSPLASH_ACCESS="vmApm7_xcObRGvWsE5dig7r-vcjEaTnOq4q8eHzpDzA"
export UNSPLASH_SECRET="Lzda_dUBd7aNZC9Dl2HPPSs6dGypNT47IwSQrrg2gqY"

export YOUTUBE_DATA_KEY="AIzaSyBi80e78ZssZs3YohJcTwLMBU7YenAoITg"


