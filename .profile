export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
[[ ! -d $ZDOTDIR ]] && ln -fs $DOTFILES $ZDOTDIR

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


if [[ -f $(command -v go) ]]; then
    export PATH="$PATH:$(go env GOROOT):$(go env GOPATH)"
fi

# PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$(manpath)"
PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
#PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
export PATH
export DOTDIR=$HOME/.zsh
export ZDOTDIR=$HOME/.zsh
export PROFILE=$ZDOTDIR/.zprofile
export RC=$ZDOTDIR/.zshrc
export ENV=$ZDOTDIR/.zshenv

# [[ -d $HOME/.cargo ]] && . "$HOME/.cargo/env"
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# [[ -x $(command -v gcc) ]] && export CC=gcc

export PATH="$HOME/.elan/bin:$PATH"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
