[ -f ~/.secrets ] && source ~/.secrets
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"
PATH="$PATH:$HOME/dartsdk/dart-sdk/bin:$DOTFILES/scripts"
export PLAYPATH="$HOME/Music:$HOME/.local/share/nicotine/downloads:/music:/mnt/Elements/drive:/mnt/Elements/music"
export MUSIC_FORMATS="mp3|m4a|wav|flac|ogg|aif|aiff|opus"

[[ -z "$(command -v which)" ]] && alias which="command -v"
[[ -z "$(command -v mkdir)" ]] && alias mkdir="$TERMUX__ROOTFS_DIR/usr/bin/mkdir"

PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/bin:$TERMUX__ROOTFS_DIR/usr/bin"
[ -d "$HOME/.elan" ] && PATH="$PATH:$HOME/.elan/bin"

export WORDCHARS=${WORDCHARS//[&+;\-_\/=.]}

local CACHEDIR=$DOTFILES/cache                # for storing files like history and zcompdump 
[ ! -e $CACHEDIR ] && mkdir $CACHEDIR

# Load external config files and tools
    source $DOTFILES/termsupport.zsh                     # Set terminal window title and other terminal-specific things


# Completion
    autoload -Uz compinit && compinit
    zstyle ':completion:*' menu select
    source $DOTFILES/aliases.zsh                         # Load aliases. Done in a seperate file to keep this from getting too long and ugly
    source $DOTFILES/functions.zsh                       # Load misc functions. Done in a seperate file to keep this from getting too long and ugly
    source $DOTFILES/keybindings.zsh                       # Load misc functions. Done in a seperate file to keep this from getting too long and ugly
    [[ -z SKIPPROFILE ]] && source $DOTFILES/.zprofile   # Setup our profile post-login
    source $DOTFILES/spectrum.zsh                        # Make nice colors available
    source $DOTFILES/prompts.zsh                         # Setup our PS1, PS2, etc.


# Set important shell variables
    export EDITOR=hx                            # Set default editor
    export PAGER=less                           # Set default pager
    export LESS="-R"                            # Set the default options for less 
    export LANG="en_GB.UTF-8"                   # I'm not sure who looks at this, but I know it's good to set in general
    export GOFMT=gofumpt
    export CLONEDIR=$HOME/gitclone/clones
    export CLONES=$HOME/gitclone/clones
    export REPO_HOST=https://github.com
    export DEVELOPER=$USER
    export GOPATH="$HOME/go"
    export WORKSPACE="$HOME/workspace"
    export VIDEOS=$HOME/$([[ $(uname) -eq Linux ]] && echo Videos || echo Movies)
    export MUSIC=$HOME/Music
    export NOTES=$HOME/self.notes
    export POSTS=$NOTES/posts
# https://zsh.sourceforge.io/Doc/Release/Options.html
# ZSH History
    history() { fc -fl 1 | sk -me; }
    HISTFILE=$CACHEDIR/history                  # Keep our home directory neat by keeping the histfile somewhere else
    SAVEHIST=10000                              # Big history
    HISTSIZE=10000                              # Big history
    setopt EXTENDED_HISTORY                     # Include more information about when the command was executed, etc
    setopt APPEND_HISTORY                       # Allow multiple terminal sessions to all append to one zsh command history
    setopt HIST_EXPIRE_DUPS_FIRST               # When duplicates are entered, get rid of the duplicates first when we hit $HISTSIZE 
    setopt HIST_FIND_NO_DUPS                    # does not display duplicates when searching the history.
    setopt HIST_IGNORE_SPACE                    # removes commands from the history that begin with a space.
    setopt HIST_IGNORE_DUPS                     # does not enter immediate duplicates into the history.
    setopt HIST_REDUCE_BLANKS                   # Remove extra blanks from each command line being added to history
    setopt HIST_VERIFY                          # makes history substitution commands a bit nicer. I don't fully understand
    setopt INC_APPEND_HISTORY                   # Add commands to history as they are typed, don't wait until shell exit
    setopt SHARE_HISTORY                        # causes all terminals to share the same history 'session'.

# Job control
    setopt LONG_LIST_JOBS                       # lists jobs in verbose format by default.
    setopt NO_BG_NICE                           # prevents background jobs being given a lower priority.
    setopt NO_CHECK_JOBS                        # prevents status report of jobs on shell exit.
    setopt NO_HUP                               # prevents SIGHUP to jobs on shell exit.

# Correction
    unsetopt CORRECT                            # (prompt for input) Try to correct the spelling of commands.
    unsetopt CORRECT_ALL                        # (prompt for input) Try to correct the spelling of all arguments in a line.

# Changing directories
    # setopt AUTO_CD                            # performs cd to a directory if the typed command is invalid, but is a directory.
    setopt AUTO_PUSHD                           # makes cd push the old directory to the directory stack.
    setopt CD_SILENT                            # does not print the working directory after a cd.
    setopt PUSHD_IGNORE_DUPS                    # does not push multiple copies of the same directory to the stack.
    setopt PUSHD_SILENT                         # does not print the directory stack after pushd or popd.
    setopt PUSHD_TO_HOME                        # has pushd without arguments act like pushd ${HOME}.
    unsetopt CHASE_DOTS                         # enables right-relative-paths

# Scripts and Functions
    setopt C_BASES                              # use c-style hexadecimal notation; 0xff not 0#ff
    setopt C_PRECEDENCES                        # use c-style order of operations
    setopt EVAL_LINENO                          # do not use relative line numbers when reporting errors in functions

# Shell Emulation
    setopt NO_CLOBBER                           # disallows > to overwrite existing files. Use >| or >! instead.
    setopt APPEND_CREATE                        # create nonexistent files in append mode

# Misc
    setopt ZLE                                  # Enable the ZLE line editor, which is default behavior, but to be sure
    declare -U path                             # prevent duplicate entries in path
    eval $(dircolors $DOTFILES/dircolors)       # Uses custom colors for LS, as outlined in dircolors
    LESSHISTFILE="/dev/null"                    # Prevent the less hist file from being made, I don't want it
    umask 002                                   # Default permissions for new files, subract from 777 to understand
    setopt NO_BEEP                              # Disable beeps
    setopt MULTI_OS                             # Can pipe to mulitple outputs
    setopt INTERACTIVE_COMMENTS                 # Allows comments in interactive shell.
    setopt RC_EXPAND_PARAM                      # Abc{$cool}efg where $cool is an array surrounds all array variables individually
    unsetopt FLOW_CONTROL                       # Ctrl+S and Ctrl+Q usually disable/enable tty input. This disables those inputs
    # setopt vi       

# Globbing
    setopt GLOB_STAR_SHORT
    setopt NO_CASE_GLOB                         # Case insensitive globbing
    setopt EXTENDED_GLOB                        # Allow the powerful zsh globbing features, see link:
    # http://www.refining-linux.org/archives/37/ZSH-Gem-2-Extended-globbing-and-expansion/
    setopt NUMERIC_GLOB_SORT 


# Aliases
    alias lsa='ls -a'
    alias ll='ls -l'
    alias la='ls -la'
    function changeDirectory { cd $1 ; la }
    alias cdl=changeDirectory;

    alias md='mkdir -p'
    alias rd='rmdir'

    # # Search running processes. Usage: psg <process_name>
    alias psg="ps aux $( [[ -n "$(uname -a | grep CYGWIN )" ]] && echo '-W') | grep -i $1"

    # Copy with a progress bar
    alias cpv="rsync -poghb --backup-dir=$TERMUX__PREFIX/tmp/rsync -e /dev/null --progress --" 

    alias d='dirs -v | head -10'                      # List the last ten directories we've been to this session, no duplicates


# ''{back,for}ward-word() WORDCHARS=$MOTION_WORDCHARS zle .$WIDGET
# zle -N backward-kill-word
# zle -N backward-word
# zle -N forward-word

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5

[[ -x "$(command -v direnv)" ]] && eval "$(direnv hook zsh)"

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

if [ -d "$DOTFILES/zsh-plugins" ]; then
    export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
fi

if [ -d "$ZSH_PLUGINS" ]; then
    [ ! -d "$TERMUX__PREFIX" ] && source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

[[ $- != *i* ]] && return
if [ -z "$TMUX" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ]; then
    exec tmux
fi
