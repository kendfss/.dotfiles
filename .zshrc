export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
export PATH="$PATH:$HOME/dartsdk/dart-sdk/bin"

[[ ! -d $ZDOTDIR ]] && ln -fs $DOTFILES $ZDOTDIR

[[ -z "$(command -v which)" ]] && alias which="command -v"
[[ -z "$(command -v mkdir)" ]] && alias mkdir="/usr/bin/mkdir"
[[ -z "$(command -v manpath)" ]] && alias manpath="/usr/bin/manpath"

PATH="$PATH:/usr/local/bin:/usr/bin"
PATH="$PATH:/usr/local/lib/nodejs/node-v16.15.0-linux-x64/bin:$HOME/.elan/bin"

export PATH

export WORDCHARS=${WORDCHARS//[&+;\-_\/=.]}
# bindkey "^H" kill-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[3~" delete-char
# bindkey '^[[3;3~' backward-kill-word
bindkey '^[[3;3~' kill-word

local ZSH_CONF=$HOME/.zsh                      # Define the place I store all my zsh config stuff
local ZSH_CACHE=$ZSH_CONF/cache                # for storing files like history and zcompdump 
local LOCAL_ZSHRC=$HOME/.zshlocal/.zshrc       # Allow the local machine to have its own overriding zshrc if it wants it

# Load external config files and tools
    source $ZSH_CONF/termsupport.zsh                     # Set terminal window title and other terminal-specific things
    source $ZSH_CONF/functions.zsh                       # Load misc functions. Done in a seperate file to keep this from getting too long and ugly
    [[ -z SKIPPROFILE ]] && source $ZSH_CONF/.zprofile   # Setup our profile post-login
    source $ZSH_CONF/aliases.zsh                         # Load aliases. Done in a seperate file to keep this from getting too long and ugly
    source $ZSH_CONF/spectrum.zsh                        # Make nice colors available
    source $ZSH_CONF/prompts.zsh                         # Setup our PS1, PS2, etc.


# Set important shell variables
    export EDITOR=hx                            # Set default editor
    export PAGER=less                           # Set default pager
    export LESS="-R"                            # Set the default options for less 
    export LANG="en_US.UTF-8"                   # I'm not sure who looks at this, but I know it's good to set in general
    export GOFMT=gofumpt
    # export MANPATH="/usr/local/share/man/man1"
    export CLONEDIR=$HOME/gitclone/clones
    export CLONES=$HOME/gitclone/clones
    export REPO_HOST=https://github.com
    export DEVELOPER=$USER
    # export GOPATH="$HOME/go:$CLONEDIR/$USER"
    export GOPATH="$HOME/go"
    export WORKSPACE="$HOME/workspace"
    # export SUBLIME="/Users/kendfss/Library/Application Support/Sublime Text"
    export VIDEOS=$HOME/$([[ $(uname) -eq Linux ]] && echo Videos || echo Movies)
    export MUSIC=$HOME/Music
    [[ ! -d $VIDEOS/ydls ]] && mkdir $VIDEOS/ydls
    [[ ! -d $MUSIC/ydls ]] && mkdir $MUSIC/ydls
    export NOTES=$HOME/self.notes
    export POSTS=$NOTES/posts
# https://zsh.sourceforge.io/Doc/Release/Options.html
# ZSH History
    alias history='fc -fl 1'
    HISTFILE=$ZSH_CACHE/history                 # Keep our home directory neat by keeping the histfile somewhere else
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
    # setopt NO_CLOBBER                           # disallows > to overwrite existing files. Use >| or >! instead.
    setopt APPEND_CREATE                        # create nonexistent files in append mode

# Misc
    setopt ZLE                                  # Enable the ZLE line editor, which is default behavior, but to be sure
    declare -U path                             # prevent duplicate entries in path
    # eval $(dircolors $ZSH_CONF/dircolors)       # Uses custom colors for LS, as outlined in dircolors
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
    # git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit" 

    # alias -g ...='../..'
    # alias -g ....='../../..'
    # alias -g .....='../../../..'
    # alias -g ......='../../../../..'
    # alias -g .......='../../../../../..'
    # alias -g ........='../../../../../../..'

    # alias ls="ls -h --color='auto'"
    alias lsa='ls -a'
    alias ll='ls -l'
    alias la='ls -la'
    function changeDirectory { cd $1 ; la }
    alias cdl=changeDirectory;

    alias md='mkdir -p'
    alias rd='rmdir'

    # # Search running processes. Usage: psg <process_name>
    # alias psg="ps aux $( [[ -n "$(uname -a | grep CYGWIN )" ]] && echo '-W') | grep -i $1"

    # Copy with a progress bar
    alias cpv="rsync -poghb --backup-dir=/tmp/rsync -e /dev/null --progress --" 

    alias d='dirs -v | head -10'                      # List the last ten directories we've been to this session, no duplicates


# ''{back,for}ward-word() WORDCHARS=$MOTION_WORDCHARS zle .$WIDGET
# zle -N backward-kill-word
# zle -N backward-word
# zle -N forward-word

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5

export PLUGINS=/usr/share/zsh/plugins
# [[ -d $ZSH_CONF/zsh-autosuggestions ]] && source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
# [[ -d $ZSH_CONF/zsh-syntax-highlighting ]] && source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# sudo ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/local/share/zsh-syntax-highlighting
source $HOME/.elan/env

[[ -x "$(command -v direnv)" ]] && eval "$(direnv hook zsh)"

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

