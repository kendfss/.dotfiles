export DOTFILES=$HOME/.dotfiles

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

PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/bin:$TERMUX__ROOTFS_DIR/bin:$TERMUX__ROOTFS_DIR/usr/sbin:$TERMUX__ROOTFS_DIR/sbin:$TERMUX__ROOTFS_DIR/usr/local/bin"
export DOTFILES=$HOME/.dotfiles
export PROFILE=$DOTFILES/.zprofile
export RC=$DOTFILES/.zshrc
export ENV=$DOTFILES/.zshenv

[ -d "$HOME/.cargo" ] && . "$HOME/.cargo/env"
[ -x "$(command -v clang)" ] && export CC=clang

PATH="$HOME/.elan/bin:$PATH"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

