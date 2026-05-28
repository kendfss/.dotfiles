set -o pipefail # remember to check $pipestatus

[ -f ~/.secrets ] && source "$HOME/.secrets"

# Load external config files and tools
source "$DOTFILES/completions.zsh"
source "$DOTFILES/termsupport.zsh"
source "$DOTFILES/aliases.zsh"
source "$DOTFILES/functions.zsh"
source "$DOTFILES/keybindings.zsh"
source "$DOTFILES/options.zsh"
source "$DOTFILES/history.zsh"
source "$DOTFILES/hooks.zsh"
[ -z "$SKIPPROFILE" ] && source "$DOTFILES/.zprofile" # Setup our profile post-login
source "$DOTFILES/spectrum.zsh"                       # Make nice colors available
source "$DOTFILES/prompts.zsh"                        # Setup our PS1, PS2, etc.

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5

[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"

if [ -d "$TERMUX__PREFIX" ]; then
	[ -z "$(pgrep sshd)" ] && [ -x "$(command -v sshd)" ] && { "$DOTFILES/boot/sshd" || echo unable to start sshd; }
elif [ ! -e /0 ] || [ ! "$(realpath /0)" = "/dev/null" ]; then
	echo "creating link(/dev/null => /0)"
	sudo ln -fs /dev/null /0
	sudo chown "$USER:$USER" /0
fi

if [ -d "$ZSH_PLUGINS" ]; then
	[ -d "$ZSH_PLUGINS/zsh-sweep" ] && {
		zs_set_path=1
		source "$DOTFILES/zsh-plugins/zsh-sweep/zsh-sweep.plugin.zsh"
	}
	{
		[ -z "${_comps+x}" ] && {
			autoload -U compinit
			compinit
		}
		source_if "$ZSH_PLUGINS/zsh-fzf/fzf-tab.plugin.zsh"
	}
	[ ! -d "$TERMUX__PREFIX" ] && source_if "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source_if "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source_if "$ZSH_PLUGINS/zsh-autoenv/zsh-autoenv.zsh"
fi

[[ $- != *i* ]] && return
if [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ] && [ -d "$TERMUX__HOME" ]; then
	exec tmux || echo "couldn't start tmux. exited with $?" >&2
fi
