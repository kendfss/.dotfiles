# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html
autoload -Uz add-zsh-hook

# goc() {
#   local change_dir=''
#   local all=''
#   local case=''
#   local cmd=''
#   local http=''
#   local short=''
#   local source=''
#   local unexported=''
#   while [ $# -gt 0 ]; do
#     case "$1" in
#       '') go doc -u | bat -Pplgo --theme ansi; return $?;;
#       '-C'|'--change-dir') shift && change_dir="-C $1" && shift && continue;;
#       '-a'|'-all'|'--all') all='-all' && shift && continue;;
#       '-cmd'|'--cmd') cmd='-cmd' && shift && continue;;
#       '-c'|'--case') case='-c' && shift && continue;;
#       '-http'|'--http') http='-http' && shift && continue;;
#       '-short'|'--short') short='-short' && shift && continue;;
#       '-s'|'-src'|'--src') source='-src' && shift && continue;;
#       '-u'|'--unexported') unexported='-u' && shift && continue;;
#       --*) echo "unrecognized flag: $1" >&2; return 1;;
#       -*)
#         local found=false
#         local arg="${1//-/}"
#         [[ "$arg" == *"a"* ]] && all='-all' && found=true && arg="${arg//a/}"
#         [[ "$arg" == *"c"* ]] && case='-c' && found=true && arg="${arg//c/}"
#         [[ "$arg" == *"u"* ]] && unexported='-u' && found=true && arg="${arg//u/}"
#         [[ "$arg" == *"s"* ]] && source='-src' && found=true && arg="${arg//s/}"
#         ([ -z "$arg" ] && [ $found = true ]) && shift && continue
#         echo "unrecognized flag(s): $arg" >&2
#         return 1
#         ;;
#       *) break;;
#     esac
#   done
#   local count=0
#   local head=""
#   local arg
#   for arg in "$@"; do
#     local blob="$(go doc $change_dir $all $case $cmd $http $short $source $unexported "$arg")"
#     local blob_head="$(printf '%s\n' "$blob" | sed -n 1p)"
#     if [[ "$blob_head" != "$head" ]]; then
#       head="$(printf "%s" "$blob_head")"
#       [ "$count" -ne 0 ] && blob="$(printf "\n%s" "$blob")"
#       count=0
#     else
#       local blob_length="$(printf '%s\n' "$blob" | wc -l)"
#       if [ $count -gt 0 -a $((blob_length)) -gt 1 ]; then
#         blob="$(printf '%s\n' "$blob" | sed 1d)"
#       fi
#     fi
#     printf '%s\n' "$blob" | bat -lgo --theme ansi
#     ((count++))
#   done
# }

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

twb() {
  if [ -d "$TERMUX__PREFIX" ]; then
    termux-clipboard-get | tmux load-buffer -
  else
    xclip -i -selection clipboard | tmux load-buffer -
  fi
}

take() {
  # Make a directory and cd into it
  local mkdir="$(command -v mkdir)"
  local code=$?
  [ -z "$mkdir" ] && echo "couldn't find mkdir" >&2 && return $code
  for arg in "$@"; do
    $mkdir -p $1 && cd $1
  done
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
  # setopt shwordsplit
  setopt localoptions shwordsplit
 
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
  local all=false
  { [ "$1" = '-a' ] || [ "$1" = '--all' ]; } && all=true
  if [ -n "$TMUX" ] && [ $all = true ]; then
    local session=$(tmux display-message -p '#S')
    while IFS= read -r pane; do
      local pid=$(tmux display-message -t "$pane" -p '#{pane_pid}')
      local child_cmd=$(ps -o cmd= $(ps --ppid "$pid" -o pid= 2>/dev/null) 2>/dev/null)
      if ! echo "$child_cmd" | grep -qiE 'weechat|hx|less|man|more|fzf|sk|vim|nano|yt-dlp|gallery-dl|youtube-dl|cleanup|dupes'; then
        tmux send-keys -t "$pane" -l 'exec $SHELL -l'
        tmux send-keys -t "$pane" Enter
        tmux send-keys -t "$pane" C-l
      fi
    done < <(tmux list-panes -t "$session" -a -F '#{session_name}:#{window_index}.#{pane_index}')
    return
  fi
  exec $SHELL -l
}

focus() {
  local args=()
  local panes=false
  local windows=false
  local sessions=false
  local dry=false
  local eliminate_current=false
  for arg in "$@"; do 
    case "$arg" in
      '--panes') panes=true;;
      '--windows') windows=true;;
      '--sessions') sessions=true;;
      '--dry-run') dry=true;;
      '--eliminate-current') eliminate_current=true;;
      --*) echo "unrecognized flag: $arg" >&2; return 1;;
      -*)
        local found=false
        arg="${arg//-/}"
        [[ "$arg" == *"p"* ]] && panes=true             && found=true && arg="${arg//p/}"
        [[ "$arg" == *"w"* ]] && windows=true           && found=true && arg="${arg//w/}"
        [[ "$arg" == *"s"* ]] && sessions=true          && found=true && arg="${arg//s/}"
        [[ "$arg" == *"d"* ]] && dry=true               && found=true && arg="${arg//d/}"
        [[ "$arg" == *"e"* ]] && eliminate_current=true && found=true && arg="${arg//e/}"
        ([ -z "$arg" ] && [ $found = true ]) && continue
        echo "unrecognized flag(s): $arg" >&2
        return 1
        ;;
      *) args+=("$arg");;
    esac
  done
  local count=0
  local keyword=""
  local format=""
  [ $panes = true ]    && keyword=pane    && format='#P'              && ((count++)) 
  [ $windows = true ]  && keyword=window  && format='#{window_index}' && ((count++)) 
  [ $sessions = true ] && keyword=session && format='#S'              && ((count++)) 
  [ $count -ne 1 ]     && echo "must choose ONE of  --panes (-p), --windows (-w), or --sessions (-s)" >&2 && return 1
  local current="$(tmux display-message -p "$format")"
  if [ $eliminate_current = false ]; then
    args+=("$current")
  fi
  local list="$(tmux list-"${keyword}s" | awk -F: '{print $1}')"
  [ -n "$list" ] || { echo "couldn't find ${keyword}s" >&2; return 1; }
  for item in "${args[@]}"; do
    list="$(echo "$list" | grep -v "^$item$")"
  done
  printf "current $keyword is: $current\nthis would close: %s\n" "$(echo "${=list}" | sed 's/[[:space:]]/, /g')"
  if [ $dry = false ]; then
    printf "sure? [Y|n]: "  
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS]|'') echo "$list" | xargs -I{} tmux kill-$keyword -t {}; return $?;;
      *) return;;
    esac
  fi
}

bckp() {
  local force=false
  [ "$1" = "-f" -o "$1" = "--force" ] && force=true && shift
  local origin=$(pwd)
  local old=$1
  if [[ -z "$old" ]]; then
    old="../$(basename "$(pwd)")"
  fi
  local new="$old-$0"
  if [ $force = false ]; then
    [ -e "$new" ] && echo "already exists" >&2 && return 1
  else
    [ -f "$new" ] && rm -f "$new"
    [ -d "$new" ] && rm -rf "$new"
  fi
  [[ -d "$old" ]] && cp -rf "$old/" "$new" && cd "$origin" && echo "backed up $old to $new"
  [[ -f "$old" ]] && cp "$old" "$new" && cd "$origin" && echo "backed up $old to $new"
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
  local depth="--depth=1"
  local dev=""
  if [[ "$1" == "-d" ]]; then
    depth=""
    shift 1
  fi
  [ $# -eq 0 ] && echo no args received && return 1
  if [[ $1 != *"/"* ]]; then
    dev="$1"
    shift 1
  fi
  if [ $# -eq 0 ]; then
    argv=("$dev")
    dev="$USER"
  fi
  for repo in "$@"; do
    if [[ $repo == *"/"* ]]; then
      dev=$(basename "$(dirname "$repo")")
    fi
    repo=$(basename "$repo")
    local pth="$CLONEDIR/$dev/$repo"
    [ -d "$pth" ] && echo "already have '$dev/$repo'" >&2 && cd "$pth" && continue
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
    return 
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

acp() {
  [ "$1" = '-' ] && { { add && commit "$(p)" && push && return; } || { echo "failed: $?" && return 1; }; }
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
    if [ -f "$name" ]; then
      openssl dgst -sha256 -r "$name" | cut -d" " -f1
      continue
    fi
    echo "$name" |  openssl dgst -sha256 -r | cut -d" " -f1
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
  shift
  $cmd $* &>/dev/null &
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
  setopt localoptions no_nomatch # ignore empty glob results
  $EDITOR {$DOTDIR,$DOTDIR/helix}/{.*(conf|fig|ore|env|rc|file|toml|lua),*.(zsh|toml)} 2> /dev/null
  # unsetopt no_nomatch
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



tunes() {
  for dir in "$@"; do
    eval "ls $dir/**.($MUSIC_FORMATS)" | tr '\n' '\0' | xargs -0I{} echo {}
  done
}

play() {
    local verbose
    local shuffle
    local dirs=()
    local files=()
    local list=false
    local count=false
    
    while [ $# -gt 0 ]; do
        local arg="$1"
        case "$arg" in
            '-v'|'--verbose') verbose='-v' && shift ;;
            '-s'|'--shuffle') shuffle='--shuffle' && shift ;;
            '-c'|'--count') count=true && shift ;;
            '-l'|'--list') list=true && shift ;;
            *.(wav|mp3|flac|aac|m4a|ogg|opus|aiff|aif)) 
                files+=("$(realpath "$arg")") && shift ;;
            *) dirs+=("$(realpath "$arg")") && shift ;;
        esac
    done
    
    [[ $list == true ]] && exts ** && return
    
    if [ 0 = ${#files[@]} ] && [ 0 = ${#dirs[@]} ]; then
        dirs=(${(@s;:;)PLAYPATH})
    fi
    
    for dir in "${dirs[@]}"; do
        dir="$(realpath "$dir")"
        # Single find command for all files recursively
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$dir" -type f \( -iname "*.flac" -o -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.wav" -o -iname "*.aif" -o -iname "*.aiff" \) -print0 2>/dev/null)
    done
    
    [[ $count == true ]] && echo ${#files[@]} && return
    [ ${#files[@]} -eq 0 ] && echo no files found >&2 && return 1
    
    mpv $verbose --no-resume-playback --no-audio-display $shuffle -- "${files[@]}"
}

sample() {
  [ "$1" = "-h" ] && echo "usage: $0 [dir/path - default .] [duration_in_seconds - default 180]" >&2 && return 0
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
  sk -em --preview 'bat -p {}'
}

# changes() {
#   local outFile="$(date +'%Y%M%e-%T').changes"
#   local cached=''
#   local files=( )
#   while [ $# -gt 0 ]; do
#     case "$1" in
#       -c|--cached) cached='--cached'; shift;;
#       -o|--output) shift; outFile="$1"; shift;;
#       *)
#         if [ -f "$1" ]; then
#           files+=("$1")
#           shift
#         else
#           echo "'$1' isn't a file name or valid flag"
#           return 1
#         fi;;
#     esac
#   done
#   local msg="$(printf "describe the changes below, in a single line, using the following syntax 'add: blah; fix: blah, blah; rm: blah; update: blah, blah, blah; ...;'\nalways end output with a semicolon. when there are multiple changes, of the same type (ie add|fix|etc), to a block|function|script|etc put those changes in parentheses and put that block/function/script/file name before those parentheses (ie: fix: funcX(blah, blah), fileX(blah, blah, blah); update: funcY blah, fileY(blah, blah blah); etc: ...;). when stating dependencies just say the name and developer - omit the repository host (ie github.com/kendfss/but -> kendfss/but; golang.org/x/net -> x/net). never include indirect dependencies (dependencies of dependencies) unless they have been updated\ninstead of giving each micro-detail: where possible, try to organize changes into cohesive units/features/fixes but don't consolidate modifications of different types like additions and fixes to the same file/scope\nwith regard to types, adhere to the following conventions: add->new functionality added to a function/file/class. fix->correcting bugs in the code/spelling. rm->removals of functions/types/data. update->elaborations/removals of natural language (ie comments/documentation)\nif you find that other types are necessary include them at will but explain them in (a) separate paragraph(s)%s\n" "$(git diff $cached $files)")"
#   echo "$msg" | c
#   echo "$msg" | delta
# }

review() {
  local maxdepth="-maxdepth 1"
  local exts=()
  while [ $# -gt 0 ]; do
    case "$1" in
      -w|--walk) maxdepth="" && shift && continue;;
      -*) echo "unrecognized flag: $1" >&2 && return 1;;
      *) exts+=("$1") && shift && continue;;
    esac
  done
  [ $# -eq 0 ] && exts+=("go")
  echo "review the following files for bugs, simplifications, and architectural/dependency improvements:"
  for ext in "${exts[@]}"; do
    find . -type f -iname "*.$ext" ${=maxdepth} 2>/dev/null | while read -r file; do
      echo "// $file"
      cat "$file"
      echo
    done
  done
}

writeme() {
  local maxdepth="-maxdepth 1"
  local exts=()
  local name=false
  while [ $# -gt 0 ]; do
    case "$1" in
      -w|--walk) maxdepth="" && shift && continue;;
      -n|--name) name=true && shift && continue;;
      -*) echo "unrecognized flag: $1" >&2 && return 1;;
      *) exts+=("$1") && shift && continue;;
    esac
  done
  [ $# -eq 0 ] && exts+=("go")
  if [ false = "$name" ]; then
    echo "write a readme for the following code. the project is called '$(basename "$(pwd)")', unless you can think of a better name"
  else
    echo "write a readme for the following code. the project doens't have a name yet, please recommend some"  
  fi
  for ext in "${exts[@]}"; do
    find . -type f -iname "*.$ext" ${=maxdepth} 2>/dev/null | while read -r file; do
      echo "// $file"
      cat "$file"
      echo
    done
  done
}

xq() {
  for arg in "$@"; do
    xbps query -Rs $arg | rg "$(printf '] (\w+(-)?)*%s((-)?\w+)*-' "$arg")" | rg "$arg"
  done
}

xqi() {
  for arg in "$@"; do
    xbps query -Rs $arg | rg "$(printf '\*] (\w+(-)?)*%s((-)?\w+)*-' "$arg")"
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

tag() {
  local artist=''
  local album=''
  local title=''
  local year=''
  local files=()
  while [ $# -gt 0 ]; do
    case "$1" in
      '-a'|'--artist') shift && artist="-metadata artist='$1'" && shift && continue;;
      '-l'|'--album') shift && album="-metadata album='$1'" && shift && continue;;
      '-t'|'--title') shift && title="-metadata title='$1'" && shift && continue;;
      '-y'|'--year') shift && year="-metadata year='$1'" && shift && continue;;
      -*) echo "unrecognized flag: $1" >&2 && return 1;;
      *)
        [ -f "$1" ] && files+=("$1") && shift && continue
        echo "file not found: $1" >&2 && return 1;;
    esac
  done
  if [ -n "$title" -a ${#files[@]} -gt 1 ]; then
    printf "setting title of more than one file to %s. sure? [yN] " "$title"
    read -r response
    case "${=response}" in
      [yY]|[yY][eE][sS]) :;;
      *) return 0;;
    esac
  fi
  for file in "${files[@]}"; do
    local temp="$(mktemp)"
    ffmpeg -i "$file" $artist $album $title $year -codec copy "$temp" || return $?
    mv "$temp" "$file" || { local code=$? && echo "failed cleanup: $file" >&2 && return $code; }
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

save() {
  local dir=$(mktemp -d)
  echo "dir: $dir" >&2
  for name in "$@"; do
    mv -- "$name" "$dir/"
  done
  local items="$(ls -1)"
  if [ -z "$items" ]; then
    echo "No items to delete. Restoring..." >&2
    find "$dir" -maxdepth 1 -mindepth 1 -exec mv {} . \; && rm -rf "$dir"
    return $?
	fi
  printf "would delete:\n%s\n" "$items"
  printf "[yN]: "
  read -r resp
  case "$resp" in
    (y | Y | yes | Yes) echo "$items" | while IFS= read -r name; do
          [ -d "$name" ] && rm -rf -- "$name" || rm -f -- "$name"
        done ;;
		(*) echo "Cancelled. Restoring items..." >&2
      find "$dir" -maxdepth 1 -mindepth 1 -exec mv {} . \; && rm -rf "$dir"
      return $? ;;
  esac
  find "$dir" -maxdepth 1 -mindepth 1 -exec mv {} . \;
  rm -rf "$dir"
  return $?
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

get() {
  local arg
  for arg in "$@"; do
    local name="$(echo "$arg" | sed 's/\?.+//g' | to basename)"
    wget "$arg" -O "$name" 1>/dev/null && echo "$arg" @ "$name"
  done
}
