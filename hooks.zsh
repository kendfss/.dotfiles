set-title() {
	# set the title of a terminal's window
	case "${BY:-$TERM}" in
		screen*) print -Pn "\033k$*\033\\" ;;
		tmux*) print -n "\ePtmux;\e\e]0;$*\a\e\\" ;;
		xterm* | rxvt* | *wezterm* | *kitty*) print -Pn "\033]0;$*\007" ;;
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

precmd() {
	set-title "${1:-${BY:-$TERM}($(pexp '%(3C.%-1d:%1~.%1~)'))}"
}

expand-vars() {
	# expand strings containing environment variables without using parameter expansion which breaks shfmt
	printf '%s ' $@ | sed 's: :\n:g' | while read -r term; do
		printf '%s\n' "$term" | sed 's:/:\n:g' | while read -r part; do
			case "$part" in
				'$'*) eval "echo \"$part\"" ;;
				*) printf '%s\n' "$part" ;;
			esac
		done | tr '\n' '/' | sed 's:/$::'
		echo
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

preexec() {
	local cmd="${1%% *}"
	local rgs="${1#* }"
	local exp
	local dir
	[ "$PWD" = "$HOME" ] || dir="$(pexp '%(3C.%-1d:%1~.%1~)')"
	cmd-words $rgs | while read -r term; do
		words+=("$term")
	done
	case "$cmd" in
		jellyfin | gallery-dl | yt-dlp) exp="$cmd" ;;
		sudo | exec | preexec | precmd | watch | time | timeout) exp="${cmd}(${words[1]})" ;;
		hx) exp="$cmd($(cmd-words $rgs | sed 's/\s+/:/g'))" ;;
		*) exp="${BY:-$TERM}($cmd)" ;;
	esac
	title="$exp${dir:+ :: $dir}"
	set-title "$title"
}
