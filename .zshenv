export DOTFILES="$HOME/.dotfiles"
export SCRIPTS="$DOTFILES/scripts"
SUDO_ASKPASS="$(command -v "$SCRIPTS/augh" 2>/dev/null)"
[ ! -x "$SUDO_ASKPASS" ] || export SUDO_ASKPASS
SUDO_EDITOR="$(command -v hx 2>/dev/null)"
[ ! -x "$SUDO_EDITOR" ] || export SUDO_EDITOR

[ ! -f ~/.secrets ] || source "$HOME/.secrets"
[ ! -d ~/.secrets ] || source "$HOME/.secrets/env"

source "$DOTFILES/options.zsh"
source "$DOTFILES/functions.zsh"
source "$DOTFILES/aliases.zsh"
source "$DOTFILES/spectrum.zsh"

[[ $- != *i* ]] || {

	# Python/UV related
	[ ! -d "$HOME/.venv" ] || {
		export VIRTUAL_ENV="$HOME/.venv"
		source "$HOME/.venv/bin/activate"
		alias python="$HOME/.venv/bin/python"
		alias pip="uv pip"
		export TF_FORCE_GPU_ALLOW_GROWTH=true
	}

	source "$DOTFILES/history.zsh"
	source "$DOTFILES/completions.zsh"
	source "$DOTFILES/hooks.zsh"
	source "$DOTFILES/termsupport.zsh"
	source "$DOTFILES/keybindings.zsh"
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

}

case "$(uname -o | tr '[:upper:]' '[:lower:]')" in
	*linux*)
		export MUSIC="$HOME/Music/library:$HOME/Music/collecting"
		export VIDEOS="$HOME/Videos"
		[ "${TERM:-}" = xterm ] || {
			export LANG=C.UTF-8
			export LC_COLLATE=C
		}
		;;
	*android*)
		export MUSIC="$HOME/storage/music"
		;;
	*)
		export MUSIC="$HOME/Music/library"
		export VIDEOS="$HOME/Movies"
		;;
esac

[ ! -d "$HOME/.local/share/nicotine" ] || export MUSIC="$MUSIC:$HOME/.local/share/nicotine/downloads"

export ABDUCO_CMD="dvtm -m '^['"
export GH_TELEMETRY=false
export DO_NOT_TRACK=true
export EDITOR=hx            # Set default editor
export VISUAL=hx            # Set default editor
export PAGER=less           # Set default pager
export LESS="-RFgM --tilde" # Set the default options for less
export MUSIC_FORMATS="wav|mp3|flac|m4a|aac|aiff|opus|ogg|wma|alac|amr|mogg|webm|wv|raw"
export GOFMT=gofumpt
export CLONEDIR="$HOME/gitclone/clones"
export CLONES="${CLONES-$HOME/gitclone/clones}"
export REPO_HOST=https://github.com
export DEVELOPER="$USER"
export GOPATH="$HOME/go"
export WORKSPACE="$GOPATH/workspace"
export FL_ROOT="$HOME/.wine/drive_c/Program Files/Image-Line/FL Studio 2025"
export PLUGINVAL_ROOT="$HOME/.wine/drive_c/Program Files/pluginval_Windows"
export GPG_TTY=$(tty)
export VST2_DIR="$HOME/.wine/drive_c/Program Files/Common Files/VST2"
export FLPROJECTS="$HOME/Documents/Image-Line/FL Studio/Projects"
export NOTES="$HOME/self.notes"
export POSTS="$NOTES/posts"
export HARDWARECLOCK="localtime"
export ZDOTDIR="$DOTFILES"
export CONFIG="$HOME/.config"
export MTPTAB="$DOTFILES/mtptab.toml"
export PYTHONSTARTUP="$DOTFILES/.pythonrc"
export INPUTRC="$HOME/.inputrc"
[ ! -x "$(command -v hx 2>/dev/null)" ] || export HELIX="$HOME/.config/helix"
[ ! -d "$DOTFILES/zsh-plugins" ] || export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
[ ! -x "$(command -v sv 2>/dev/null)" ] || {
	[ ! -d "$HOME/service" ] || sv() { SVDIR="$HOME/service" command sv "$@"; }
	[ ! -d "$HOME/.config/runit/up" ] || sv() { SVDIR="$HOME/.config/runit/up" command sv "$@"; }
}

[ ! -x "$(command -v bat 2>/dev/null)" ] || export MANPAGER="$HOME/.dotfiles/scripts/manpager"
[ ! -d "$HOME/.local/share/man" ] || rg -q "$HOME/.local/share/man" <<<"$MANPATH" || export MANPATH="$HOME/.local/share/man:$MANPATH"

# Dart/Flutter related
[ ! -d "$HOME/dartsdk" ] || export PATH="$PATH:$HOME/dartsdk/dart-sdk/bin"
[ ! -d "$HOME/.cache/dart-sdk" ] || export PATH="$PATH:$HOME/.cache/dart-sdk/bin"

# VS Code related
[ ! -d "$HOME/.cache/vscode/bin" ] || export PATH="$PATH:$HOME/.cache/vscode/bin"

# rust related
[ ! -d "$HOME/.cargo" ] || {
	export PATH="$PATH:$HOME/.cargo/bin"
	source_if "$HOME/.cargo/env"
}

[ ! -d "$HOME/Android" ] || {
	export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
	[ ! -d "$HOME/Android/Sdk" ] || ANDROID_STUDIO_HOME="$HOME/Android/Sdk/android-studio"

	[ ! -d "${ANDROID_STUDIO_HOME:-}" ] || alias anstu="$ANDROID_STUDIO_HOME/bin/studio.sh"
	[ ! -d "${ANDROID_SDK_ROOT:-}" ] || {
		PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools"
		export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/20.1.5948944"
	}
}
[ ! -d "$HOME/android_sdk" ] || {
	export ANDROID_HOME=$HOME/android_sdk
	export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
	export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/20.1.5948944"
	export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"
}

export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin:$DOTFILES/scripts"
export DICTAPI="https://api.dictionaryapi.dev/api/v2/entries/en_GB"

_dirof() {
	for name in "$@"; do
		pth="$(dirname "$(command -v "$name")")"
		echo "$pth"
	done
}

export RUST_BACKTRACE=full

[ ! -x "$(command -v go)" ] || {
	export PATH="$PATH:$HOME/go/bin"
	export GOMEMLIMIT=4GiB
}

[ ! -x "$(command -v flatpak 2>/dev/null)" ] || alias bottles="flatpak run com.usebottles.bottles"
[ ! -d "/var/lib/flatpak" ] || export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/kendfss/.local/share/flatpak/exports/share"

[ ! -d "${TERMUX__ROOTFS_DIR:-}" ] || {
	export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/bin:$TERMUX__ROOTFS_DIR/usr/bin"
	export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/bin:$TERMUX__ROOTFS_DIR/bin:$TERMUX__ROOTFS_DIR/usr/sbin:$TERMUX__ROOTFS_DIR/sbin:$TERMUX__ROOTFS_DIR/usr/local/bin"
	[ ! -d /usr/local/go/bin ] || export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/go/bin"
}
[ ! -d "$HOME/.elan" ] || export PATH="$PATH:$HOME/.elan/bin" ELAN_HOME="$HOME/.elan"

export WORDCHARS="${WORDCHARS//[&+;\-_\/=.\|]/}"

export SKIM_DEFAULT_OPTIONS="-m --tiebreak index --bind='ctrl-x:exclude,tab:toggle,btab:toggle-preview,ctrl-a:select-all,alt-a:deselect-all,alt-left:backward-word,alt-right:forward-word,alt-up:beginning-of-line,alt-down:end-of-line,alt-delete:kill-word,ctrl-r:refresh-preview,ctrl-/:toggle-input' --cycle --preview-window=wrap-word"
export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"

[ ! -d "$HOME/.wine/drive_c/bin" ] || export PATH="$PATH:$HOME/.wine/drive_c/bin"
