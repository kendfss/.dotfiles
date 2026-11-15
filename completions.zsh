case "$SHELL" in
	*zsh)
		[ -z "${_comps+x}" ] && {
			autoload -U compinit
			compinit
			zstyle ':completion:*' menu select
		}
		;;
	*bash)
		[ -z "${_comps+x}" ] && {
			autoload -U bashcompinit
			bashcompinit
		}
		;;
esac

cnf="/usr/share/zsh/plugins/xbps-command-not-found/xbps-command-not-found.zsh"
[ -e "$cnf" ] && source "$cnf"

! exe android || source <(android completion zsh)
! exe rustup || source <(rustup completions zsh)
! exe cheat || eval "$(cheat --completion zsh)"
! exe dlv || source <(dlv completion zsh)
! exe fzf || source <(fzf --zsh)
! exe gh || source <(gh completion -s zsh)
! exe glow || source <(glow completion zsh)
! exe idris2 || eval "$(idris2 --bash-completion-script)"
! exe sk || source <(sk --shell zsh)
! exe wezterm || source <(wezterm shell-completion --shell zsh)

zfunc_add tailscale completion zsh
zfunc_add bat --completion zsh
zfunc_add cb completions zsh
zfunc_add bw completion --shell zsh
zfunc_add jj util completion zsh
zfunc_add mdbook completions zsh

source_if "/home/kendfss/.local/share/zsh/site-functions/_soulseek-rs" # soulseek-rs completions
