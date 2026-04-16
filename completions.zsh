[ -z "${_comps+x}" ] && {
	autoload -U compinit
	compinit
}
zstyle ':completion:*' menu select

[ -x "$(command -v glow)" ] && source <(glow completion zsh)
[ -x "$(command -v gh)" ] && source <(gh completion -s zsh)
[ -x "$(command -v fzf)" ] && source <(fzf --zsh)
[ -x "$(command -v sk)" ] && source <(sk --shell zsh)
[ -x "$(command -v wezterm)" ] && source <(wezterm shell-completion --shell zsh)
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
# [ -x "$(command -v bat)" ] && eval "$(bat --completion zsh)"
# [ -x "$(command -v bat)" ] && source <(bat --completion zsh)
