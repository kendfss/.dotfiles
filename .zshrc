[ -f ~/.secrets ] && source "$HOME/.secrets"
# Load external config files and tools
    source "$DOTFILES/termsupport.zsh"                     # Set terminal window title and other terminal-specific things
    autoload -Uz compinit && compinit
    zstyle ':completion:*' menu select
    source "$DOTFILES/aliases.zsh"                         # Load aliases. Done in a seperate file to keep this from getting too long and ugly
    source "$DOTFILES/functions.zsh"                       # Load misc functions. Done in a seperate file to keep this from getting too long and ugly
    source "$DOTFILES/keybindings.zsh"                       # Load misc functions. Done in a seperate file to keep this from getting too long and ugly
    [[ -z $SKIPPROFILE ]] && source "$DOTFILES/.zprofile"   # Setup our profile post-login
    source "$DOTFILES/spectrum.zsh"                        # Make nice colors available
    source "$DOTFILES/prompts.zsh"                         # Setup our PS1, PS2, etc.
    source "$DOTFILES/options.zsh"
    source "$DOTFILES/history.zsh"

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5

[[ -x "$(command -v direnv)" ]] && eval "$(direnv hook zsh)"

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"

[ -d "$TERMUX__PREFIX" ] && [ -z "$(pgrep sshd)" ] && [ -x "$(command -v sshd)" ] && { $DOTFILES/boot/sshd || echo unable to start sshd; }

if [ -d "$DOTFILES/zsh-plugins" ]; then
    export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
fi

if [ -d "$ZSH_PLUGINS" ]; then
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
    if [ -d "$ZSH_PLUGINS/zsh-sweep" ]; then
        zs_set_path=1
        source "$DOTFILES/zsh-plugins/zsh-sweep/zsh-sweep.plugin.zsh"
    fi
    [ ! -d "$TERMUX__PREFIX" ] && source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

[[ $- != *i* ]] && return
if [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ] && [ -d "$TERMUX__HOME" ]; then
    exec tmux || echo "couldn't start tmux. exited with $?" >&2
fi

