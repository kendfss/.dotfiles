local local_dir="$HOME/.zfunc"
mkdir -p "$local_dir" || exit 1
fpath+=("$local_dir")

[ -z "${_comps+x}" ] && {
	autoload -U compinit
	compinit
	autoload -U bashcompinit
	bashcompinit
}
zstyle ':completion:*' menu select

exe() {
	[ -x "$(command -v "$1")" ] || return 1
}

# exe idris2 && eval "$(idris2 --bash-completion-script)"
cnp="/usr/share/zsh/plugins/xbps-command-not-found/xbps-command-not-found.zsh" && [ -e "$cnf" ] && source "$cnf"
exe glow && source <(glow completion zsh)
exe gh && source <(gh completion -s zsh)
exe fzf && source <(fzf --zsh)
exe sk && source <(sk --shell zsh)
exe wezterm && source <(wezterm shell-completion --shell zsh)
exe zoxide && eval "$(zoxide init --cmd zx zsh)" && alias z=zoxide && alias cd=zx
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
