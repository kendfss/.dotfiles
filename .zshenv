SUDO_ASKPASS="$(command -v gnome-ssh-askpass 2>/dev/null)"
[ -x "$SUDO_ASKPASS" ] && export SUDO_ASKPASS
SUDO_EDITOR="$(command -v hx 2>/dev/null)"
[ -x "$SUDO_EDITOR" ] && export SUDO_EDITOR

case "$(uname -o | tr '[:upper:]' '[:lower:]')" in
	"gnu/linux")
		[ -d "$HOME/Android/Sdk" ] && ANDROID_STUDIO_HOME="$HOME/Android/Sdk/android-studio"
		[ -d "${ANDROID_STUDIO_HOME:-}" ] && alias anstu="$ANDROID_STUDIO_HOME/bin/studio.sh"
		[ -d "$HOME/Android" ] && export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
		[ -d "${ANDROID_SDK_ROOT:-}" ] && {
			PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools"
			export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/20.1.5948944"
		}
		[ "${TERM:-}" = xterm ] || {
			# export LANG=en_kendfss.UTF-8
			export LANG=C.UTF-8
			export LC_COLLATE=C
		}
		;;
	darwin)
		export PATH="$PATH:/Library/TeX/texbin:/Library/Apple/usr/bin"
		export PATH="$PATH:/Library/Frameworks/Python.framework/Versions/3.10/bin"
		;;
	*) ;;
esac

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
export WORKSPACE="$HOME/workspace"
export FL_ROOT="$HOME/.wine/drive_c/Program Files/Image-Line/FL Studio 2025"
export PLUGINVAL_ROOT="$HOME/.wine/drive_c/Program Files/pluginval_Windows"
export VST2_DIR="$HOME/.wine/drive_c/Program Files/Common Files/VST2"
export FLPROJECTS="$HOME/Documents/Image-Line/FL Studio/Projects"
export VIDEOS="$HOME/$({ [ "$(uname)" = "Linux" ] && echo Videos; } || echo Movies)"
export MUSIC="$HOME/Music"
export NOTES="$HOME/self.notes"
export POSTS="$NOTES/posts"
export HARDWARECLOCK="localtime"
export DOTFILES="$HOME/.dotfiles"
export ZDOTDIR="$DOTFILES"
export CONFIG="$HOME/.config"
export MTPTAB="$DOTFILES/mtptab.toml"
export SCRIPTS="$DOTFILES/scripts"
export PYTHONSTARTUP="$DOTFILES/.pythonrc"

[ -x "$(command -v hx 2>/dev/null)" ] && export HELIX="$HOME/.config/helix"
[ -x "$(command -v bat 2>/dev/null)" ] && export MANPAGER="$HOME/.dotfiles/scripts/manpager"
[ -d "$DOTFILES/zsh-plugins" ] && export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
if command -v sv >/dev/null 2>/dev/null; then
	[ -d "$HOME/service" ] && sv() { SVDIR="$HOME/service" command sv "$@"; }
fi
if [ -x "$(command -v clang)" ]; then
	CC="$(which clang)" && export CC
fi

# Python/UV related
[ -d "$HOME/.venv" ] && export VIRTUAL_ENV="$HOME/.venv" && . "$HOME/.venv/bin/activate"
export TF_FORCE_GPU_ALLOW_GROWTH=true

# Dart/Flutter related
[ -d "$HOME/dartsdk" ] && export PATH="$PATH:$HOME/dartsdk/dart-sdk/bin"
[ -d "$HOME/.cache/dart-sdk" ] && export PATH="$PATH:$HOME/.cache/dart-sdk/bin"

# VS Code related
[ -d "$HOME/.cache/vscode/bin" ] && export PATH="$PATH:$HOME/.cache/vscode/bin"

# rust related
[ -d "$HOME/.cargo" ] && {
	export PATH="$PATH:$HOME/.cargo/bin"
	[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
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

export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/bin:$TERMUX__ROOTFS_DIR/bin:$TERMUX__ROOTFS_DIR/usr/sbin:$TERMUX__ROOTFS_DIR/sbin:$TERMUX__ROOTFS_DIR/usr/local/bin"

if [ -x "$(command -v node)" ]; then
	export PATH="$PATH:$(_dirof node)"
	export PATH="$PATH:$(_dirof npm)"
fi

[ -d /usr/local/go/bin ] && export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/go/bin"

[ -x "$(command -v go)" ] && export PATH="$PATH:$HOME/go/bin"

# export PROFILE="$DOTFILES/.zprofile"
# export RC="$DOTFILES/.zshrc"
# export ENV="$DOTFILES/.zshenv"

export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/kendfss/.local/share/flatpak/exports/share"

[ -d "${TERMUX__ROOTFS_DIR:-}" ] && export PATH="$PATH:$TERMUX__ROOTFS_DIR/usr/local/bin:$TERMUX__ROOTFS_DIR/usr/bin"
[ -d "$HOME/.elan" ] && export PATH="$PATH:$HOME/.elan/bin"

export WORDCHARS="${WORDCHARS//[&+;\-_\/=.\|]/}"

export SKIM_DEFAULT_OPTIONS="-m --tiebreak index --bind='tab:toggle,btab:toggle-preview,ctrl-a:select-all,alt-a:deselect-all,alt-left:backward-word,alt-right:forward-word,alt-up:beginning-of-line,alt-down:end-of-line,alt-delete:kill-word' --cycle --preview-window=wrap-word"
export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"

[ -d "$HOME/.wine/drive_c/bin" ] && export PATH="$PATH:$HOME/.wine/drive_c/bin"
