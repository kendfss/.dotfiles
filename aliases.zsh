if [[ $SHELL == *"zsh" ]]; then
	[[ "$(type run-help)" == *"alias"* ]] && unalias run-help
	autoload run-help
	alias help=run-help
fi

alias .="cd $DOTFILES"
alias ~="cd $HOME"
alias sed="sed -E"
alias spaced='tr "[:space:]" " "'
alias lined='tr "[:space:]" "\n"'
alias upper='tr "[:lower:]" "[:upper:]"'
alias lower='tr "[:upper:]" "[:lower:]"'
alias words='tr -cs "[:alpha:]" "\n"'
alias freqs='sort | uniq -c | sort -n'
alias mime='file -b --mime-type'

if [ -d "$TERMUX__HOME" ]; then
	alias cpv="rsync -poghb --backup-dir=$TERMUX__PREFIX/tmp/rsync -e /dev/null --progress --"
	alias hp17='ssh hp17'
	alias hp17t='ssh hp17t'
else
	alias pt="trans en:pt"
	alias en="trans pt:en"
	alias a12='ssh a12'
	alias a12t='ssh a12t'
fi

if [ -x "$(command -v sk)" ] && [ -x "$(command -v fzf)" ]; then
	echo "WARNING both fzf and skim/sk installed!" >&2
elif [ -x "$(command -v sk)" ]; then
	fzf() { command sk "$@"; }
elif [ -x "$(command -v fzf)" ]; then
	sk() { command fzf "$@"; }
	alias fzp="fzf --bind='btab:toggle,tab:preview:xdg-open {}' --preview-window hidden"
else
	echo "neither fzf or skim are installed" >&2
fi

[ -x "$(command -v zoxide)" ] && alias cd=z

if ! command -v rg &>/dev/null; then
	echo "ripgrep not found. setting alias rg='grep -E'. good luck!"
	alias rg='grep -E'
fi
[ "$0" = "bash" ] && alias exit='exit &>/dev/null'
alias glog='git log --graph --decorate --oneline'
alias rg='rg -g "!.git/"'
[ "$0" = "zsh" ] && alias -g G='| grep' && alias -g L='| less'
alias br="ffprobe -v 0 -select_streams a:0 -show_entries stream=bit_rate -of compact=p=0:nk=1"

[ -x "$(which bat)" ] || alias bat=less

[ -x "$(command -v git)" ] && {
	alias pull='git pull'
	alias gfm="git fetch && git merge"
	alias reddit="s -p reddit"
	alias gv="gh repo view"
	alias status="git status"
	alias statusu="git status -uno"
	alias lg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
	alias gc="git commit -m"
	alias gst="git status -sb"
	alias checkout="git checkout"
}
[ -x "$(command -v fd)" ] && {
	alias lsd="fd --type d --maxdepth 1"
	alias lsf="fd --type f --maxdepth 1"
}
[ -n "$EDITOR" ] && alias editor="$EDITOR"
[ -x "$(command -v v)" ] && alias voc="v doc -comments"
[ -x "$(command -v mysql)" ] && alias sqin="mysql -u root -p"
[ -x "$(command -v go)" ] && alias gtidy="go tidy -v"

alias lst="ls --time=ctime"
alias cl="clear; ls"
alias isfile="test -f"
alias gos="cd \$GOS"
alias md="mkdir -p"
alias pcd="cd \"\$(p)\""
alias ccd="pwd | c"
alias intip="ifconfig | grep \"inet \" | grep -v 127.0.0.1"
alias extip="curl ifconfig.me"
alias naming="clear; cd $HOME/gitclone/clones/kendfss/alphabet_souper; python -i main.py"
alias mouseinfo="python -m mouseinfo"
alias links="find \"\$(p)\" -maxdepth 1 -type l -ls"
alias rmf="rm -rf"
alias cgun="clear; gun"
alias gun="$GOFMT -e -w .; go run"
alias vimguide="vim $HOME/gitclone/clones/hackjutsu/vim-cheatsheet/readme.md"
alias unhide="echo -en \"\e[?25h\""
alias cls="printf '\33c\e[3J'"
alias uuid='uuidgen | tr "[A-Z]" "[a-z]"'
# # Search running processes. Usage: psg <process_name>
alias psg="ps aux $([[ -n "$(uname -a | grep CYGWIN)" ]] && echo '-W') | grep -i $1"
alias lsa='ls -a'
alias ll='ls -l'
alias la='ls -la'
alias md='mkdir -p'
alias d='dirs -v | head -10' # List the last ten directories we've been to this session, no duplicates
