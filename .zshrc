[ ! -f ~/.secrets ] || source "$HOME/.secrets"
[ ! -d ~/.secrets ] || source "$HOME/.secrets/env"

{
	source "$DOTFILES/options.zsh"
	source "$DOTFILES/history.zsh"
} # could go in profile, but ain't nobody got time for reboots between changes

source "$DOTFILES/functions.zsh"
source "$DOTFILES/aliases.zsh"

source "$DOTFILES/completions.zsh"
source "$DOTFILES/hooks.zsh"
source "$DOTFILES/keybindings.zsh"

source "$DOTFILES/spectrum.zsh"
source "$DOTFILES/termsupport.zsh"

# Python/UV related
[ ! -d "$HOME/.venv" ] || {
	export VIRTUAL_ENV="$HOME/.venv"
	source "$HOME/.venv/bin/activate"
	alias python="$HOME/.venv/bin/python"
	alias pip="uv pip"
	export TF_FORCE_GPU_ALLOW_GROWTH=true
}

source "$DOTFILES/prompts.zsh"

if [ -d "$TERMUX__PREFIX" ]; then

	[ ! -z "$(pgrep sshd)" ] || [ ! -x "$(command -v sshd)" ] || { "$DOTFILES/boot/sshd" || echo unable to start sshd; }

	if [ ! -z "$TMUX" ] || [ ! -z "$NO_TMUX" ] || [ ! -z "$SSH_TTY" ] || [ ! -z "$SSH_CONNECTION" ] || [ ! -d "$TERMUX__HOME" ]; then
		exec tmux || echo "couldn't start tmux. exited with $?" >&2
	fi

elif [ ! -e /0 ] || [ ! "$(realpath /0)" = "/dev/null" ]; then

	echo "creating link(/dev/null => /0)"
	sudo ln -fs /dev/null /0
	sudo chown "$USER:$USER" /0

fi

if [ -d "$ZSH_PLUGINS" ]; then

	[ ! -d "$ZSH_PLUGINS/zsh-sweep" ] || {
		zs_set_path=1
		source "$DOTFILES/zsh-plugins/zsh-sweep/zsh-sweep.plugin.zsh"
	}

	source_if "$ZSH_PLUGINS/zsh-fzf/fzf-tab.plugin.zsh"
	[ -d "$TERMUX__PREFIX" ] || source_if "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source_if "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source_if "$ZSH_PLUGINS/zsh-autoenv/zsh-autoenv.zsh"

fi
