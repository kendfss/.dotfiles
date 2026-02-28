[ -z "${_comps+x}" ] && {
	autoload -U compinit
	compinit
}
zstyle ':completion:*' menu select

[ -x "$(command -v glow)" ] && source <(glow completion zsh)
[ -x "$(command -v gh)" ] && source <(gh completion -s zsh)
[ -x "$(command -v fzf)" ] && source <(fzf --zsh)
[ -x "$(command -v sk)" ] && source <(sk --shell zsh)
# [ -x "$(command -v bat)" ] && source <(bat --completion zsh)
