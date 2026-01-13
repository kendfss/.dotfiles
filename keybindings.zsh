[ $0 = "bash" ] && function zle() {
	true
} && alias bindkey=zle
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

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[3~" delete-char
bindkey '^[[3;3~' kill-word

[[ $0 = *"zsh" ]] && autoload -U edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line


