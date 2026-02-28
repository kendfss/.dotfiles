#!/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Options.html
export CACHEDIR="$DOTFILES/cache"   # for storing files like history and zcompdump
export HISTFILE="$CACHEDIR/history" # Keep our home directory neat by keeping the histfile somewhere else

[ ! -e "$CACHEDIR" ] && mkdir "$CACHEDIR"
touch "$HISTFILE"

SAVEHIST=10000 # Big history
HISTSIZE=10000 # Big history
