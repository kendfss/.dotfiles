if [[ $(uname) -eq Linux ]]; then
  [[ -d "$HOME/Android/Sdk" ]] && ANDROID_STUDIO_HOME=$HOME/Android/Sdk/android-studio
  [[ -d "$ANDROID_STUDIO_HOME" ]] && alias anstu="$ANDROID_STUDIO_HOME/bin/studio.sh"
  [[ -d "$HOME/Android" ]] && export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  [[ -d "$ANDROID_SDK_ROOT" ]] && PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"
  export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/20.1.5948944"
fi

alias pt=ptpython
alias lst="ls --time=ctime"
# alias pip=pip3
alias treec="tree | c && p"
# alias py39="/usr/local/opt/python@3.9/libexec/bin/python"
# alias pip39="/usr/local/opt/python@3.9/libexec/bin/pip"
# alias python39="/usr/local/opt/python@3.9/libexec/bin/python"
alias cl="clear; ls"
# alias st="open -a \"/Applications/Sublime Text.app/Contents/MacOS/sublime_text\""
alias editor="$EDITOR"
alias glone="cd $HOME/gitclone; python main.py"
# alias glone="$HOME/gitclone/main.py"
alias sqin="mysql -u root -p"
alias isfile="test -f"
# alias p=pbpaste
# alias c=pbcopy
# alias goc="go doc"
alias voc="v doc -comments"
alias gtidy="go tidy -v"
alias gos="cd \$GOS"
# alias gop="cd \$GOPATH/src"
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
alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport
alias gfm="git fetch && git merge"
alias cgun="clear; gun"
alias gun="$GOFMT -e -w .; go run"
alias vimguide="vim $HOME/gitclone/clones/hackjutsu/vim-cheatsheet/readme.md"
alias unhide="echo -en \"\e[?25h\""
alias wipe="/usr/bin/osascript -e 'tell application \"System Events\" to tell process \"Terminal\" to keystroke \"k\" using command down'"
alias cls="printf '\33c\e[3J'"
alias pocw="open 'file://$HOME/Documents/docs/python-3.10.0rc1-docs-html/index.html'"
# alias vstgen=/Users/kendfss/programs/scripts/vstgen.make
alias router="open http://192.168.8.1/html/home.html"
alias uuid='uuidgen | tr "[A-Z]" "[a-z]"'
alias reddit="s -p reddit"
alias gv="gh repo view"
alias status="git status"

