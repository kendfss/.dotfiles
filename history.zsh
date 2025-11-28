#!/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Options.html
CACHEDIR="$DOTFILES/cache"                # for storing files like history and zcompdump 
[ ! -e "$CACHEDIR" ] && mkdir "$CACHEDIR"
history() { fc -fl 1 | sk -me; }
HISTFILE="$CACHEDIR/history"                  # Keep our home directory neat by keeping the histfile somewhere else
SAVEHIST=10000                              # Big history
HISTSIZE=10000                              # Big history



