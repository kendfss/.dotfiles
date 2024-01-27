# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html
autoload -Uz add-zsh-hook

exts() {
  # print file extensions
    dir=$1
    shift 1 > /dev/null

    if (( $# )); then
        dir="$@"
    else
        dir=$(pwd)
    fi

    files=$(ls -1 $dir)
    extensions=()

    for file in $files; do
        extension=${file##*.}
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


# Make a directory and cd into it
take() {
  mkdir -p $1
	cd $1
}

cv2() {
  cmd=$1
  shift
  $(command -v $cmd) $*
}


cv1() {
  for arg in "$@"; do
    command -v $arg
  done
}


# intellegently extract archives based on extension. 
function extract {
  file=$1
  shift
  dir=$1

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
             cmd="tar xjvf \"$file\" $dc" 
             echo $cmd
             eval ${cmd}
             ;;   

         *.tar.gz)    
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar xzvf \"$file\" $dc"; 
             echo $cmd;
             eval ${cmd}
             ;;

         *.tar)       
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar vxf \"$file\" $dc";
             echo $cmd;
             eval ${cmd}
             ;;

         *.tbz2)      
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar xjvf \"$file\" $dc";
             echo $cmd; 
             eval ${cmd}
             ;;  

         *.tgz) 
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar xzf \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd} 
             ;;    

         *.bz2)       
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar jf \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd} 
             ;;     

         *.zip)       
             if [[ -n $dir ]]; then dc="-d $dir"; fi
             cmd="unzip \"$file\" $dc"; 
             echo $cmd; 
             eval ${cmd}
             ;;

         *.gz)
             if [[ -n $dir ]]; then dc="-C $dir"; fi
             cmd="tar zf \"$file\" \"$dc\""; 
             echo $cmd; 
             eval ${cmd}
             ;;

         *.7z)        
             #TODO dir
             cmd="7z x -o \"$dir\" \"$file\""; 
             echo $cmd; 
             eval ${cmd} 
             ;;

         *.rar)       
             #TODO Dir
             cmd="unrar x \"$file\" \"$dir\"";
             echo $cmd;
             eval ${cmd}
             ;;
         *)           
            echo "'$file' cannot be extracted via extract()" 
            ;;
         esac
   fi
}
 
 
# web_search from terminal
function web_search() {
  emulate -L zsh
 
  # define search engine URLS
  typeset -A urls
  urls=(
    google      "https://www.google.com/search?q="
    ddg         "https://www.duckduckgo.com/?q="
    github      "https://github.com/search?q="
  )
 
  # check whether the search engine is supported
  if [[ -z "$urls[$1]" ]]; then
    echo "Search engine $1 not supported."
    return 1
  fi
 
  # search or go to main page depending on number of arguments passed
  if [[ $# -gt 1 ]]; then
    # build search url:
    # join arguments passed with '+', then append to search engine URL
    url="${urls[$1]}${(j:+:)@[2,-1]}"
  else
    # build main page url:
    # split by '/', then rejoin protocol (1) and domain (2) parts with '//'
    url="${(j://:)${(s:/:)urls[$1]}[1,2]}"
  fi
 
  open_command "$url"
}
 
#use generalized open command
function open_command() {
  emulate -L zsh
  setopt shwordsplit
 
  local open_cmd
 
  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   open_cmd='xdg-open' ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac
 
  # don't use nohup on OSX
  if [[ "$OSTYPE" == darwin* ]]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}
 
# Show dots while waiting for tab-completion
expand-or-complete-with-dots() {
	# toggle line-wrapping off and back on again
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
	print -Pn "%{%F{red}......%f%}"
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam
 
	zle expand-or-complete
	zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots


urlencode() {
    # urlencode <string>

    old_lang=$LANG
    LANG=C
    
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LANG=$old_lang
    LC_COLLATE=$old_lc_collate
}

reload() {
  exec $SHELL
}

bckp() {
  origin=$(pwd)
  old=$1
  if [[ -z "$old" ]]; then
    old="../$(basename "$(pwd)")"
  fi
  new="$old-$0"
  [[ -d $new ]] && echo "already exists" && return 1
  [[ -f $new ]] && echo "already exists" && return 1
  [[ -d $old ]] && cp -rf "$old/" "$new" && cd "$origin" && echo "backed up $old to $new"
  [[ -f $old ]] && cp -rf "$old/" "$new" && cd "$origin" && echo "backed up $old to $new"
}

blank() {
  for i in {1..$1}; do
    echo ""
  done
}

bar() {
  char="*"
  if [[ $2 ]]; then
    char=$2
  fi
  for i in {1..$1}; do
    printf "%s" "$char"
  done
  print ""
}

10print () {
  local RANDOM=$(date +%s)
  declare -a chars
  chars=(\\ /)
  chars=(\# " ")
  for i in {1..$1}; do
    ind=$(($RANDOM % 2))
    printf "%s" "${chars[$(($ind + 1))]}"
  done
  echo ""
}


rename() {
  name=$(base)
  cd .. && mv "$name" "$1" && cd "$1" 
}

tst() {
  # name=tst
  # [[ $2 -eq "" ]] || name=$2_test
  # [[ $1 -eq "" ]] || name+="." && name+=$1
  
  # [[ $1 -eq go ]] && content="package " && [[ $3 -eq "" ]] && content+=$(base) || content+=$3
  # [[ $1 -eq v ]] && content="module " && [[ $3 -eq "" ]] && content+=$(base) || content+=$3

  # echo "$content" > "$name"
  # $EDITOR "$name"
  1=this
  for name in "$@"; do
    echo $name
  done
  echo "$@"
}

surl() {
  for url in "$@"; do
    ssh_url=$(echo "$url" | sed 's/https:\/\/\([^/]*\)\(.*\)\.\(.*\)/git@\1:\2.git/')
    echo "$ssh_url"
  done
}

clone() {
  if [[ $1 != *"/"* ]]; then
    dev=$1
    shift 1
  fi
  for repo in "$@"; do
    if [[ $repo == *"/"* ]]; then
      dev=$(basename "$(dirname "$repo")")
    fi
    repo=$(basename "$repo")

    echo "cloning $dev/$repo"
    take "$CLONEDIR/$dev" && git clone --depth=1 "$REPO_HOST/$dev/$repo" "$repo" && cd "$repo" && 
    # take "$CLONEDIR/$dev" && sudo git clone --depth=1 "$REPO_HOST/$dev/$repo" "$repo" && cd "$repo" && 
  done
}

fork() {
  if [[ $1 != *"/"* ]]; then
    dev=$1
    shift 1
  fi

  for repo in "$@"; do
    if [[ $repo == *"/"* ]]; then
      dev=$(basename "$(dirname "$repo")")
    fi

    repo=$(basename "$repo")
    # echo "cloning $dev/$repo"
    user="$HOME/gitclone/clones/$USER" 
    mkdir -p "$user" && cd "$user" && gh repo fork "$dev/$repo" && cd "$repo" 2> /dev/null
  done
  # dev=$USER
  # repo=$(basename "$1")
  # take "$HOME/gitclone/clones/$dev" && gh repo fork "$1" && cd "$repo" 2> /dev/null
}

padd() {
  printf "\n" >> ~/.zprofile
  for i in "$@"; do
    printf "%s" "$i" >> ~/.zprofile
    printf "\n" >> ~/.zprofile
  done
}

def() {
  fname=~/self.notes/definitions
  term=$1
  shift 1
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$(printf "%s\n\t%s\n%s" "$term" "$*" "$former")
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

function argstudy() {
  # We use "$@" instead of $* to preserve argument-boundary information
  ARGS=$(getopt -o 'a:l::v' --long 'article:,language::,lang::,verbose' -- "$@") || exit
  eval "set -- $ARGS"

  while true; do
      case $1 in
        (-v|--verbose)
              ((VERBOSE++)); shift;;
        (-a|--article)
              ARTICLE=$2; shift 2;;
        (-l|--lang|--language)
              # handle optional: getopt normalizes it into an empty string
              if [ -n "$2" ]; then
                LANG=$2
              fi
              shift 2;;
        (--)  shift; break;;
        (*)   exit 1;;           # error
      esac
  done

  # remaining=("$@")

  [[ -n $VERBOSE ]] && echo "verbose enabled"
  [[ -n $ARTICLE ]] && echo "ARTICLE enabled"
  [[ -n $LANG ]]  && echo "LANG enabled"

  echo "Remainders:"
  echo "$*"
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
  # [[ ${#argv[@]} -gt 0 ]] && echo "using \"$1\" extension. will exit with 1" && touch "api/core.$1" && return 1
  echo "using \"$1\" extension. will exit with 1" && touch "api/core.$1" && return 1
}

add() {
  git add "$@"
}

commit() {
  git commit -m "$@"
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
  for path in "$@"; do
    shopt -s nullglob nocaseglob
    files=("$path"*)
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
  $EDITOR "$ZDOTDIR"
}

startover() {
  name="$(pwd)"
  readme=$(cat readme.md)
  discontinue
  mkdir -p "$name" && cd "$name" || return 1
  echo "$readme" > README.md
  create "$1"
  $EDITOR .
}

discontinue() {
  if [[ -z "$@" ]]; then
    name="$(basename $PWD)"
    gh repo delete "$USER/$name" --yes && cd .. && rm -rf "$name"
  else
    for arg in "$@"; do
      name="$(basename $arg)"
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
  here=$(pwd)
  name=$(base)
  dest=$1/$name
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
  for name in "$@"; do
    openssl dgst -sha256 "$name" | cut -d " " -f2
  done
}

rl() {
  for arg in "$@"; do
    readlink "$(command -v "$arg")"
  done
}

# md() {
#   for name in "$@"; do
#     mkdir -p "$name"
#   done
# }

dirof() {
  for name in "$@"; do
    dirname "$(command -v "$name")"
  done
}

zdot() {
  $EDITOR $DOTFILES/(.*(conf|fig|ore|env|rc|file)|*.zsh)
}

here() {
  # $EDITOR "$(pwd)"
  dirname `readlink -f $0`
}

titles() {
  fname=~/self.notes/track_titles
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$*"\n"$former
  echo "$extended" > "$fname"
}

keep() {
  fname=$(pwd)/keeps.md
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$*"\n"$former
  echo "$extended" > "$fname"
}

if [[ $(uname) -eq Linux ]]; then
  open() {
    xdg-open $* > /dev/null
  }
fi

fname() {
  for fullpath in "$@"; do
    filename="${fullpath##*/}"                      # Strip longest match of */ from start
    base="${filename%.[^.]*}"                       # Strip shortest match of . plus at least one non-dot char from end
    ext="${filename:${#base} + 1}"                  # Substring from len of base thru end
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
  cmd=$1
  shift 1
  $cmd $* &> /dev/null &
}

stdout() {
  cmd=$1
  shift 1
  $cmd $* &> /dev/stdout | less
}

note() {
  fname=~/self.notes/notes
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$*"\n"$former
  echo "$extended" > "$fname"
}

notes() {
  $EDITOR ~/self.notes/notes
}

cnotes() {
  less < ~/self.notes/notes
}

etch() {
  fname="$HOME/self.notes/$*.md"
  name=$(echo "$fname" | sed "s/ /_/g")
  [[ ! -f "$fname" ]] && printf "%s\n---\n" "$*" > "$fname"
  $EDITOR -n "$fname"
}

yd() {
  folder=$1
  url=$3
  rgs=$2
  origin=$(pwd)

  # echo "yt-dlp $rgs $url"
  [[ ! -d "$folder" ]] && mkdir -p "$folder" 
  cd "$folder" || (echo "couldn't get into $folder" && return 1)

  yt-dlp $rgs $url && cd "$origin" && return
  echo "download failed for other reasons"
  cd "$origin" 
  return 1
}

y22() {
  rgs="-f22  --no-check-certificates"
  d=$VIDEOS/ytdls
  for url in "$@"; do
    echo "$url"
    yd "$d" "$rgs" "$url" || return 1
    print "\n\n\n"
  done
  # yd "$d" "$rgs" "$*"
}

yda() {
  rgs="-x"
  d=$MUSIC/ytdls
  for url in "$@"; do
    echo "$url"
    yd "$d" "$rgs" "$url" || return 1
    print "\n\n\n"
  done
  # yd "$d" "$rgs" "$*"
}

ydl() {
  rgs=""
  d=$VIDEOS/ytdls
  for url in "$@"; do
    echo "$url"
    yd "$d" "$rgs" "$url" || return 1
    print "\n\n\n"
  done
  # yd "$d" "$rgs" "$*"
}

post() {
  name=$*
  name=$(replace " " "_" "$name")
  dname="$POSTS/$name"
  
  [[ -d $dname ]] && cd $dname && $EDITOR $dname && return
  take $dname
  fname="$dname/$name.md"
  [[ ! -d $dname ]] && mkdir -p "$dname"
  $EDITOR "$dname"
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$*"\n===\n"$former
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
  oldHome=$JAVA_HOME
  JAVA_HOME=/usr/local/jdk-17.0.4+8 /home/kendfss/gitclone/clones/processing/processing4/build/linux/work/processing-java $*
  JAVA_HOME=$oldHome
}

processing() {
  oldHome=$JAVA_HOME
  JAVA_HOME=/usr/local/jdk-17.0.4+8 /home/kendfss/gitclone/clones/processing/processing4/build/linux/work/processing $*
  JAVA_HOME=$oldHome
}

transopts() {
  trans -R
}

frep() {
  root=$1
  patt=$2
  [[ -z $3 ]] && grep -irl "$patt" "$root" | grep -i "$patt"
  [[ -n $3 ]] && grep -irl "$patt" "$root"
}

procapi() {
  root=/home/kendfss/gitclone/clones/processing/processing-docs
  data=$root/content/api_en
  $EDITOR "$root" && $EDITOR $(frep "$data" "$1")
}

procex() {
  root=/home/kendfss/gitclone/clones/processing/processing-docs
  data=$root/content/examples
  $EDITOR "$root" && $EDITOR $(frep "$data" "$1")
}

progrep() {
  root=/home/kendfss/gitclone/clones/processing/processing-docs
  frep "$root" "$1"
}

name_all() {
  name=$1
  # args=( "${@[@/$1]}" )
  # unset "$@[1]"
  args=( ${@[@]:2} )
  for pth in $args; do 
    mv "$pth" "$(namespacer "$name")"
  done
}

work() {
  fname=~/self.notes/work.md
  [[ -f "$fname" ]] && former=$(cat "$fname") && rm "$fname"
  extended=$*"\n"$former
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
  # sudo
  __plat | column -ts:
}

linkhere() {
  [[ -z "$@" ]] && items="$(p)"
  [[ -n "$@" ]] && items=$@
  # for name in $(p); do
  for name in $items; do
    [[ -f "$name" ]] && ln -f "$name" .
  done
}

# printf "%s\n" "0x4f4c4c" >> colors.txt

# function initpyenv () { 
#   export PYENV_ROOT="$HOME/.pyenv"
#   command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
#   eval "$(pyenv init -)"
#   pyenv global 3.11-dev
# }

east() {
  for arg in "$@"; do
    [[ -f "$arg" ]] && bat "$arg" && printf "end of \"%s\"\n" "$arg"
  done
}

fl() {
  # for arg in "$@"; do
  # quietly wine ~/.wine/drive_c/Program\ Files/Image-Line/FL\ Studio\ 20/FL64.exe $* &> /dev/null
  quietly wine ~/.wine/drive_c/Program\ Files/Image-Line/FL\ Studio\ 21/FL64.exe $* &> /dev/null
  # done
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

tst() {
  for line in "$(apt search mingw | head -n54 | tail -n8 | cut -d" " -f1-4)"; do 
    [[ "$line" == "p"* ]] && echo "line: $line"
  done
}

goup() {
  origin=$(pwd) && echo "$0: origin == $origin"
  groot=$(go env GOROOT) && [[ -z $groot ]] && echo "$0: go root not found" && return 1
  cd "$groot" && echo "cd $groot"
  bckp "$groot" && echo "backup in $groot-bckp"
  # (git stash && git pull && git stash pop) || echo "$0: bad stash or pull" && cd "$origin" && return 1
  git stash
  git pull
  git stash pop
  # echo "$0: bad stash or pull" && cd "$origin" && return 1
  cd "$groot/src" && echo "cd \"$groot/src\""
  export GOROOT_BOOTSTRAP=$groot-bckp
  chmod +x ./make.bash
  ./make.bash
  cd ../bin && sudo ln -f $(pwd)/go /usr/bin/go
  cd "$origin"
  newVer=$($groot/bin/go version)
  echo "$0: old version is $oldVer"
  oldVer=$($GOROOT_BOOTSTRAP/bin/go version)
  echo "$0: new version is $newVer"
  rm -rf $GOROOT_BOOTSTRAP
}

cde() {
  cd $1 && $EDITOR
}

package() {
  name=$1
  shift 1
  for file in "$@"; do
    echo "$0 $name" > "$file"
  done
}

# # $DOTDIR/functions.zh
# cfg() {
#   setopt no_nomatch # ignore empty glob results
#   $EDITOR {$DOTDIR,$DOTDIR/helix}/\{.*\(conf\|fig\|ore\|env\|rc\|file\|toml\),*\.\(zsh\|toml\)\} 2> /dev/null
#   unsetopt no_nomatch
# }

cfg() {
  setopt no_nomatch # ignore empty glob results
  $EDITOR {$DOTDIR,$DOTDIR/helix}/{.*(conf|fig|ore|env|rc|file|toml),*.(zsh|toml)} 2> /dev/null
  unsetopt no_nomatch
}

absmod() {
  if [[ -f go.mod ]]; then
    oldmod=$(cat go.mod)
    echo "$oldmod" > go.mod.tmp
    rm go.mod
    echo "$oldmod" | sed "s/\.\.\/\.\./\/home\/kendfss\/gitclone\/clones/g" go.mod.tmp | sed "s/\.\./\/home\/kendfss\/gitclone\/clones\/kendfss/g" | sed "s/psort/$(base)/g" > go.mod
  fi
}

tst(){
  ARGS=$(getopt -o '' --long 'article:,language::,lang::,verbose' -- "$@") || exit
  eval "set -- $ARGS"
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
  code="$1"
  shift
  text="$*"
  [[ -n "$text" ]] && echo "$text"
  return "$code"
}

rjustify() {
  max_len=$(printf "%s\n" "$@" | awk '{ print length }' | sort -nr | head -n 1)
  for arg in "$@"; do
    printf "%*s\n" "$max_len" "$arg"
  done
}

fetch() {
  local count=0
  for url in "$@"; do
    # echo "Trying to fetch $url..."
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

map(){
  cmd=$1
  shift
  for arg in "$@0"; do 
    $cmd $arg
  done
}

new() {
    name=$(echo "$*" | sed "s/ /_/g")
    pth="$CLONEDIR/$USER/$name"

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
  cmd="$1"
  shift
  sudo `cv "$cmd"` $*
}








