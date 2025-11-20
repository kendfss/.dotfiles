# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html
autoload -Uz add-zsh-hook

goc() {
  case $1 in
  '')
    go doc -u | bat -Pplgo --theme ansi;;
  '-ua')
    go doc -u -all | bat -Pplgo --theme ansi;;
  '-u')
    shift
    for arg in "$@"; do
      go doc -u $arg | bat -Pplgo --theme ansi
    done;;
  '-all')
    shift
    for arg in "$@"; do
      go doc -all $arg | bat -Pplgo --theme ansi
    done;;
  *)
    for arg in "$@"; do
      go doc "$arg" | bat -Pplgo --theme ansi
    done;;
  esac
}

poc() {
  [[ $# -eq 0 ]] && local args=(".") || local args=("$@")
  for arg in $args; do
    pydoc $arg | bat -Pplpython --theme ansi
  done
}

recover() {
  for arg in $@; do 
    git checkout "$(git rev-list -1 HEAD -- '$arg')^" -- '$arg'
  done
}

ext() {
  for arg in "$@"; do
    [ -f "$arg" ] && local base="$(basename "$arg")" && local ext="${base##*.}"
    [ "$ext" = "$base" ] && ext=""
    echo "$ext";
  done
}

exts() {
  if [ "$1" = "-s" ]; then
    shift 1
    ext "$@" | sort -ui
  else
    ext "$@"
  fi
}

_() {
  [[ -z $1 ]] && argv[1]="$(pwd)"
  dir=$1
  shift 1 > /dev/null || return 1

  local files=$(ls -1 $dir)
  local extensions=()

  for file in $files; do
      local extension=${file##*.}
      extensions+=($extension)
  done

  for extension in $extensions; do
      echo "$extension"
  done
}

tpb() {
  tmux save-buffer -
}

tcb() {
  tmux save-buffer - | xclip -i -selection clipboard
}


take() {
  # Make a directory and cd into it
  mkdir -p $1 && cd $1
}
alias mcd=take

cv2() {
  local cmd=$1
  shift
  $(command -v $cmd) $*
}


cv1() {
  for arg in "$@"; do
    command -v $arg
  done
}


function extract {
  # Intellegently extract archives based on extension. 
  local file=$1
  shift
  local dir=$1

   if [[ -n $dir ]]; then
      mkdir -p "$dir"; 
      echo Extracting "$file" into "$dir" ...
   else 
      echo Extracting "$file" ...
   fi
 
   if [[ ! -f $file ]] ; then
      echo "'$file' is not a valid file"
   else
      case $file in
         *.tar.bz2)   
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar xjvf \"$file\" $dc" 
             echo $cmd
             eval ${cmd}
             ;;   

         *.tar.gz)    
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar xzvf \"$file\" $dc"; 
             echo $cmd;
             eval ${cmd}
             ;;

         *.tar)       
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar vxf \"$file\" $dc";
             echo $cmd;
             eval ${cmd}
             ;;

         *.tbz2)      
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar xjvf \"$file\" $dc";
             echo $cmd; 
             eval ${cmd}
             ;;  

         *.tgz) 
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar xzf \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd} 
             ;;    

         *.bz2)       
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar jf \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd} 
             ;;     

         *.zip)       
             if [[ -n $dir ]]; then dc="-d $dir"; fi
             local cmd="unzip \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd}
             ;;

         *.gz)
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             local cmd="tar zf \"$file\" \"$dc\""; 
             echo $cmd; 
             eval ${cmd}
             ;;

         *.7z)        
             #TODO dir
             local cmd="7z x -o \"$dir\" \"$file\""; 
             echo $cmd; 
             eval ${cmd} 
             ;;

         *.rar)       
             #TODO Dir
             local cmd="unrar x \"$file\" \"$dir\"";
             echo $cmd;
             eval ${cmd}
             ;;
         *)           
            echo "'$file' cannot be extracted via extract()" 
            ;;
         esac
   fi
}


function web_search() {
  # Web_search from terminal
  emulate -L zsh
 
  # Define search engine URLS
  typeset -A urls
  local urls=(
    google      "https://www.google.com/search?q="
    ddg         "https://www.duckduckgo.com/?q="
    github      "https://github.com/search?q="
  )
 
  # Check whether the search engine is supported
  if [[ -z "$urls[$1]" ]]; then
    echo "Search engine $1 not supported."
    return 1
  fi
 
  # Search or go to main page depending on number of arguments passed
  if [[ $# -gt 1 ]]; then
    # Build search url:
    # Join arguments passed with '+', then append to search engine URL
    local url="${urls[$1]}${(j:+:)@[2,-1]}"
  else
    # Build main page url:
    # Split by '/', then rejoin protocol (1) and domain (2) parts with '//'
    local url="${(j://:)${(s:/:)urls[$1]}[1,2]}"
  fi
 
  open_command "$url"
}
 
function open_command() {
  # Use generalized open command
  emulate -L zsh
  setopt shwordsplit
 
  local open_cmd
 
  # Define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   open_cmd='xdg-open' ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac
 
  # Don't use nohup on OSX
  if [[ "$OSTYPE" == darwin* ]]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}

urlencode() {
    # Urlencode <string>
    local LANG=C
    local LC_COLLATE=C
    local length="${#1}"
    for (( arg = 0; i < length; i++ )); do
        local c="${1:$arg:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}


reload() {
  exec $SHELL -l
}

bckp() {
  local origin=$(pwd)
  local old=$1
  if [[ -z "$old" ]]; then
    old="../$(basename "$(pwd)")"
  fi
  local new="$old-$0"
  [[ -d $new ]] && echo "already exists" && return 1
  [[ -f $new ]] && echo "already exists" && return 1
  [[ -d $old ]] && cp -rf "$old/" "$new" && cd "$origin" && echo "backed up $old to $new"
  [[ -f $old ]] && cp "$old" "$new" && cd "$origin" && echo "backed up $old to $new"
}

blank() {
  for arg in {1..$1}; do
    echo ""
  done
}

bar() {
  local char="*"
  if [[ $2 ]]; then
    char=$2
  fi
  for arg in {1..$1}; do
    printf "%s" "$char"
  done
  print ""
}

10print () {
  local RANDOM=$(date +%s)
  declare -a chars
  local chars=(\\ /)
  chars=(\# " ")
  for arg in {1..$1}; do
    ind=$(($RANDOM % 2))
    printf "%s" "${chars[$(($ind + 1))]}"
  done
  echo ""
}


rename() {
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
  local depth="--depth=1"
  if [[ "$1" == "-d" ]]; then
    depth=""
    shift 1
  fi
  if [[ $1 != *"/"* ]]; then
    local dev="$1"
    shift 1
  fi
  for repo in "$@"; do
    if [[ $repo == *"/"* ]]; then
      dev=$(basename "$(dirname "$repo")")
    fi
    repo=$(basename "$repo")
    echo "cloning $dev/$repo"
    take "$CLONEDIR/$dev" && git clone $depth "$REPO_HOST/$dev/$repo" "$repo" && cd "$repo" 
  done
}

fork() {
  if [[ $1 != *"/"* ]]; then
    local dev=$1
    shift 1
  fi
  for repo in "$@"; do
    if [[ $repo == *"/"* ]]; then
      local dev=$(basename "$(dirname "$repo")")
    fi
    local repo=$(basename "$repo")
    local user="$HOME/gitclone/clones/$USER" 
    mkdir -p "$user" && cd "$user" && gh repo fork "$dev/$repo" && cd "$repo" 2> /dev/null
  done
}

padd() {
  printf "\n" >> ~/.zprofile
  for arg in "$@"; do
    printf "%s\n" "$arg" >> ~/.zprofile
  done
}

def() {
  local fname=~/self.notes/definitions
  local term=$1
  shift 1
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$(printf "%s\n\t%s\n%s" "$term" "$*" "$former")
  echo "$extended" > "$fname"
}

defs() {
  $EDITOR ~/self.notes/definitions
}

cdefs() {
  cat ~/self.notes/definitions
}

amend() {
  git add . && git commit --amend && git push -f origin
}

issues() {
  gh repo issue "$@"
}

pm() {
  if [[ ! -a .git ]]; then
    git init
  fi
  if [[ ! -a go.mod ]]; then
    go mod init "github.com/$USER/$(base)" &> /dev/null
  fi
  go mod tidy
}

cmd() {
  mkdir -p cmd 
  [[ ${#argv[@]} -eq 0 ]] && echo "no extension. created dir but exiting with 1" && return 1
  [[ $1 == "go" ]] && printf "package main\n" >> "cmd/main.$1" && return 0
  [[ $1 == "v"  ]] && printf "module main\n" >> "cmd/main.$1" && return 0
  [[ ${#argv[@]} -eq 1 ]] && touch "cmd/main.$1" && return 0
  [[ ${#argv[@]} -gt 0 ]] && echo "using \"$1\" extension. will exit with 1" && touch "cmd/main.$1" && return 1
}

api() {
  mkdir -p api 
  [[ ${#argv[@]} -eq 0 ]] && echo "no extension. created dir but exiting with 1" && return 1
  [[ $1 == "go" ]] && printf "package %s\n" "api" >> "api/core.$1" && return 0
  [[ $1 == "v"  ]] && printf "module %s\n" "api" >> "api/core.$1" && return 0
  [[ $1 == "kurt" ]] || [[ $1 == "kt" ]] && touch "api/core.kt" && return 0
  [[ $1 == "marco" ]] || [[ $1 == "mc" ]] && touch "api/core.mc" && return 0
  [[ $1 == "fork" ]] || [[ $1 == "fk" ]] && touch "api/core.fk" && return 0
  [[ ${#argv[@]} -eq 1 ]] && touch "api/core.$1" && return 0
  echo "using \"$1\" extension. will exit with 1" && touch "api/core.$1" && return 1
}

add() {
  local dry=false
  local visible=false
  local hidden=false
  local force=""
  local help_text=$(cat <<EOF
usage: ${0} [flags] [args]
  stage files in a git repository
  
  flags:
    --help               print this message
    -v, --visible        include non-hidden files that aren't in gitignore
    -h, --hidden         include hidden files that aren't in gitignore
    -f, --force          forcefully stage files matched by .gitignore
    -d, --dry, --dry-run just print the names to the files that would be stage

  args:
    paths to any files

  examples:
    # stage your readme
    $0 README.md
    # stage hidden and visible files (the order of terms doesn't matter in short flags)
    $0 -hv
    # stage all tracked files
    $0
EOF
)

  while [[ $# -gt 0 ]]; do
    case "$1" in
      '--help') echo "$help_text"; return 0;;
      '-v'|'--visible') visible=true;;
      '-h'|'--hidden') hidden=true;;
      '-d'|'--dry'|'--dry-run') dry=true;;
      '-f'|'--force') force="-f";;
      -*) 
        [[ "$1" == *"v"* ]] && visible=true
        [[ "$1" == *"h"* ]] && hidden=true
        [[ "$1" == *"d"* ]] && dry=true
        [[ "$1" == *"f"* ]] && force="-f"
        ;;
      *) break;;  
    esac
    shift
  done

  local files=""

  if [[ $# -gt 0 ]]; then
    files=$(printf "%s\n" "$@")
  fi

  if [[ $# -eq 0 ]] && ! $visible && ! $hidden; then
    files+=$(git status -s | rg '^[ MA]M\s' | awk '{print $2}')$'\n'
    files+=$(git status -s | rg '^[ R]M\s' | awk '{print $4}')$'\n'
  fi
  
  if $visible; then
    files+=$(git status -s -- [^.]* 2>/dev/null | awk '{print $2}')$'\n'
  fi
  
  if $hidden; then
    files+=$(git status -s -- .[^.]* 2>/dev/null | awk '{print $2}')$'\n'
  fi

  files=$(echo "$files" | rg -v '^\s*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)
  
  if [[ -z "$files" ]]; then
    echo "no changes" >&2
    return 1
  fi

  if $dry; then
    echo "would add:"
  else
    echo "$files" | xargs -r git add $force
    echo "added:"
  fi
  
  echo "$files" | while IFS= read -r file; do
    [[ -n "$file" ]] && printf "    %s\n" "$file"
  done
}

commit() {
  local msg="$*"
  git commit -m "$msg"
}

push() {
  git push origin
}

acp() {
  if [[ -z $1 ]]; then
    argv[1]=\.
  fi
  if [[ -z $2 ]]; then
    argv[2]=sorry
  fi
  if [[ -z $3 ]]; then
    argv[3]=origin
  fi
  add $1 && commit $2 && push $3
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

startover() {
  local name="$(pwd)"
  local readme=$(cat readme.md)
  discontinue
  mkdir -p "$name" && cd "$name" || return 1
  echo "$readme" > README.md
  create "$1"
  $EDITOR .
}

discontinue() {
  if [[ -z "$@" ]]; then
    local name="$(basename $PWD)"
    gh repo delete "$USER/$name" --yes && cd .. && rm -rf "$name"
  else
    for arg in "$@"; do
      local name="$(basename $arg)"
      gh repo delete "$USER/$name" --yes && rm -rf "$name"
    done
  fi
}

clobber() {
  rm "$1"
  echo "$2" > "$1"
}

clobberp() {
  rm "$1"
  p > "$1"
}

relocate() {
  local here=$(pwd)
  local name=$(base)
  local dest=$1/$name
  mkdir -p "$dest"
  mv "$here" "$1" && cd "$dest" || return 1
}

cds () {
  cd "$1" && $EDITOR .
}

co() {
  git checkout $*
}

sha256() {
  # Compute sha256 sum of a file or string if file is not found
  local cmd;
  local cut;
  cmd='openssl dgst -sha256 -r'
  cut='cut -d " " -f 1'
  for name in "$@"; do
    ([ -f "$name" ] && openssl dgst -sha256 -r "$name" | cut -d" " -f1) || echo "$name" |  openssl dgst -sha256 -r | cut -d" " -f1
  done
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

zdot() {
  $EDITOR "$DOTFILES/(.*(conf|fig|ore|env|rc|file)|*.zsh)"
}

here() {
  dirname `readlink -f $0`
}

titles() {
  local fname=~/self.notes/track_titles
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$*"\n"$former
  echo "$extended" > "$fname"
}

keep() {
  local fname=$(pwd)/keeps.md
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$*"\n"$former
  echo "$extended" > "$fname"
}

if [[ $(uname) -eq Linux ]]; then
  open() {
    xdg-open $* > /dev/null
  }
fi

fname() {
  for fullpath in "$@"; do
    local filename="${fullpath##*/}"                      # Strip longest match of */ from start
    local base="${filename%.[^.]*}"                       # Strip shortest match of . plus at least one non-dot char from end
    local ext="${filename:${#base} + 1}"                  # Substring from len of base thru end
    if [[ -z "$base" && -n "$ext" ]]; then          # If we have an extension and no base, it's really the base
      base=".$ext"
      ext=""
    fi
    echo "$base"
  done
}
        
fext() {
  filename="${fullpath##*/}"                      # Strip longest match of */ from start
  base="${filename%.[^.]*}" 
  echo "${filename:${#base} + 1}" 
}

quietly() {
  local cmd=$1
  shift 1
  for arg in "$@"; do
    $cmd "$arg" &> /dev/null &
  done
}

stdout() {
  cmd=$1
  shift 1
  $cmd $* &> /dev/stdout | less
}

note() {
  local fname=~/self.notes/notes
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$*"\n"$former
  echo "$extended" > "$fname"
}

notes() {
  $EDITOR ~/self.notes/notes
}

cnotes() {
  less < ~/self.notes/notes
}

etch() {
  local fname="$HOME/self.notes/$*.md"
  local name=$(echo "$fname" | sed "s/ /_/g")
  [[ ! -f "$fname" ]] && printf "%s\n---\n" "$*" > "$fname"
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
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$*"\n===\n"$former
  echo "$extended" > "$fname"
  $EDITOR "$fname"
}

posts() {
  $EDITOR ~/self.notes/notes
}

cposts() {
  cat ~/self.notes/notes
}

stars() {
  gh api user/starred --template '{{range .}}{{.full_name|color "yellow"}}{{"\n"}}{{end}}'
}

processing-java() {
  local oldHome=$JAVA_HOME
  JAVA_HOME=/usr/local/jdk-17.0.4+8 /home/kendfss/gitclone/clones/processing/processing4/build/linux/work/processing-java $*
  JAVA_HOME=$oldHome
}

processing() {
  local oldHome=$JAVA_HOME
  JAVA_HOME=/usr/local/jdk-17.0.4+8 /home/kendfss/gitclone/clones/processing/processing4/build/linux/work/processing $*
  JAVA_HOME=$oldHome
}

frep() {
  local root=$1
  local patt=$2
  [[ -z $3 ]] && grep -irl "$patt" "$root" | grep -i "$patt"
  [[ -n $3 ]] && grep -irl "$patt" "$root"
}

procapi() {
  local root=/home/kendfss/gitclone/clones/processing/processing-docs
  local data=$root/content/api_en
  $EDITOR "$root" && $EDITOR $(frep "$data" "$1")
}

procex() {
  local root=/home/kendfss/gitclone/clones/processing/processing-docs
  local data=$root/content/examples
  $EDITOR "$root" && $EDITOR $(frep "$data" "$1")
}

progrep() {
  local root=/home/kendfss/gitclone/clones/processing/processing-docs
  frep "$root" "$1"
}

name_all() {
  local name=$1
  local args=( ${@[@]:2} )
  for pth in $args; do 
    mv "$pth" "$(namespacer "$name")"
  done
}

work() {
  local fname=~/self.notes/work.md
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  local extended=$*"\n"$former
  echo "$extended" > "$fname"
}
works() {
  $EDITOR ~/self.notes/work.md
}

cworks() {
  less < ~/self.notes/work.md
}

stop() {
  for arg in "$@"; do
    for id in $(pgrep -f "$arg"); do
      kill "$id" &> /dev/null
    done
  done
}

isprime() {
  for arg in "$@"; do
    perl -wle 'print "Prime" if (1 x shift) !~ /^1?$|^(11+?)\1+$/' "$arg"
  done
}

__plat() {
  printf "OS:\t%s\n" "$(head -n 1 < /etc/issue | cut -d " " --complement -f5-)"
  printf "Model:\t%s\n" "$(sudo dmidecode | grep "Product Name:" | cut -d " " -f3- | head -n 1)"
  printf "Board:\t%s\n" "$(sudo dmidecode | grep "Product Name:" | cut -d " " -f3- | tail -n 1)"
  printf "Kernel:\t%s\n" "$(uname -r)"
  printf "NetCtl:\t%s\n" "$(lspci | grep "Network controller" | cut -d " " -f4-)"
  printf "Processor:\t%sx %s\n" "$(cat /proc/cpuinfo | grep 'process' | wc -l)" "$(cat /proc/cpuinfo | grep 'name' | uniq | cut -d" " -f3-)"
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

fl() {
  local pids="$(pgrep FL64\.exe)"
  [ -n "$pids" ] && echo "$pids" | xargs -I{} kill -9 {} && { [ -z "$1" ] && return }
  case "$1" in
    '-r'|'--reload'|'r'|'reload') shift 1;;
    '-k'|'--kill'|'k'|'kill') return;;
    *);;
  esac
  quietly wine ~/.wine/drive_c/Program\ Files/Image-Line/FL\ Studio*/FL64.exe #$* #&> /dev/null
}

vimruntime() {
  vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|quit' | tr -d '\015' 
}

gitpop() {
  quietly firefox `git remote -v | head -n 1 | cut -d@ -f2 | cut -d" " -f1`
}

killbridge() {
  for id in $(pgrep --list-name ilbridge | cut -d" " -f1); do kill "$id"; done
}

cph() {
  $* -h &> /dev/stdout | c
}

goup() {
  local origin=$(pwd) && echo "$0: origin == $origin"
  local groot=$(go env GOROOT) && [[ -z $groot ]] && echo "$0: go root not found" && return 1
  cd "$groot" && echo "cd $groot"
  bckp "$groot" && echo "backup in $groot-bckp"
  git stash
  git pull
  git stash pop
  cd "$groot/src" && echo "cd \"$groot/src\""
  export GOROOT_BOOTSTRAP=$groot-bckp
  chmod +x ./make.bash
  ./make.bash
  cd ../bin && sudo ln -f $(pwd)/go /usr/bin/go
  cd "$origin"
  local newVer=$($groot/bin/go version)
  echo "$0: old version is $oldVer"
  local oldVer=$($GOROOT_BOOTSTRAP/bin/go version)
  echo "$0: new version is $newVer"
  rm -rf $GOROOT_BOOTSTRAP
}

cde() {
  cd $1 && $EDITOR
}

package() {
  local name=$1
  shift 1
  for file in "$@"; do
    echo "$0 $name" > "$file"
  done
}

cfg() {
  setopt no_nomatch # ignore empty glob results
  $EDITOR {$DOTDIR,$DOTDIR/helix}/{.*(conf|fig|ore|env|rc|file|toml),*.(zsh|toml)} 2> /dev/null
  unsetopt no_nomatch
}

absmod() {
  if [[ -f go.mod ]]; then
    local oldmod=$(cat go.mod)
    echo "$oldmod" > go.mod.tmp
    rm go.mod
    echo "$oldmod" | sed "s/\.\.\/\.\./\/home\/kendfss\/gitclone\/clones/g" go.mod.tmp | sed "s/\.\./\/home\/kendfss\/gitclone\/clones\/kendfss/g" | sed "s/psort/$(base)/g" > go.mod
  fi
}

forever() {
  while true; do $*; done
}


p() {
  xclip -o -selection clipboard
}

c() {
  xclip -i -selection clipboard
}

throw() {
  local code="$1"
  shift
  local text="$*"
  [[ -n "$text" ]] && echo "$text"
  return "$code"
}

rjustify() {
  local max_len=$(printf "%s\n" "$@" | awk '{ print length }' | sort -nr | head -n 1)
  for arg in "$@"; do
    printf "%*s\n" "$max_len" "$arg"
  done
}

fetch() {
  local count=0
  for url in "$@"; do
    while ! wget -q "$url"; do
      echo "Failed to fetch ${url##*/}."
      count=1
      sleep 1
    done
    count=0
    echo "Successfully fetched ${url##*/}."
  done
  return $count
}

please() {
  local count=0
  while ! "$@"; do
    count=$((count + 1))
  done
  if [[ ! $count -eq 0 ]]; then
    echo "Command succeeded after $count retries."
  fi
}

errc() {
  $* 2>&1 | xclip -i -selection -clipboard
}

map() {
  local cmd=$1
  shift
  for arg in "$@"; do 
    $cmd $arg
  done
}

new() {
    local name=$(echo "$*" | sed "s/ /_/g")
    local pth="$CLONEDIR/$USER/$name"

    if [ -d "$pth" ]; then
        cd "$pth"
    else
        if cd "$pth" 2> /dev/null || take "$pth"; then
            create
            return 0
        else
            echo "\"$pth\" already exists"
            return 1
        fi
    fi
}

create() {
    if [[ -z `find . -maxdepth 1 -iname 'readme.md' -print -quit` ]]; then
        printf "%s\n---\n" "$(base)" >> README.md
    fi

    if [ "$1" == "go" ] && [ ! -a "$1.mod" ]; then
        $1 mod init "github.com/$USER/$(basename "$(pwd)")"
        
        if [ ! -a "lib.$1" ]; then
            echo "package $(basename "$(pwd)")" > "lib.$1"
        fi

        cmd $1
        api $1
    fi

    if [ "$1" == "v" ] && [ ! -a "$1.mod" ]; then
        $1 init .

        if [ ! -a "lib.$1" ]; then
            echo "module $(basename "$(pwd)")" > "lib.$1"
        fi

        cmd $1
        api $1
    fi

    if [ ! -a ./.gitignore ]; then
        joe g "$1" > .gitignore
    fi

    if [ ! -a ./license ]; then
        license bsd-3 > LICENSE
    fi

    if [ ! -a ./.git ]; then
        git init
    fi

    add .
    commit "first"
    gh repo create "$(basename "$(pwd)")" --private --source=. --push
    $EDITOR .
}


switch() {
  local cmd="$1"
  shift
  sudo `cv2 "$cmd"` $*
}


gofiles() {
  find . -name "*.go" ! -name "*_string.go" ! -name "*_templ.go"
}


cheat() {
  for pth in {$HOME/{.local,go}/,/{usr/,}{s,}}bin/cheat; do [[ -x "$pth" ]] && local cmd=$pth && break; done
  [[ -z "$cmd" ]] && echo cannot find executable > /dev/stderr && return 1
  case $1 in
  '-s'|'-v'|'-e')
    $cmd $*;;
  '--conf')
    glow -p $($cmd $*) && $cmd $*;;
  *)
    $cmd $* | glow;;
  esac
}


ipof() {
  if [ $# = 0 ]; then
    printf "local:  %s\n" "$(ip addr show | awk '/^\s+inet\s/{print $2}' | tail -n1)"
    printf "remote: %s\n" "$(curl ipecho.net/plain 2>/dev/null)"
    return
  fi
  # Return the IP of the host of the given urls
  for arg in "$@"; do
    ping -q -c1 -t1 $arg | tr -d '()' | awk '/^PING/{print $3}'
  done
}

gouch() {
  for arg in "$@"; do
    mkdir "$arg"
    echo "package $arg\n" > "$arg/$arg.go"
  done
}

flatline() {
  p | sed ':a;N;$!ba;s/\n/\\n/g' | c
}

nuke() {
  local pth="`pwd`"
  cd .. && $(command -v rm) -r "$pth"
}

nukef() {
  local pth="`pwd`"
  cd .. && $(command -v rm) -rf "$pth"
}

mass() {
  du -sh (.|)* 2>/dev/null | sort -h
}

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
      command='gofiles';;
    'py')
      comment='#'
      command='pyfiles';;
    *)
    echo unsupported language \"$1\" && return 1;;
  esac
  for name in `$command`; do
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
      gf "$1" | xargs sed "s/$1/$2/g";;
    3)
      ([ "$1" == "-i" ] && gf "$2" | xargs sed -i "s/$2/$3/g" && return 0) || eval "$fail";;
    *) eval "$fail";;
  esac
}

gf() {
  local dir="$PWD"
  [[ "$1" == "-d" ]] && local dir="$2" && shift 2
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

trans() {
  local rate=()
  for arg in "$@"; do
    case "$1" in
      '-h'|'--help'|'help'|'') 
        printf "%s is a video transcoder\nusage: %s [flag] VIDEO_FILES...\n\t-h, --help\tprint this message\n\t-r, --rate\tframerate of output videos\n" "${0##*/}" "${0##*/}"
        return 0
        ;;
      '-r'|'--rate'|'rate') 
        if [ -z "$2" ]; then
          echo "${0##*/}: -r flag requires a frame rate value" >&2
          return 1
        fi
        rate=(-r "$2")
        shift 2
        ;;
      *) break;;
    esac
  done

  [ "$#" -eq "0" ] && echo "${0##*/}: no input path(s) specified" >&2 && return 1
  
  for name in "$@"; do
    [ ! -f "$name" ] && echo "${0##*/}: '$name' is not a valid file" >&2 && continue

    local ext="${name##*.}"
    local base="${name%.*}"  # Simpler than sed
    local new="$(namespacer "${base}.mp4")"  # Added dot before mp4
    
    echo "Transcoding: $(basename "$name")"
    if ! SVT_LOG=0 ffmpeg -hide_banner -loglevel error -stats -i "$name" -c:v libsvtav1 "${rate[@]}" -crf 20 -preset 2 "$new"; then
      rm -f "$new"
      echo "${0##*/}: transcoding failed for '$name'" >&2
      return 1
    fi
    
    local orig_size=$(du -b "$name" | cut -f1)
    local new_size=$(du -b "$new" | cut -f1)
    
    if [ "$new_size" -lt "$orig_size" ]; then
      rm "$name" && echo "✔ Kept transcoded file (saved $(( (orig_size - new_size) / 1024 )) KB)"
    else
      rm "$new" && echo "✗ Kept original ($orig_size bytes) file because transcoded ($new_size bytes) was larger"
    fi
  done
}

tunes() {
  for dir in "$@"; do
    eval "ls $dir/**.($MUSIC_FORMATS)" | tr '\n' '\0' | xargs -0I{} echo {}
  done
}

play() {
  local verbose
  if [ "$1" = "v" ] || [ "$1" = "-v" ]; then
    verbose="-v"
    shift 1
  fi
  if [[ "0" == "$#" ]]; then
    local dirs="$(echo "$PLAYPATH" | tr ':' ' ')"
    local files=()
    while IFS= read -r -d '' file; do
      files+=("$file")
    done < <(find ${=dirs} -type f \( -name "*.flac" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.ogg" -o -name "*.opus" -o -name "*.wav" -o -name "*.aif" \) -print0 | shuf -z)
    # Single mpv instance with shuffle
    mpv $verbose --no-resume-playback --no-audio-display --shuffle "${files[@]}"
    return
  fi
  
  if [[ "-l" == "$1" ]]; then
    shift
    exts **
    return
  fi

  local shuffle
  if [ "-s" = "$1" ] || [ "s" = "$1" ]; then
    shuffle="--shuffle"
  fi
  # For arguments, shuffle them and play in single instance
  local args=("$@")
  mpv $verbose --no-resume-playback --no-audio-display $shuffle "${args[@]}"
}

sshplay() {
    # local ssh_host="$USER@$(ip addr show | awk '/^\s+inet\s/{print $2}' | tail -1)"  # CHANGE THIS
    local ssh_host="hp17"  # CHANGE THIS
    local verbose=""
    local shuffle=true
    
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            v|-v)
                verbose="-v"
                shift
                ;;
            -s|--shuffle)
                shuffle=true
                shift
                ;;
            -n|--no-shuffle)
                shuffle=false
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Build find command based on your original logic
    local find_cmd='find $(echo "$PLAYPATH" | tr ":" " ") -type f \( -name "*.flac" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.ogg" -o -name "*.opus" -o -name "*.wav" -o -name "*.aif" \)'
    
    if [ "$shuffle" = true ]; then
        find_cmd="$find_cmd | shuf"
    fi
    
    # Stream files over SSH
    ssh "$ssh_host" "$find_cmd" | while read -r file; do
        if [ -n "$file" ]; then
            echo "Streaming: $file"
            ssh "$ssh_host" "cat '$file'" | mpv $verbose --no-resume-playback --no-audio-display -
        fi
    done
}

sample() {
  [ "$1" = "-h" ] && echo "usage: $0 [dir/path - default .] [duration_in_seconds - default 180]" >/dev/stderr && return 0
  local preview path secs target response fileMode;
  [ "$1" = "-p" ] && preview=true && shift
  path="$(pwd)"
  secs=180
  [ "$#" = "2" ] && path="$1" && secs="$2"
  [ "$#" = "1" ] && path="$1"
  [ "$path" = ".." ] && path="$(dirname "$(pwd)")"
  [ "$path" = "." ] && path="$(pwd)"
  [ -f "$path" ] && fileMode=true
  target="$(namespacer ~/Music/samples/$(basename "$path").flac)"
  if [ -n "$preview" ]; then
    [ -d "$path" ] && find "$path" -type f -print0 | xargs -0 cat | sort | aplay >&2 /dev/null
    [ -f "$path" ] && cat "$path" | sort | aplay >&2 /dev/null
  else
    printf 'sampling %s into %s for %s seconds [Y/n] ' "$path" "$target" "$secs"
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS]|"")
        [ -d "$path" ] && find "$path" -type f -print0 | xargs -0 cat | sort | head -c $((8000 * $secs)) | flac - -s -f --endian=little --sign=unsigned --channels=1 --bps=8 --sample-rate=8000 -o "$target" >/dev/null
        [ -f "$path" ] && cat "$path" | sort | head -c $((8000 * $secs)) | flac - -s -f --endian=little --sign=unsigned --channels=1 --bps=8 --sample-rate=8000 -o "$target" >/dev/null;;
      *) return;;
    esac
  fi
}

symlinkDialogue() {
    local source="$1"
    local target="$2"
    local sudo
    [ -x "$(which sudo)" ] && sudo="$(which sudo)"
    if [ ! -e "$target" ]; then
        $sudo ln -s "$source" "$target" && printf 'linked %s -> %s\n' "$source" "$target"
        return $?
    fi
    
    if [ -L "$target" ]; then
        local current_link
        current_link="$(readlink "$target")"
        if [ "$current_link" = "$source" ]; then
            echo "Symlink already correct: $target -> $source"
            return 0
        fi
    fi
    
    # Handle existing file/symlink that needs updating
    echo "Conflict: $target already exists" >&2
    if [ -L "$target" ]; then
        echo "  Current symlink: $target -> $current_link" >&2
    fi
    echo "  Desired symlink: $target -> $source" >&2
    
    printf "Overwrite? [y/N] "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            $sudo ln -sf "$source" "$target" && echo "Updated: $target -> $source"
            return $?
            ;;
        *)
            echo "Skipped: $target"
            return 1
            ;;
    esac
}

gg() {
  (( $# )) || { echo "usage: gg pat1 [pat2..]" >&2; return 1 }

  # First arg seeds the file list
  local files
  files=(${(f)"$(rg -l "$1")"})
  shift

  for pat in "$@"; do
    files=(${(f)"$(rg -l "$pat" -- $files)"})
  done

  printf "%s\n" $files
}

goclean() {
  # Clean go's caches and re-fetch dependencies
  local origin="$(pwd)"
  ([ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "log" ] || [ "$1" = "--log" ]) && du -sh "$HOME/(.|)*" 2> /dev/null | sort -h 
  go clean -x -{test,fuzz,mod}cache
  for name in $CLONES/$USER/*; do
    echo "$name"
    [ -f "$name/go.mod" ] && cd "$name" && go mod tidy;
    echo
  done
  ([ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "log" ] || [ "$1" = "--log" ]) && du -sh "$HOME/(.|)*" 2> /dev/null | sort -h 
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
  notify-send -t 60000 "$msg" 
  echo $msg
}

kff() {
  ps -ef | grep '[f]irefox' | awk '{print $2}' | xargs -I{} kill -9 {}
}

