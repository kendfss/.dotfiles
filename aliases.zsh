case "$SHELL" in
	bash) alias exit='exit &>/dev/null' ;;
	zsh)
		alias -g G="| grep" && alias -g L="| less"
		[[ "$(type run-help)" == *"alias"* ]] && unalias run-help
		autoload run-help
		alias help=run-help
		;;
esac

alias nansi="command sed -E 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2})*)?[mGK]//g'"
alias nansi="command sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g'"
alias pd="cd -1"
alias sudo="sudo -E"
alias dvtm="dvtm -m '^['"
alias .="cd $DOTFILES"
alias ~="cd $HOME"
alias ..="cd .."
alias sed="sed -E"
alias spaced="tr '[:space:]' ' ' | sed 's: $::'"
alias lined="tr '[:space:]' '\n' | grep -Ev '^\s+$'"
alias upper="tr '[:lower:]' '[:upper:]'"
alias lower="tr '[:upper:]' '[:lower:]'"
alias words="tr -cs '[:alpha:]' '\n'"
alias freqs="sort | uniq -c | sort -n"
alias mime="file -b --mime-type"
alias when="ls -1ctr"

command -v hx >/dev/null 2>&1 && alias hxg="hx --grammar fetch && hx --grammar build"
command -v reload >/dev/null 2>&1 && alias reload="exec $(command -v reload)"
command -v jellyfin >/dev/null 2>&1 && alias jellyfin="exec $(command -v jellyfin)"
command -v fastfetch >/dev/null 2>&1 && alias about="echo a reduced fastfetch; fastfetch | grep -Eo '\s+([A-Z]([A-Z]|[a-z])+)+[\s:].+' | sed -E 's:^\s+::' | tac | sed 1d | tac | column -ts:"

if [ -d "$TERMUX__HOME" ]; then
	case "$(/system/bin/getprop ro.product.device 2>/dev/null)" in
		a7)
			alias a12="ssh a12"
			alias a12t="ssh a12t"
			;;
		a12)
			alias a7="ssh a7"
			alias a7t="ssh a7t"
			;;
	esac
	alias cpv="rsync -poghb --backup-dir=$TERMUX__PREFIX/tmp/rsync -e /dev/null --progress --"
	alias hp17="ssh hp17"
	alias hp17t="ssh hp17t"
	alias rpi400="ssh rpi400"
	alias rpi400t="ssh rpi400t"
else
	case "$(hostname)" in
		hp17)
			alias rpi400="ssh rpi400"
			alias rpi400t="ssh rpi400t"
			;;
		rpi400)
			alias hp17="ssh hp17"
			alias hp17t="ssh hp17t"
			;;
	esac
	alias cpv="rsync -poghb --backup-dir=/tmp/rsync -e /dev/null --progress --"
	alias pt="trans en:pt"
	alias en="trans pt:en"
	alias a7="ssh a7"
	alias a7t="ssh a7t"
	alias a12="ssh a12"
	alias a12t="ssh a12t"
fi

command -v abduco &>/dev/null && alias a=abduco

if [ -x "$(command -v sk)" ] && [ -x "$(command -v fzf)" ]; then
	echo "WARNING both fzf and skim/sk installed!" >&2
elif [ -x "$(command -v sk)" ]; then
	fzf() { command sk "$@"; }
elif [ -x "$(command -v fzf)" ]; then
	sk() { command fzf "$@"; }
else
	echo "neither fzf or skim are installed" >&2
fi

if ! command -v rg &>/dev/null; then
	echo "ripgrep not found. setting alias rg='grep -E'. good luck!"
	alias rg="grep -E"
else
	alias rg="rg -g '!.git/'"
fi

[ -x "$(command -v ffprobe)" ] && alias br="ffprobe -v 0 -select_streams a:0 -show_entries stream=bit_rate -of compact=p=0:nk=1"

[ -x "$(command -v s)" ] && {
	alias reddit="s -p reddit"
}

[ -x "$(command -v git)" ] && {
	alias glog="git log --graph --decorate --oneline"
	alias pull="git pull"
	alias gfm="git fetch && git merge"
	alias gv="gh repo view"
	alias status="git status"
	alias statusu="git status -uno"
	alias lg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
	alias gc="git commit -m"
	alias gst="git status -sb"
	alias checkout="git checkout"
	alias submod="git submodule update --init --recursive --remote"
}
[ -x "$(command -v fd)" ] && {
	alias lsd="fd --type d --maxdepth 1"
	alias lsf="fd --type f --maxdepth 1"
	alias fd="fd --one-file-system"
}
[ -n "$EDITOR" ] && alias editor="$EDITOR"
[ -x "$(command -v v)" ] && alias voc="v doc -comments"
[ -x "$(command -v mysql)" ] && alias sqin="mysql -u root -p"
[ -x "$(command -v go)" ] && {
	alias gtidy="go mod tidy -v"
	alias gup="git init && joe g go > .gitignore && license gpl > LICENSE && go mod init github.com/$USER/$(basename $PWD) && go mod tidy -v"
}
[ -x "$(command -v pack)" ] && alias idr="pack repl"

alias lst="ls --time=ctime"
alias md="mkdir -p"
alias pcd="cd \"$(p)\""
alias ccd="pwd | c"
alias intip="ifconfig | grep \"inet \" | grep -v 127.0.0.1"
alias extip="curl ifconfig.me"
alias naming="clear; cd $HOME/gitclone/clones/kendfss/alphabet_souper; python -i main.py"
alias mouseinfo="python -m mouseinfo"
alias unhide="echo -en '\e[?25h'"
alias cls="printf '\33c\e[3J'"
alias uuid="uuidgen | tr '[A-Z]' '[a-z]'"
alias lsa="ls -a"
alias ll="ls -l"
alias la="ls -la"
alias md="mkdir -p"
alias d="dirs -v | head -10" # List the last ten directories we've been to this session, no duplicates
alias preto="printf '\033]11;#000000\007'"
