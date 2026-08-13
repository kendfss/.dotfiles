preexec() {
	set-window-title "$(derive-window-title "$@")"
}

precmd() {
	set-window-title "${1:-${BY:-$TERM}($(pexp '%(3C.%-1d:%1~.%1~)'))}"
}

set-window-title() {
	# set the title of a terminal's window
	case "${BY:-$TERM}" in
		screen*) print -Pn "\033k$*\033\\" ;;
		tmux*) print -n "\ePtmux;\e\e]0;$*\a\e\\" ;;
		xterm* | rxvt* | *ghostty* | *wezterm* | *kitty*) print -Pn "\033]0;$*\007" ;;
		dvtm*) echo -ne "\033]0;$*\007" ;;
		*) print -Pn "\033k$*\033\\" ;;
	esac
}

set-tab-title() {
	while true; do echo todo; done
	# set the title of a terminal's window
	case "${BY:-$TERM}" in
		screen*) print -Pn "\033k$*\033\\" ;;
		tmux*) print -n "\ePtmux;\e\e]0;$*\a\e\\" ;;
		xterm* | rxvt* | *ghostty* | *wezterm* | *kitty*) print -Pn "\033]0;$*\007" ;;
		dvtm*) echo -ne "\033]0;$*\007" ;;
		*) print -Pn "\033k$*\033\\" ;;
	esac
}

prompt-prefix() {
	local dst=''
	local origin="$(pwd)"
	if [ -d "$1" ]; then
		dst="$1"
	elif [ -e "$1" ]; then
		dst="$(dirname "$1")"
	else
		pexp '%(3C.%-1d:%1~.%1~)'
		return
	fi
	cd "$dst"
	pexp '%(3C.%-1d:%1~.%1~)'
	cd "$origin"
}

expand-vars() {
	# expand strings containing environment variables without using parameter expansion which breaks shfmt
	printf '%s ' $@ | sed 's: :\n:g' | while read -r term; do
		case "$term" in
			'|' | '&' | '&&') ;;
			*)
				printf '%s\n' "$term" | sed 's:/:\n:g' | while read -r part; do
					case "$part" in
						'$('*) printf '%s\n' "$(printf '%s' "$part" | sed 's:^\$\(::;s:\)$::')" ;;
						'${'*) printf '%s\n' "$(printf '%s' "$part" | sed 's:^\$\{::;s/(:.+|\})$//')" ;;
						'$'*) eval "echo \"$part\"" ;;
						*) printf '%s\n' "$part" ;;
					esac
				done | tr '\n' '/' | sed 's:/$::'
				echo
				;;
		esac
	done | tr '\n' ' ' | sed 's: $::'
	echo
}

cmd-words() {
	# extract words and strings, but not flags, from the first command in a pipeline
	local words=()
	expand-vars "$@" | sed 's:\s+:\n:g' | while read -r word; do
		case "$word" in
			'|') break ;;
			-* | 0* | 1* | 2* | 3* | 4* | 5* | 6* | 7* | 8* | 9*) ;; # heinously inelegant but doesn't break shfmt
			*)
				if [ -e "$word" ]; then
					words+=("$(basename "$word")")
				else
					words+=("$word")
				fi
				;;
		esac
	done
	echo "${words[@]}"
}

derive-window-title() {
	local cmd="${1%% *}"
	local rgs="${1#* }"
	local exp="${BY:-$TERM}($cmd)"
	local dir
	local words
	[ "$PWD" = "$HOME" ] || dir="$(pexp '%(3C.%-1d:%1~.%1~)')"
	cmd-words $rgs | while read -r term; do
		words+=("$term")
	done
	case "$cmd" in
		'LANG=C.UTF-8') exp="$rgs" ;;
		tmux | herdr | jellyfin | gallery-dl | yt-dlp) exp="$cmd" ;;
		sudo | exec | preexec | precmd | time | timeout) exp="${cmd}(${words[1]})" ;;
		watch) exp="${cmd}(${words[2]})" ;;
		hx | mpv) exp="$cmd($(cmd-words $rgs | sed 's/\s+/:/g'))" ;;
		yes) exp="$(printf '%s\n' "$(printf '%s' "$part" | sed 's:^.+\|\s*::')")" ;;
		*) ;;
	esac
	local title="$exp${dir:+ :: $dir}"
	echo "$title"
}
