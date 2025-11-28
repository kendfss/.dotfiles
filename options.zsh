#!/bin/env zsh

# HISTORY
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

# JOB CONTROL
setopt LONG_LIST_JOBS                       # lists jobs in verbose format by default.
setopt NO_BG_NICE                           # prevents background jobs being given a lower priority.
setopt NO_CHECK_JOBS                        # prevents status report of jobs on shell exit.
setopt NO_HUP                               # prevents SIGHUP to jobs on shell exit.

# CORRECTION
unsetopt CORRECT                            # (prompt for input) Try to correct the spelling of commands.
unsetopt CORRECT_ALL                        # (prompt for input) Try to correct the spelling of all arguments in a line.

# CHANGING DIRECTORIES
# setopt AUTO_CD                            # performs cd to a directory if the typed command is invalid, but is a directory.
setopt AUTO_PUSHD                           # makes cd push the old directory to the directory stack.
setopt CD_SILENT                            # does not print the working directory after a cd.
setopt PUSHD_IGNORE_DUPS                    # does not push multiple copies of the same directory to the stack.
setopt PUSHD_SILENT                         # does not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME                        # has pushd without arguments act like pushd ${HOME}.
unsetopt CHASE_DOTS                         # enables right-relative-paths


# SCRIPTS AND FUNCTIONS
setopt C_BASES                              # use c-style hexadecimal notation; 0xff not 0#ff
setopt C_PRECEDENCES                        # use c-style order of operations
setopt EVAL_LINENO                          # do not use relative line numbers when reporting errors in functions

# SHELL EMULATION
setopt NO_CLOBBER                           # disallows > to overwrite existing files. Use >| or >! instead.
setopt APPEND_CREATE                        # create nonexistent files in append mode

# GLOBBING
setopt GLOB_STAR_SHORT
setopt NO_CASE_GLOB                         # Case insensitive globbing
setopt EXTENDED_GLOB                        # Allow the powerful zsh globbing features, see link:
# http://www.refining-linux.org/archives/37/ZSH-Gem-2-Extended-globbing-and-expansion/
setopt NUMERIC_GLOB_SORT 

# MISC
setopt ZLE                                  # Enable the ZLE line editor, which is default behavior, but to be sure
declare -U path                             # prevent duplicate entries in path
eval $(dircolors $DOTFILES/dircolors)       # Uses custom colors for LS, as outlined in dircolors
LESSHISTFILE="/dev/null"                    # Prevent the less hist file from being made, I don't want it
umask 002                                   # Default permissions for new files, subract from 777 to understand
# setopt NO_BEEP                              # Disable beeps
setopt MULTI_OS                             # Can pipe to mulitple outputs
setopt INTERACTIVE_COMMENTS                 # Allows comments in interactive shell.
setopt RC_EXPAND_PARAM                      # Abc{$cool}efg where $cool is an array surrounds all array variables individually
unsetopt FLOW_CONTROL                       # Ctrl+S and Ctrl+Q usually disable/enable tty input. This disables those inputs
# setopt vi       



