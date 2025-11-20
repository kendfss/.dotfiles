if [[ $(uname) -eq Linux ]]; then
  [[ -d "$HOME/Android/Sdk" ]] && ANDROID_STUDIO_HOME=$HOME/Android/Sdk/android-studio
  [[ -d "$ANDROID_STUDIO_HOME" ]] && alias anstu="$ANDROID_STUDIO_HOME/bin/studio.sh"
  [[ -d "$HOME/Android" ]] && export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  [[ -d "$ANDROID_SDK_ROOT" ]] && PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"
  export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/20.1.5948944"
fi

if [ -x "$(command -v sk)" ] && [ -x "$(command -v fzf)" ]; then
  echo "WARNING both fzf and skim/sk installed!"
elif [ -x "$(command -v sk)" ]; then
  alias skim=sk
  alias fzf=sk
elif [ -x "$(command -v fzf)" ]; then
  alias skim=fzf
  alias sk=fzf
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
alias zt=zathura
alias pt=ptpython
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
export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

