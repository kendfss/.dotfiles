export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
[[ ! -d $ZDOTDIR ]] && ln -fs $DOTFILES $ZDOTDIR

dirof_() {
  for name in "$@"; do
    pth=$(dirname `command -v "$name"`)
    echo "$pth"
  done
}

# export GOPROXY=mod
# export HELIX_RUNTIME=$ZDOTDIR/helix/runtime
# export NVIM=$HOME/.config/nvim
export CMAKE_ROOT=/usr/local/share/cmake-3.24
export IPDATAKEY=22c8e4ddd882816537eb93039043f10c552da195d7f4625928cf51bb

# # export PYTHONHOME=/home/kendfss/gitclone/clones/python/cpython
# # set PYTHONHOME
# # set PYTHONPATH
# export PYENV_ROOT="$HOME/.pyenv"
# if [[ -d $PYENV_ROOT ]]; then
#   export PATH="$PATH:$PYENV_ROOT/bin"
#   eval "$(pyenv init -)"
#   pyenv shell 3.11-dev
# fi
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
`eval "$(pyenv init -)"`
pyenv global 3.11-dev

# export VIMRUNTIME=/usr/share/vim/vim81
export SUBLIME_CONFIG=$HOME/.config/sublime-text
export RUST_BACKTRACE=1
export GOEXPERIMENT=unified

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

export NDK_PATH="~/Android/Sdk/ndk/24.0.8215888"

PATH="$PATH:$HOME/programs/scripts:$HOME/go/bin"
export PATH

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

export ZDOTDIR=$HOME/.zsh
export PROFILE=$ZDOTDIR/.zprofile
export RC=$ZDOTDIR/.zshrc
export ENV=$ZDOTDIR/.zshenv
[[ -d $HOME/.cargo ]] && . "$HOME/.cargo/env"

