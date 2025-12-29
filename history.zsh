#!/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Options.html
CACHEDIR="$DOTFILES/cache"                # for storing files like history and zcompdump 
[ ! -e "$CACHEDIR" ] && mkdir "$CACHEDIR"
history() {
  local output="$(fc -flt '' | sk -m -e --tiebreak index --tac)"
  local code=$?
  echo "$output" | while read line; do
    echo "${${(s: :)line}[2,-1]}"
  done
  return $code
}

HISTFILE="$CACHEDIR/history"                  # Keep our home directory neat by keeping the histfile somewhere else
SAVEHIST=10000                              # Big history
HISTSIZE=10000                              # Big history



