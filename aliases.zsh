if [[ "$SHELL" = *"zsh" ]]; then
  [[ "$(type run-help)" = *"alias"* ]] && unalias run-help
  autoload run-help
  alias help=run-help
fi

alias .="cd $DOTFILES"
alias ~="cd $HOME"
alias sed="sed -E"
alias upper='tr "[:lower:]" "[:upper:]"' 
alias lower='tr "[:upper:]" "[:lower:]"' 
alias words='tr -cs "[:alpha:]" "\n"'
alias freqs='sort | uniq -c | sort -n'

if [ -x "$(command -v sk)" ] && [ -x "$(command -v fzf)" ]; then
  echo "WARNING both fzf and skim/sk installed!" >&2
elif [ -x "$(command -v sk)" ]; then
  alias skim=sk
  alias fzf=sk
  source <(sk --shell zsh)
elif [ -x "$(command -v fzf)" ]; then
  skim() { fzf "$@"; }
  sk() { fzf "$@"; }
  source <(fzf --zsh)
else
  echo "neither fzf or skim are installed" >&2
fi

if ! command -v rg &>/dev/null; then
  echo "ripgrep not found. setting alias rg='grep -E'. good luck!"
  alias rg='grep -E'
fi
[ "$0" = "bash" ] && alias exit='exit &>/dev/null'
alias glog='git log --graph --decorate --oneline'
alias rg='rg -g "!.git/"'
[ "$0" = "zsh" ] && alias -g G='| grep' && alias -g L='| less'
alias br="ffprobe -v 0 -select_streams a:0 -show_entries stream=bit_rate -of compact=p=0:nk=1"

alias pull='git pull'
alias push='git push'
alias zt=zathura
alias pt=ptipython
alias lst="ls --time=ctime"
alias treec="tree | c && p"
alias cl="clear; ls"
alias editor="$EDITOR"
alias glone="cd $HOME/gitclone; python main.py"
alias sqin="mysql -u root -p"
alias isfile="test -f"
alias voc="v doc -comments"
alias gtidy="go tidy -v"
alias gos="cd \$GOS"
alias md="mkdir -p"
alias pcd="cd \"\$(p)\""
alias rmp="rm \"\$(p)\""
alias ccd="pwd | c"
alias intip="ifconfig | grep \"inet \" | grep -v 127.0.0.1"
alias extip="curl ifconfig.me"
alias naming="clear; cd $HOME/gitclone/clones/kendfss/alphabet_souper; python -i main.py"
alias mouseinfo="python -m mouseinfo"
alias brewenv="open \"$HOME/Library/Caches/Homebrew/downloads\""
alias links="find \"\$(p)\" -maxdepth 1 -type l -ls"
alias rmf="rm -rf"
alias gfm="git fetch && git merge"
alias cgun="clear; gun"
alias gun="$GOFMT -e -w .; go run"
alias vimguide="vim $HOME/gitclone/clones/hackjutsu/vim-cheatsheet/readme.md"
alias unhide="echo -en \"\e[?25h\""
alias cls="printf '\33c\e[3J'"
alias uuid='uuidgen | tr "[A-Z]" "[a-z]"'
alias reddit="s -p reddit"
alias gv="gh repo view"
alias status="git status"
alias statusu="git status -uno"
alias lg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
alias gc="git commit -m"
alias gst="git status -sb"
alias checkout="git checkout"
# # Search running processes. Usage: psg <process_name>
alias psg="ps aux $( [[ -n "$(uname -a | grep CYGWIN )" ]] && echo '-W') | grep -i $1"
# Copy with a progress bar
alias cpv="rsync -poghb --backup-dir=$TERMUX__PREFIX/tmp/rsync -e /dev/null --progress --" 
alias lsa='ls -a'
alias ll='ls -l'
alias la='ls -la'
alias md='mkdir -p'
alias rd='rmdir'
alias d='dirs -v | head -10'                      # List the last ten directories we've been to this session, no duplicates

# [[ -z "$(command -v which)" ]] && alias which="command -v"
# [[ -z "$(command -v mkdir)" ]] && alias mkdir="$TERMUX__ROOTFS_DIR/usr/bin/mkdir"


