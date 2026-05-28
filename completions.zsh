local local_dir="$HOME/.zfunc"
mkdir -p "$local_dir" || exit 1
fpath+=("$local_dir")

[ -z "${_comps+x}" ] && {
	autoload -U compinit
	compinit
}
zstyle ':completion:*' menu select

exe() {
	[ -x "$(command -v "$1")" ] || return 1
}

exe glow && source <(glow completion zsh)
exe gh && source <(gh completion -s zsh)
exe fzf && source <(fzf --zsh)
exe sk && source <(sk --shell zsh)
exe wezterm && source <(wezterm shell-completion --shell zsh)
exe zoxide && eval "$(zoxide init zsh)"
exe cheat && eval "$(cheat --completion zsh)"
exe tailscale && {
	local pth="$local_dir/_tailscale"
	[ -e "$pth" ] && rm "$pth"
	tailscale completion zsh >"$pth"
}
exe bat && {
	local pth="$local_dir/_bat"
	[ -e "$pth" ] && rm "$pth"
	bat --completion zsh >"$pth"
}

unfunction exe
