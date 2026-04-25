#!/bin/env sh

# set up a work environment using the xbps package manager
set -eu

self="$(basename "$0")"
description="$(cat "$0" /dev/null </dev/null | sed '1d;2d' | head -1 | sed -E 's/^#\s*//')"

error() {
	echo "$self: $*" >&2
}

fatal() {
	[ $# -gt 0 ] && error "$@"
	exit 1
}

assure() {
	# Collect missing bins/pkgs into positional params as pairs: bin pkg bin pkg ...
	missing=""
	code=0
	while [ $# -gt 0 ]; do
		bin="$1"
		pkg="$2"
		if [ -z "$pkg" ]; then
			fatal "developer error: no package specified for '$bin' binary"
		fi
		if ! command -v "$bin" >/dev/null 2>&1; then
			error "need to install '$bin' from the '$pkg' package"
			missing="$missing $bin $pkg"
		fi
		shift 2
	done
	[ -z "$missing" ] && return 0
	# Re-set positional params to the missing pairs
	# shellcheck disable=SC2086
	set -- $missing # intentional word splitting
	xbps-install -Syu "$@" || return $?
	while [ $# -gt 0 ]; do
		bin="$1" pkg="$2"
		if ! command -v "$bin" >/dev/null 2>&1; then
			error "'$bin' from '$pkg' not installed"
			code=1
		fi
		shift 2
	done
	[ $code = 0 ] || exit $code
}

need() {
	missing=""
	while [ $# -gt 0 ]; do
		[ -x "$(command -v "$1")" ] || {
			missing="$missing $1 $1"
		}
		shift
	done
	[ "${#missing}" = 0 ] && return
	command -v assure >/dev/null || {
		error "need and not sure how to get:"
		# shellcheck disable=SC2086
		printf '%s from %s\n' $missing >&2
		return 1
	}
	# shellcheck disable=SC2086
	assure $missing
}

check() {
	code=0
	while [ $# -gt 0 ]; do
		command -v "$1" >/dev/null || {
			error "couldn't find command/builtin: $1"
			code=1
		}
		shift
	done
	[ $code = 0 ] || exit $code
}

[ "$(id -u)" -ne 0 ] && {
	helpText
	fatal "This script must be run as root. Use 'sudo $self'."
}

user=kendfss
id "$user" 2>/dev/null >/dev/null || while true; do
	user="$(
		printf 'pick a username: '
		read -r user
	)"
	useradd -m -G wheel,users,sudoers "$user" || continue
	passwd "$user" || {
		userdel -r "$user"
		continue
	}
	break
done

[ '#' = "$({ cat /etc/sudoers || exit 1; } | { grep '%wheel' || exit 1; } | { head -1 || exit 1; } | { sed -E 's/./&\n/' || exit 1; } | { head - || exit 1; })" ] && {
	error "you need to enable the %wheel group members to use sudo. press enter to continue"
	read -r null
	echo "$null" >/dev/null
	visudoers
	fatal run this script again
}

userhome="$({ cat /etc/passwd || exit 1; } | { grep "$user" || exit 1; } | { awk -F: '{print $6}' || exit 1; })"
mkdir -p "$userhome/.ssh" && {
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGA7kpOkhqeoMp+MIkw/GshtGPWKuc5C7/apNjxNWC6h" >>"$userhome/.ssh/authorized_keys" # desktop
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXBhkv+CXgD0/a9taeOlf+Q6APZD9gPwQrntUjot+C4" >>"$userhome/.ssh/authorized_keys" # phone
	chown -R "$user:$user" "$userhome/.ssh"
	chmod 700 "$userhome/.ssh"
	chmod 600 "$userhome/.ssh/authorized_keys"
}

if [ ! -f "/etc/sudoers.d/$user" ] && [ ! -n "$(id "$user" | grep wheel)" ]; then
	echo "$user ALL=(ALL) ALL" >"/etc/sudoers.d/$user" || fatal failed to create sudoers entry for "'$user'"
	chmod 440 "/etc/sudoers.d/$user"
fi

timeout 2 ping google.com || {
	mkdir -p "/var/service" || fatal
	[ ! -e "/var/service/wpa_supplicant" ] && {
		ln -fs /etc/sv/wpa_supplicant /var/service/wpa_supplicant || fatal "couldn't setup wpa_supplicant for wifi. link {/etc/sv,/var/service}/wpa_supplicant"
		sv restart wpa_supplicant
	}
	[ ! -e "/var/service/dhcpcd" ] && {
		ln -fs /etc/sv/dhcpcd /var/service/dhcpcd || fatal "couldn't setup dhcpcd for wifi. link {/etc/sv,/var/service}/dhcpcd"
		sv restart dhcpcd
	}
}

[ 0 = "$(cat /etc/doas.conf | wc -l)" ] && {
	cat <<-EOF
		permit persist :root
		permit persist setenv {PATH=$PATH} :wheel
	EOF
}

export DOTFILES="$userhome/.dotfiles"
export ZDOTDIR="$DOTFILES"
export PATH="$DOTFILES/scripts:$PATH:/usr/local/go/bin:$userhome/.local/bin:$userhome/go/bin"
export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
mkdir -p "$ZSH_PLUGINS"

check symlinkDialogue gochain
assure chpst runit tr coreutils || exit $?
need curl uv go bat git

symlinkDialogue() { HOME="$userhome" USER="$user" command symlinkDialogue "$@"; }
gochain() { HOME="$userhome" USER="$user" command gochain "$@"; }

helpText() {
	cat <<-EOF | bat -lman >&2
		usage:
			sudo $self [FLAGS]

		$description

		flags:
			-h, --help            print this message
	EOF
	[ -n "$1" ] && exit "$1"
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help) helpText 0 ;;
		-*)
			helpText
			fatal unexpected flag: "'$1'"
			;;
		*)
			helpText
			fatal unexpected argument: "'$1'"
			;;
	esac
done

[ -z "$(command -v xbps)" ] && { { curl -sL "https://github.com/kendfss/xbps/releases/latest/download/xbps_linux_$(uname -m).tar.gz" | tar -xz -O xbps | tee /usr/bin/xbps >/dev/null && chmod +x /usr/bin/xbps && echo "personal xbps successfully installed"; } || fatal couldn\'t install personal xbps; } || error personal xbps already installed

export CLONEDIR=$HOME/gitclone/clones && { mkdir -p "$CLONEDIR" || fatal "was not able to create \"\$CLONEDIR=$CLONEDIR\""; }
mkdir -p "$HOME/.config" || fatal "couldn't make ~/.config directory"

for name in "$DOTFILES"/scripts/*; do
	[ -x "$name" ] || continue
	target="/usr/bin/$(basename "$name")"
	symlinkDialogue "$name" "$target" || exit $?
done

# for name in "$DOTFILES"/etc/*; do
# 	[ -d "$name" ] || continue
# 	base="$(basename "$name")"
# 	case "$base" in
# 		sv) for path in "$name"/*; do
# 			name="${path##*/}"
# 			symlinkDialogue "$path" "/etc/sv/$name" || exit $?
# 			symlinkDialogue "/etc/sv/$name" "/var/service/$name" || exit $?
# 		done ;;
# 		ly)
# 			continue
# 			symlinkDialogue $DOTFILES/etc/ly/config.ini /etc/ly/config.ini || exit $?
# 			;;
# 		*)
# 			[ "$base" = "ly" ] && continue
# 			symlinkDialogue "$name" "/etc/$base" || exit $?
# 			;;
# 	esac
# done

for name in "$DOTFILES/.config"/*; do
	[ -d "$name" ] || continue
	base="$(basename "$name")"
	symlinkDialogue "$name" "$HOME/.config/$base" || exit $?
done

for item in "$DOTFILES"/.*; do
	[ -f "$item" ] || continue
	target="$HOME/$(basename "$item")"
	symlinkDialogue "$item" "$target" || exit $?
done

if [ -x "$(command -v xbps-install)" ]; then
	xbps-install -yu xbps || exit $?
	xbps-install -Syu xtools || exit $?
	xlocate -S

	packages=''
	echo man-pages-posix zsh acl-progs rsync tmux helix git git-filter-repo github-cli go shfmt flac direnv ripgrep jq clang clang-analyzer fzf clang-tools-extra lldb shellcheck wget htop tree glow typst tinymist pandoc psmisc lf coreutils lua-language-server StyLua taplo base-devel bat gcc make llvm opendoas samba-libs \
		delta gallery-dl lsof ntfs-3g uv pup alsa-utils tree-sitter tree-sitter-cli rustup rust-analyzer mdBook | sed -E 's/\s+/\n/g' | while read -r package; do
		# zenity clipnotify kitty zathura zathura-pdf-mupdf tabbed mpv mpv-mpris playerctl nicotine+ xkill xfce4-screenshooter \
		command -v $package >/dev/null 2>&1 || {
			packages="${packages:+${packages} }$package"
		}
	done
	[ ${#packages} -gt 0 ] && { xbps-install -Syu $packages || exit $?; }
	chsh -s "$(which zsh)" "$user"
	# symlinkDialogue /usr/lib/mpv-mpris/mpris.so ~/.config/mpv/scripts/mpris.so || exit $?

	[ -z "$(gh auth status | tr '[:upper:]' '[:lower:]' | rg -o 'logged in')" ] && error "run 'gh auth login' manually later for github cli access"

	command -v json2go >/dev/null || doas -u "$user" go install github.com/Parutix/json2go@latest || exit $?

	test -d "$HOME/.venv" || { test -e "$HOME/.venv" && fatal "$HOME/.venv exists but isn't a directory"; } || uv venv "$HOME/.venv" || exit $?
	doas -u "$user" uv python install || exit $?
	doas -u "$user" uv pip install python send2trash click dill filetype || exit $?

	gochain || fatal golang toolchain setup failed

	for name in zsh-autosuggestions zsh-syntax-highlighting; do
		[ ! -e "$ZSH_PLUGINS/$name" ] && { git clone --depth=1 "https://github.com/zsh-users/$name" "$ZSH_PLUGINS/$name" || exit 1; }
	done
	[ ! -e "$ZSH_PLUGINS/zsh-sweep" ] && { git clone https://github.com/psprint/zsh-sweep "$ZSH_PLUGINS/zsh-sweep" || exit $?; }
	[ ! -e "$ZSH_PLUGINS/zsh-autoenv" ] && {
		git clone https://github.com/Tarrasch/zsh-autoenv $ZSH_PLUGINS/zsh-autoenv || exit $?
	}
	symlinkDialogue "$ZSH_PLUGINS" "/usr/share/zsh/plugins" || exit $?

	export TMUX_PLUGINS="$HOME/.tmux/plugins"
	mkdir -p "$TMUX_PLUGINS"
	[ ! -d "$TMUX_PLUGINS/tpm" ] && { git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$TMUX_PLUGINS/tpm" || fatal could not clone \$TMUX_PLUGINS/tpm; }

	[ -z "$(command -v npm)" ] && { {
		xbps-install -Syu nodejs && npm i -g bash-language-server awk-language-server yaml-language-server deno
	} || fatal "couldn't install node and npm isn't available"; }

	[ -d "$HOME/.cargo" ] && . "$HOME/.cargo/env"

else
	fatal "xbps-install is not available. Make sure you have the package manager for Void Linux installed."
fi
