# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html
autoload -Uz add-zsh-hook

# [ -x "$(command -v tmux 2>/dev/null)" ] && tmux() {
# 	(($#)) || exec command tmux
# 	[ "$1" = "@" ] || exec command tmux
# 	command tmux "$@"
# }

pcd() {
	cd "$(p)"
}

mkhx() {
	clone helix-editor/helix
	git pull
	cargo build --locked
	sudo mv target/release/hx /usr/local/bin
}

wpax() {
	# send network credentials to wpa_supplicant, or sdout, from NetworkManager
	local name ssid psk blob
	sudo rg -l ssid /etc/NetworkManager | fzf --preview "sudo rg '(ssid|psk)=' {}" | while read -r name; do
		blob="$(sudo cat "$name" | rg '(ssid|psk)=' | awk -F= '{print $2}')"
		ssid="$(head -1 <<<"$blob")"
		[ -z "$(sudo rg "$ssid" /etc/wpa_supplicant/wpa_supplicant.conf)" ] || continue
		psk="$(tail -1 <<<"$blob")"
		blob="$(wpa_passphrase "$ssid" "$psk")"
		if (($#)); then
			printf '%s\n' "$blob"
		else
			sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf <<<"$blob"
		fi
	done
}

safe() {
	local item
	while read -r item; do strings "$item" | sort -u | rg -qio "kendfss|kenneth.?sabalo|kenneth|sabalo|elisandro|santana|de.?faria" && echo "$item"; done
}

xy() {
	setopt localoptions pipefail
	xbps-query -L | awk '{print $2}' | xargs -d '\n' curl -L 2>/0 | pup 'a attr{href}' | egrep '\.xbps$' | sed -E 's:\-[0-9\._]+.+$::;' | sort -u | fzf --preview 'xbps-query -RS {}'
}

fzm() {
	fzf --preview-window='hidden' --bind='tab:toggle+hide-preview,btab:hide-preview+show-preview,up:up+hide-preview,down:down+hide-preview' "$@"
}

amdahl() {
	python -c 'import os; print(os.cpu_count())'
}

pluck() {
	local ctr=${1:-0}
	while read -r line; do
		((ctr)) || {
			echo "$line"
			return
		}
		ctr=$((ctr - 1))
	done
}

command -v xlocate &>/dev/null && xl() {
	for arg in "$@"; do
		xlocate "/$arg" | grep -E "/$arg\$"
	done
}

tabulate() {
	awk '{ lines[NR]=$0; status[NR]=$1; name[NR]=$2; $1=$2=""; desc[NR]=substr($0,3)
          if (length(name[NR]) > max) max=length(name[NR]) }
        END { for (i=1;i<=NR;i++) printf "%s\t%-*s\t%s\n", status[i], max, name[i], desc[i] }
    ' | column -ts $'\t'
}

[ -x "$(command -v tmux 2>/dev/null)" ] && tmux() {
	(($#)) || exec command tmux
	[ "$1" = "@" ] || exec command tmux "$@"
	shift
	command tmux "$@"
}

[ -x "$(command -v herdr 2>/dev/null)" ] && herdr() {
	(($#)) || {
		[ -n "$(ps aux | grep '[h]erdr')" ] || exec command herdr --no-session
		exec command herdr
	}
	[ "$1" = "@" ] || exec command herdr "$@"
	shift
	command herdr "$@"
}

command -v namespacer &>/dev/null || namespacer() { echo "$@_2"; }

command -v mpv &>/dev/null && mpv() {
	preexec "mpv $*"
	command mpv "$@"
}

urand() {
	cat /dev/urandom | head -c $1 | xxd -p | awk '{print strtonum("0x" $1)}' | tr -d '\n' | xargs echo
}

subs() {
	for arg in "$@"; do
		local len=${#arg}
		for ((i = 1; i <= len; i++)); do
			echo "${arg[1,-$i]}"
		done
	done
}

swop() {
	tmp="$(mktemp)"
	cat "$1" | tee "$tmp" >/dev/null
	cat "$2" | tee "$1" >/dev/null
	cat "$tmp" | tee "$2" >/dev/null
	rm "$tmp"
}

sh() {
	# ENV='' PROFILE='' RC='' SHELL=sh PS1='$(pwd) >>> ' command sh "$@"
	ENV='' PS1='$(pwd) >>> ' command sh "$@"
}

gallery-dl() {
	local flags=()
	local args=()
	local once=false
	local browser="$(xdg-settings get default-web-browser | awk -F. '{print $1}')"
	while (($#)); do
		case "$1" in
			http* | https*) args+=("$1") ;;
			--once) once=true ;;
			--browser)
				browser="$2"
				shift
				;;
			-d | -D)
				flags+=("$1" "$2")
				shift
				;;
			-*) flags+=("$1") ;;
		esac
		shift
	done
	((${#args})) || {
		echo "$0: no args received" >&2
		return 1
	}
	# browser=${browser:+--cookies-from-browser $browser}
	[ -z "$browser" ] || browser=("--cookies-from-browser" $browser)
	while true; do
		local count=${#args}
		set -- $args
		local ctr=0
		local fails=()
		printf 'args:'
		printf "\t%s\n" "$*"
		while (($#)); do
			ctr=$((ctr + 1))
			printf "%d/%d: " "$ctr" "$count"
			printf "%s\n" "$1"
			if ! command gallery-dl "${browser[@]}" "${flags[@]}" "$1"; then
				fails+=("$1")
			fi
			shift
		done
		[ $once = true ] || { ((${#fails})) && args=("${fails[@]}") && continue; }
		break
	done
}

unr() {
	awk -v RS="" -v ORS="" '
  { 
    # Replace all internal newlines and consecutive whitespace with a single space
    gsub(/[ \t\r\n]+/, " ", $0); 
    
    # Print the paragraph. If it is not the first paragraph, prepend a blank line.
    print (NR == 1 ? "" : "\n\n") $0; 
  } 
  END { printf "\n" } # Add exactly one trailing newline for a valid POSIX file
'
}

chad() {
	# Perform an HTTP GET request on the current page URL with the `ask` query

	# The question should be specific, self-contained, and written in natural
	# language. The response will contain a direct answer to the question and relevant
	# excerpts and sources from the documentation.

	# Use this mechanism when the answer is not explicitly present in the current
	# page, you need clarification or additional context, or you want to retrieve
	# related documentation sections.

	curl -L "https://chadboyce.gitbook.io/notes/lf.md?ask=$(jq -sRr @uri <(printf '%s ' "$@"))"
}

smpl() {
	local flags=()
	local name=()
	while (($#)); do
		case "$1" in
			-*) flags+=("$1") ;;
			*) name+=("$1") ;;
		esac
		shift
	done
	command smpl "${flags[@]}" "$(
		{
			printf "%s" "${name[1]}"
			printf " %s" "${name[2,-1]}"
		} | to fopa | rev | awk '{print $1}' | rev
	)"
}

source_if() {
	while (($#)); do
		[ -e "$1" ] && source "$1"
		shift
	done
}

lfcd() {
	cd "$(command lf -print-last-dir "$@")"
}

poc() {
	[[ $# -eq 0 ]] && local args=(".") || local args=("$@")
	local arg
	for arg in $args; do
		pydoc $arg | bat -Pplpython --theme ansi
	done
}

recover() {
	local arg
	for arg in $@; do
		git checkout "$(git rev-list -1 HEAD -- '$arg')^" -- '$arg'
	done
}

# ext() {
# 	local arg
# 	for arg in "$@"; do
# 		[ ! -f "$arg" ] && continue
# 		{ local base="$(basename "$arg")" && local ext="${base##*.}"; } || return $?
# 		[ "$ext" = "$base" ] && continue
# 		echo "$ext"
# 	done
# }

# exts() {
# 	if [ "$1" = "-s" ]; then
# 		shift 1
# 		ext "$@" | sort -ui
# 	else
# 		ext "$@"
# 	fi
# }

take() {
	# Make a directory and cd into it
	local code=$?
	# [ -z "$mkdir" ] && echo "couldn't find mkdir" >&2 && return $code
	for arg in "$@"; do
		command mkdir -p $1 && cd $1
	done
}
alias mcd=take

urlencode() {
	# Urlencode <string>
	local LANG=C
	local LC_COLLATE=C
	local length="${#1}"
	for ((arg = 0; i < length; i++)); do
		local c="${1:arg:1}"
		case $c in
			[a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
			*) printf '%%%02X' "'$c" ;;
		esac
	done
}

bar() {
	local char="*"
	if [ -n "$2" ]; then
		char="$2"
	fi
	for arg in {1..$1}; do
		printf "%s" "$char"
	done
	print ""
}

10print() {
	local RANDOM=$(date +%s)
	declare -a chars
	local chars=(\\ /)
	chars=(\# " ")
	for arg in {1..$1}; do
		ind=$((RANDOM % 2))
		printf "%s" "${chars[$((ind + 1))]}"
	done
	echo ""
}

move() {
	local name=$(base)
	cd .. && mv "$name" "$1" && cd "$1"
}

surl() {
	for url in "$@"; do
		local ssh_url=$(echo "$url" | sed 's/https:\/\/\([^/]*\)\(.*\)\.\(.*\)/git@\1:\2.git/')
		echo "$ssh_url"
	done
}

clone() {
	# local lines="$(ENV="" command clone "$@")"
	local lines="$(command clone "$@")"
	local dir="$(echo "$lines" | tail -n1)"
	[ $(echo "$lines" | wc -l) -gt 1 ] && echo "$lines"
	[ -d "$dir" ] && cd "$dir"
}

padd() {
	printf "\n" >>~/.zprofile
	for arg in "$@"; do
		printf "%s\n" "$arg" >>~/.zprofile
	done
}

def() {
	local fname="$NOTES/definitions"
	case $# in
		0) $EDITOR "$fname" && return ;;
		1) case "$1" in
			-c | --cat) cat "$fname" ;;
			*) echo "$0: unsupported argument: $1" >&2 && return 1 ;;
		esac ;;
		*)
			local term="$1"
			shift 1
			[ -f "$fname" ] && former=$(cat "$fname") && rm "$fname"
			local extended=$(printf "%s\n\t%s\n%s" "$term" "$*" "$former")
			echo "$extended" >"$fname"
			;;
	esac
}

amend() {
	git add . && git commit --amend && git push -f origin
}

issues() {
	gh repo issue "$@"
}

base() {
	basename "$(pwd)"
}

iexists() {
	local match_found=1
	for pth in "$@"; do
		shopt -s nullglob nocaseglob
		local files=("$pth"*)
		if [[ ${#files[@]} -gt 0 ]]; then
			printf "%s\n" "${files[@]}"
			match_found=0
		fi
		shopt -u nullglob nocaseglob
	done
	return $match_found
}

hide() {
	for arg in "$@"; do
		mv "$arg" ".$arg"
	done
}

dots() {
	$EDITOR "$DOTFILES"
}

relocate() {
	local here=$(pwd)
	local name=$(base)
	local dest=$1/$name
	mkdir -p "$dest"
	mv "$here" "$1" && cd "$dest" || return 1
}

cds() {
	cd "$1" && $EDITOR .
}

co() {
	git checkout $*
}

rl() {
	for arg in "$@"; do
		readlink "$(command -v "$arg")"
	done
}

dirof() {
	for name in "$@"; do
		dirname "$(command -v "$name")"
	done
}

here() {
	dirname $(readlink -f $0)
}

titles() {
	local fname=~/self.notes/track_titles
	[[ -f $fname ]] && former=$(cat "$fname") && rm "$fname"
	local extended=$*"\n"$former
	echo "$extended" >"$fname"
}

keep() {
	local fname=$(pwd)/keeps.md
	[[ -f $fname ]] && former=$(cat "$fname") && rm "$fname"
	local extended=$*"\n"$former
	echo "$extended" >"$fname"
}

if [[ $(uname) -eq Linux ]]; then
	open() {
		xdg-open $* >/dev/null
	}
fi

fname() {
	for fullpath in "$@"; do
		local filename="${fullpath##*/}"   # Strip longest match of */ from start
		local base="${filename%.[^.]*}"    # Strip shortest match of . plus at least one non-dot char from end
		local ext="${filename:${#base}+1}" # Substring from len of base thru end
		if [[ -z $base && -n $ext ]]; then # If we have an extension and no base, it's really the base
			base=".$ext"
			ext=""
		fi
		echo "$base"
	done
}

fext() {
	filename="${fullpath##*/}" # Strip longest match of */ from start
	base="${filename%.[^.]*}"
	echo "${filename:${#base}+1}"
}

note() {
	local fname="$NOTES/notes"
	case $# in
		0) $EDITOR "$fname" ;;
		1) case "$1" in
			-c | --cat) cat "$fname" && return ;;
			def | define) shift && def "$@" && return ;;
			post) shift && post "$@" && return ;;
			*) ;;
		esac ;;
	esac
	[ -f "$fname" ] && former=$(cat "$fname") && rm "$fname"
	local extended=$*"\n"$former
	echo "$extended" >"$fname"
}

notes() {
	$EDITOR ~/self.notes/notes
}

cnotes() {
	cat ~/self.notes/notes | fzf --preview 'printf "%s\n" {}'
}

etch() {
	local fname="$HOME/self.notes/$*.md"
	local name=$(echo "$fname" | sed "s/ /_/g")
	[[ ! -f $fname ]] && printf "%s\n---\n" "$*" >"$fname"
	$EDITOR -n "$fname"
}

post() {
	local name=$*
	name=$(replace " " "_" "$name")
	local dname="$POSTS/$name"

	[[ -d $dname ]] && cd $dname && $EDITOR $dname && return
	take $dname
	local fname="$dname/$name.md"
	[[ ! -d $dname ]] && mkdir -p "$dname"
	$EDITOR "$dname"
	[[ -f $fname ]] && former=$(cat "$fname") && rm "$fname"
	local extended=$*"\n===\n"$former
	echo "$extended" >"$fname"
	$EDITOR "$fname"
}

posts() {
	$EDITOR ~/self.notes/notes
}

cposts() {
	cat ~/self.notes/notes | fzf
}

stars() {
	gh api user/starred --template '{{range .}}{{.full_name|color "yellow"}}{{"\n"}}{{end}}'
}

work() {
	local fname=~/self.notes/work.md
	[[ -f $fname ]] && former=$(cat "$fname") && rm "$fname"
	local extended=$*"\n"$former
	echo "$extended" >"$fname"
}
works() {
	$EDITOR ~/self.notes/work.md
}

cworks() {
	less <~/self.notes/work.md
}

stop() {
	for arg in "$@"; do
		for id in $(pgrep -f "$arg"); do
			kill "$id" &>/dev/null
		done
	done
}

isprime() {
	for arg in "$@"; do
		perl -wle 'print "Prime" if (1 x shift) !~ /^1?$|^(11+?)\1+$/' "$arg"
	done
}

__plat() {
	printf "OS:\t%s\n" "$(head -n 1 </etc/issue | cut -d " " --complement -f5-)"
	printf "Model:\t%s\n" "$(sudo dmidecode | grep "Product Name:" | cut -d " " -f3- | head -n 1)"
	printf "Board:\t%s\n" "$(sudo dmidecode | grep "Product Name:" | cut -d " " -f3- | tail -n 1)"
	printf "Kernel:\t%s\n" "$(uname -r)"
	printf "NetCtl:\t%s\n" "$(lspci | grep "Network controller" | cut -d " " -f4-)"
	printf "Processor:\t%sx %s\n" "$(grep 'process' /proc/cpuinfo | wc -l)" "$(grep 'name' /proc/cpuinfo | uniq | cut -d" " -f3-)"
}

plat() {
	__plat | column -ts:
}

linkhere() {
	[ -z "$@" ] && items="$(p)"
	[ -n "$@" ] && items=$@
	for name in $items; do
		[ -f "$name" ] && ln -f "$name" .
	done
}

east() {
	for arg in "$@"; do
		[ -f "$arg" ] && bat "$arg" && printf "end of \"%s\"\n" "$arg"
	done
}

gitpop() {
	quietly firefox $(git remote -v | head -n 1 | cut -d@ -f2 | cut -d" " -f1)
}

cph() {
	$* -h &>/dev/stdout | c
}

cde() {
	cd $1 && $EDITOR
}

forever() {
	while true; do $*; done
}

rjustify() {
	local max_len=$(printf "%s\n" "$@" | awk '{ print length }' | sort -nr | head -n 1)
	for arg in "$@"; do
		printf "%*s\n" "$max_len" "$arg"
	done
}

is_assignment() {
	local arg="$1"
	# Must contain exactly one '=' that's not at the beginning
	# and not part of an operator like +=, -=, etc.
	if [[ $arg =~ ^[a-zA-Z_][a-zA-Z0-9_]*=[^=]*$ ]]; then
		# Check that there's no space before or after the '='
		if [[ ! $arg =~ [[:space:]] ]]; then
			return 0
		fi
	fi
	return 1
}

please() {
	local count=0
	local args=()
	local vars=()
	local cmd=""
	local sudo=false
	while (($#)); do
		if is_assignment "$1"; then
			vars+=("$1")
		else
			if [ -z "$cmd" ]; then
				case "$1" in
					sudo | pkexec) sudo=true ;;
					*) cmd="$1" ;;
				esac
			else
				args+=("$1")
			fi
		fi
		shift
	done
	if $sudo; then
		local guard=pkexec
		command -v "$guard" &>/dev/null || guard=sudo
		local full=("$guard" env "${vars[@]}" "$cmd" "${args[@]}")
	else
		local full=(env "${vars[@]}" "$cmd" "${args[@]}")
	fi
	while ! "$full[@]"; do
		count=$((count + 1))
	done
	[ $count = 0 ] || echo "Command succeeded after $count retries."
}

errc() {
	# $* 2>&1 | xclip -i -selection -clipboard
	$* 2>&1 | tcb
}

map() {
	local cmd=$1
	shift
	for arg in "$@"; do
		$cmd $arg
	done
}

gofiles() {
	local args="$@"
	[ "${#args}" = 0 ] && args+="."
	for arg in "${args[@]}"; do
		find "$arg" -name "*.go" ! -name "*_string.go" ! -name "*_templ.go"
	done
}

cheat() {
	command -v cheat &>/dev/null || {
		echo cannot find executable >/dev/stderr && return 1
	}
	case "$1" in
		'-s' | '-v' | '-e')
			command cheat $*
			;;
		'--conf')
			command glow -p $(command cheat $*) && command cheat $*
			;;
		*)
			command cheat $* | glow
			;;
	esac
}

ipof() {
	(($#)) || {
		{
			printf "global\t%s\n" "$(curl ipecho.net/plain 2>/dev/null)"
			ip addr show | egrep "^\s+inet\s" | egrep -v '\blo\b' | while read -r line; do
				read -A parts <<<"$line"
				printf '%s\t%s\n' "${parts[-1]}" "${parts[2]}"
			done
		} | sort | column -ts $'\t'
		return
	}
	# Return the IP of the host of the given urls
	for arg in "$@"; do
		ping -q -c1 -t1 $arg | tr -d '()' | awk '/^PING/{print $3}'
	done
}

flatline() {
	p | sed ':a;N;$!ba;s/\n/\\n/g' | c
}

nuke() {
	local pth="$(pwd)"
	cd .. && command rm -r "$pth"
}

nukef() {
	fn() {
		echo "$1"
		command rm -rf "$1" || return $?
	}
	local count=${1:-1}
	while [ $count -gt 0 ]; do
		local pth="$(pwd)"
		case "$pth" in
			'/' | "$HOME" | "$CLONES" | "$CLONES/$USER") return 1 ;;
			*) ;;
		esac
		cd .. && { fn "$pth" || return $?; }
		count=$((count - 1))
	done
}

# alias mass="du -xsh $(pwd)/(.|)* 2>/dev/null | sort -h"

# mass() {
# 	du -xsh $(pwd)/(.|)* 2>/dev/null | sort -h
# }

# mass() {}

weigh() {
	for arg in "$@"; do
		find "$arg" -mindepth 1 -maxdepth 1 -type d -print0 # | xargs -I{} du -sh "{}" | sort -h
	done | xargs -0 -I{} du -sh '{}' | sort -h
}

gcd() {
	local depth='--depth=1'
	[ "$1" = "-d" ] && depth='' && shift
	local name="$(basename "$1")"
	git clone $depth "$1" && cd "$name"
}

project() {
	local comment
	local command
	case $1 in
		'go')
			echo // go.mod && cat go.mod
			comment='//'
			command='gofiles'
			;;
		'py')
			comment='#'
			command='pyfiles'
			;;
		*)
			echo unsupported language \"$1\" && return 1
			;;
	esac
	for name in $($command); do
		echo $comment $name && cat $name
	done
}

_sfusage() {
	printf "usage:\n\t%s \"old str\" \"new str\"\n\t%s -i \"old str\" \"new str\" # to modify in place\n" "$1" "$1" >&2
}

sf() {
	local fail="_sfusage $0 && return 1"
	case $# in
		2)
			gf "$1" | xargs sed "s/$1/$2/g"
			;;
		3)
			([ "$1" == "-i" ] && gf "$2" | xargs sed -i "s/$2/$3/g" && return 0) || eval "$fail"
			;;
		*) eval "$fail" ;;
	esac
}

gf() {
	local dir="$PWD"
	[[ $1 == "-d" ]] && local dir="$2" && shift 2
	local files="$(find "$dir" -type f -name '*')"
	for arg in "$@"; do
		echo "$files" | xargs grep -l "$arg" 2>/dev/null
	done
}

frc() {
	# Get the frame rate and codec of a given video
	for name in "$@"; do
		ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$name" | tr '\n' ' ' && echo
	done
}

gg() {
	[ $# -gt 1 ] || {
		echo "usage: <command> | $0 arg1 arg2 [... argN]"
		return 1
	}
	local lines="$(cat)"
	for arg in "$@"; do
		lines="$(echo "$lines" | rg "$arg")"
	done
	echo "$lines"
}

goclean() {
	# Clean go's caches and re-fetch dependencies
	local origin="$(pwd)"
	([ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "log" ] || [ "$1" = "--log" ]) && du -sh "$HOME/(.|)*" 2>/dev/null | sort -h
	go clean -x -{test,fuzz,mod}cache
	for name in $CLONES/$USER/**/go.mod; do
		local dir="$(dirname "$name")"
		echo "$dir" && cd "$dir" && go mod tidy
		echo
	done
	([ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "log" ] || [ "$1" = "--log" ]) && du -sh "$HOME/(.|)*" 2>/dev/null | sort -h
	cd "$origin"
}

myip() {
	local ip="$(curl http://ipecho.net/plain)"
	echo "$ip"
}

distro() {
	cat /etc/*-release | cut -d= -f2 | sed 's/"//g' | tail -n1
}

plumb() {
	wine "/home/kendfss/.wine/drive_c/Program Files/Image-Line/FL Studio 2025/System/Tools/Plugin Manager/PluginManager.exe" &>/dev/null &
}

upyet() {
	while true; do
		ping -c3 -W5 ifconfig.me &>/dev/null && break
		sleep 10
	done
	local msg="Internet connection is up!"
	[ -x "$(command -v notify-send)" ] && notify-send -t 60000 "$msg"
	echo $msg
}

retract() {
	local version="$(git tag | tail -1)"
	[ -n "$1" ] && version="$1"
	git tag -d "$version" && git push origin :refs/tags/"$version"
}

reissue() {
	local version="$(git tag | tail -1)"
	[ -n "$1" ] && version="$1"
	git tag -d "$version" && git push origin :refs/tags/"$version" && git tag "$version" && git push origin "$version"
}

assume() {
	for name in "$@"; do
		sudo setfacl -m u:$(whoami):rwx "$name"
	done
}

peek() {
	fzf -em --preview 'bat -p {}'
}

# xq() {
#   for arg in "$@"; do
#     xbps query -Rs $arg | rg "$(printf '] (\w+(-)?)*%s((-)?\w+)*-' "$arg")" | rg "$arg"
#   done
# }

xi() {
	local args=()
	local update=""
	while [ $# -gt 0 ]; do
		if [ "$1" = "-u" ]; then
			update="-u" && shift && continue
		else
			args+=("$1") && shift && continue
		fi
	done
	sudo xbps-install -S $update ${args[@]}
}

xr() {
	if [ $# = 0 ]; then
		sudo xbps-remove -yoO
	else
		sudo xbps-remove $*
	fi
	return $?
}

gmt() {
	go mod tidy
}

gmi() {
	go mod init "$REPO_HOST/$USER/$(basename "$(pwd)")"
}

clean() {
	local blob="$1"
	shift
	if (($# & 1 != 1)); then
		echo "must have an even number of (pattern replacement) argument pairs"
		return 1
	fi
	local sed=""
	while [ $# -gt 0 ]; do
		sed+="s/$1/$2/g;"
		shift 2
	done
	echo "$blob" | sed $sed
}

dsu() {
	local name
	[ $# -gt 0 ] && {
		for name in "$@"; do
			du -sh "$name"/{.?,}* 2>/dev/null | sort -h
		done
		return $?
	}
	du -sh {.?,}* 2>/dev/null | sort -h
}
