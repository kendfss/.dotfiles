# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html
autoload -Uz add-zsh-hook

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

ext() {
  local arg
  for arg in "$@"; do
    [ ! -f "$arg" ] && continue
    { local base="$(basename "$arg")" && local ext="${base##*.}"; } || return $?
    [ "$ext" = "$base" ] && continue
    echo "$ext"
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
    for (( arg = 0; i < length; i++ )); do
        local c="${1:$arg:1}"
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
  local lines="$(command clone "$@")"
  local dir="$(echo "$lines" | tail -n1)"
  [ $(echo "$lines" | wc -l) -gt 1 ] && echo "$lines"
  [ -d "$dir" ] && cd "$dir"
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


commit() {
  local msg="$*"
  git commit -m "$msg"
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

cds () {
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
  shift
  $cmd $* &>/dev/null &
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
  cat ~/self.notes/notes | fzf
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
  cat ~/self.notes/notes | fzf
}

stars() {
  gh api user/starred --template '{{range .}}{{.full_name|color "yellow"}}{{"\n"}}{{end}}'
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

fl() {
  local pids="$(pgrep FL64\.exe)"
  [ -n "$pids" ] && echo "$pids" | xargs -I{} kill -9 {} && { [ -z "$1" ] && return; }
  case "$1" in
    '-r'|'--reload'|'r'|'reload') shift 1;;
    '-k'|'--kill'|'k'|'kill') return;;
    *);;
  esac
  quietly wine ~/.wine/drive_c/Program\ Files/Image-Line/FL\ Studio*/FL64.exe #$* #&> /dev/null
}

gitpop() {
  quietly firefox `git remote -v | head -n 1 | cut -d@ -f2 | cut -d" " -f1`
}

cph() {
  $* -h &> /dev/stdout | c
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
  cd .. && command rm -r "$pth"
}

nukef() {
  local pth="`pwd`"
  cd .. && command rm -rf "$pth"
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



tunes() {
  for dir in "$@"; do
    eval "ls $dir/**.($MUSIC_FORMATS)" | tr '\n' '\0' | xargs -0I{} echo {}
  done
}




gfg() {
  (( $# )) || { echo "usage: $0 pat1 [pat2..]" >&2; return 1; }
  # First arg seeds the file list
  local files
  files=(${(f)"$(rg -l "$1")"})
  shift
  for pat in "$@"; do
    files=(${(f)"$(rg -l "$pat" -- $files)"})
  done
  printf "%s\n" $files
}

gg() {
  [ $# -gt 1 ] || { echo "usage: <command> | $0 arg1 arg2 [... argN]"; return 1; }
  local lines="$(cat)"
  for arg in "$@"; do
    lines="$(echo "$lines" | rg "$arg")"
  done
  echo "$lines"
}

goclean() {
  # Clean go's caches and re-fetch dependencies
  local origin="$(pwd)"
  ([ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "log" ] || [ "$1" = "--log" ]) && du -sh "$HOME/(.|)*" 2> /dev/null | sort -h 
  go clean -x -{test,fuzz,mod}cache
  for name in $CLONES/$USER/**/go.mod; do
    local dir="$(dirname "$name")"
    echo "$dir" && cd "$dir" && go mod tidy;
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

xq() {
  for arg in "$@"; do
    xbps query -Rs $arg | rg "$(printf '] (\w+(-)?)*%s((-)?\w+)*-' "$arg")" | rg "$arg"
  done
}

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

lines() {
  local files=()
  local dirs=()
  for arg in "$@"; do
    [ -L "$arg" ] && arg="$(realpath "$arg")"
    if [ -f "$arg" ]; then
      files+=("$arg")
      continue
    fi
    if [ -d "$arg" ]; then
      dirs+=("$arg")
      continue
    fi
    printf "'%s' is not a file or directory\n" "$arg" >&2
    return 1
  done
  if [ ${#dirs[@]} -eq 0 -a ${#files[@]} -eq 0 ]; then
    dirs=("$(pwd)")
  fi
  for dir in "${dirs[@]}"; do
    for name in "$dir"/{.?,}*; do
      [ -f "$name" ] && files+=("$name")
    done
  done
  files=("${(@fu)files}")  # (f) use newline as separator, (u) unique
  for file in "${files[@]}"; do
    printf "%s: %'d lines\n" "$file" "$(wc -l < "$file")"
  done
}


gmt() {
  go mod tidy
}

gmi() {
  go mod init "$REPO_HOST/$USER/$(basename "$(pwd)")"
}

grab() {
  for arg in "$@"; do
    local name="$(namespacer "$(basename "$(echo "$arg" | cut -d'?' -f1)")")"
    curl "$arg" -o "$name" 2>/dev/null && echo "$name"
  done
}

clean() {
  local blob="$1"
  shift
  if (( $# & 1 != 1 )); then
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
    	du -sh "$name"/{.?,}* 2> /dev/null | sort -h
    done
    return $?
	}
	du -sh {.?,}* 2> /dev/null | sort -h
}

