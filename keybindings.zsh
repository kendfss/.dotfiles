# compatibility (silent failure) with bash
[ $0 = "bash" ] && {
	function zle() {
		true
	}
	alias bindkey=bind
}

command -v setxkbmap &>/dev/null && setxkbmap -option caps:none

expand-or-complete-with-dots() {
	# Show dots while waiting for tab-completion
	# toggle line-wrapping off and back on again
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
	print -Pn "%{%F{red}......%f%}"
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

	zle expand-or-complete
	zle redisplay
}

zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[3~" delete-char
bindkey '^[[3;3~' kill-word
[ "$TERM" = 'xterm-kitty' -o "$TERM" = 'wezterm' ] && {
	bindkey "^[[F" end-of-line
	bindkey "^[[H" beginning-of-line
}

case "$TERM" in
	xterm)
		bindkey "ÿ" backward-kill-word
		bindkey "M-^?" backward-kill-word
		;&
	xterm* | *kitty | *wezterm* | *ghostty*)
		bindkey "^[^?" backward-kill-word
		bindkey "^[[F" end-of-line
		bindkey "^[[H" beginning-of-line
		;;
	dvtm*)
		bindkey "^[[7~" beginning-of-line
		bindkey "^[[8~" end-of-line
		bindkey "^[1;3D" backward-word
		bindkey "[1;3C" forward-word
		bindkey "^[^G" backward-kill-word
		;;
esac

bindkey -r '^H' # disable backward-delete-char
[ -x $(command -v fzf 2>/dev/null) ] && {
	bindkey -r '^R'
	bindkey '^H' fzf-history-widget
}

[[ $0 == *"zsh" ]] && autoload -U edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
