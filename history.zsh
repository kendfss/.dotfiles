#!/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Options.html
export CACHEDIR="$DOTFILES/cache"                # for storing files like history and zcompdump 
export HISTFILE="$CACHEDIR/history"                  # Keep our home directory neat by keeping the histfile somewhere else

[ ! -e "$CACHEDIR" ] && mkdir "$CACHEDIR"
history() {
  local output="$(cat "$HISTFILE" | sed -E 's/^.+;//g' | sk -m -e --tiebreak index --tac)"
  local code=$?
  tmux send-keys "$(echo "$output" | while IFS= read -r line; do
    echo "${${(s: :)line}[2,-1]}"
  done | perl -pe 's/\n/; /' | sed 's/; $//')"
  return $code
}

SAVEHIST=10000                              # Big history
HISTSIZE=10000                              # Big history



