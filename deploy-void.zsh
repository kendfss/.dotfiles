#!/bin/env zsh
export DOTFILES=$HOME/.dotfiles
export ZDOTDIR="$DOTFILES"
local code
mkdir -p "$HOME/.config" || { code=$? && echo "couldn't make ~/.config directory" && exit $code; }

source "$DOTFILES/functions.zsh" || { code=$? && echo "couldn't source functions" && exit $code; }

[ -z "$(which xbps)" ] && { { curl -sL "https://github.com/kendfss/xbps/releases/latest/download/xbps_linux_$(uname -m).tar.gz" | tar -xz -O xbps | sudo tee /usr/bin/xbps >/dev/null && sudo chmod +x /usr/bin/xbps && echo "personal xbps successfully installed"; } || code=$? && echo couldn\'t install personal xbps && exit $code; } || echo personal xbps already installed

source "$DOTFILES/functions.zsh"

PATH="$DOTFILES/scripts:$PATH:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin"
for name in "$DOTFILES"/scripts/*; do
	[ -x "$name" ] || continue
	target="/usr/bin/$(basename "$name")"
	symlinkDialogue "$name" "$target" || exit $?
done
for name in "$DOTFILES"/services/*; do
	[ -d "$name" ] || continue
	local base="$(basename "$name")"
	symlinkDialogue "$name" "/etc/sv/$base" || exit $?
	symlinkDialogue "$name" "/var/service/$base" || exit $?
done
for name in "$DOTFILES/.config"/*; do
	[ -d "$name" ] || continue
	local base="$(basename "$name")"
	symlinkDialogue "$name" "$HOME/.config/$base" || exit $?
done
for name in "$DOTFILES/etc"/*; do
	[ -d "$name" ] || continue
	local base="$(basename "$name")"
	[ "$base" = "ly" ] && continue
	symlinkDialogue "$name" "/etc/$base" || exit $?
done
symlinkDialogue {$DOTFILES,}/etc/ly/config.ini || exit $?

for item in "$DOTFILES"/.*; do
	[ -f "$item" ] || continue
	local target="$HOME/$(basename "$item")"
	symlinkDialogue "$item" "$target" || exit $?
done

[[ -z $CLONEDIR ]] && export CLONEDIR=$HOME/gitclone/clones && { mkdir -p $CLONEDIR || { code=$? && echo "was not able to create \"\$CLONEDIR=$CLONEDIR\"" && exit $code; }; }

lines() {
	for arg in "$@"; do
		echo "$arg"
	done
}

if [[ -x "$(command -v xbps-install)" ]]; then
	sudo xbps-install -yu xbps || exit $?
	sudo xbps-install -Syu || exit $?
	local packages=()
	local package
	lines git zsh acl-progs rsync zsh tmux kitty helix git git-filter-repo github-cli go shfmt flac direnv ripgrep jq clang clang-analyzer skim clang-tools-extra lldb shellcheck wget htop tree glow typst tinymist tabbed zathura{,-pdf-mupdf} pandoc psmisc lf coreutils mpv{,-mpris} playerctl nicotine+ lua-language-server StyLua taplo base-devel bat gcc make llvm xkill xfce4-screenshooter delta gallery-dl lsof ntfs-3g uv | while read -r package; do
		where $package && continue
		packages+=("$package")
	done
	[ ${#packages} -gt 0 ] && { sudo xbps-install -Syu $packages || exit $?; }

	[[ "$(gh auth status | tr '[:upper:]' '[:lower:]')" != *"logged in"* ]] && { gh auth login || exit $?; }

	which json2go || go install github.com/Parutix/json2go@latest || exit $?

	test -d "$HOME/.venv" || { test -e "$HOME/.venv" && echo "$HOME/.venv exists but isn't a directory" >&2 && exit 1; } || uv venv "$HOME/.venv" || exit $?
	uv pip install {i,pt}python send2trash click dill filetype || exit $?
	# sudo xbps-install -Syu python3{,-{sqlparse,wheel,numpy,Pillow,PyAudio,attrs,audioread,binaryornot,bitarray,boolean.py,click,dill,google-{auth{-{httplib2,oauthlib},},api-{core,python-client}},httpx,requests,language-server,path,pandas,pathtools,pip,pipenv,pipx,platformdirs,re-assert,send2trash,tabulate,virtualenv,argcomplete,click,jedi,parsing,parso,userpath,yaml}} || exit $?

	[ -x "$(command -v gochain)" ] && { gochain || { local code=$? && echo gochain exists but could not run it >&2 && exit $code; }; }

	symlinkDialogue {/usr/lib/mpv-mpris,~/.config/mpv/scripts}/mpris.so || exit $?

	echo here
	export ZSH_PLUGINS="$DOTFILES/zsh-plugins"
	mkdir -p "$ZSH_PLUGINS"
	for name in zsh-{autosuggestions,syntax-highlighting}; do
		[[ ! -e "$ZSH_PLUGINS/$name" ]] && { git clone --depth=1 "https://github.com/zsh-users/$name" "$ZSH_PLUGINS/$name" && source "$ZSH_PLUGINS/$name/$name.zsh"; }
	done
	[[ ! -e "$ZSH_PLUGINS/zsh-sweep" ]] && { { git clone https://github.com/psprint/zsh-sweep "$ZSH_PLUGINS/zsh-sweep" && source "$DOTFILES/.zshrc"; } || exit $?; }
	symlinkDialogue "$ZSH_PLUGINS" "/usr/share/zsh/plugins" || exit $?

	export TMUX_PLUGINS="$HOME/.tmux/plugins"
	mkdir -p "$TMUX_PLUGINS"
	[[ ! -d $TMUX_PLUGINS ]] && { git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$TMUX_PLUGINS/tpm" || { echo could not clone \$TMUX_PLUGINS seems to already exist but not be a directory && exit $?; }; }

	type -p curl >/dev/null || (sudo xbps-install -Syu curl)

	[[ -z "$(command -v npm)" ]] && { { sudo xbps-install -Syu nodejs && sudo npm i -g {bash,awk,yaml}-language-server deno; } || { echo "couldn't install node and npm isn't available" && exit $?; }; }

	[[ ! -x "$(command -v rustup)" ]] && sudo xbps-install -Syu rustup rust-analyzer mdBook

	[ -d "$HOME/.cargo" ] && source "$HOME/.cargo/env"

	[[ ! -x "$(command -v tree-sitter-cli)" ]] && sudo xbps-install -Syu tree-sitter
else
	echo "xbps-install is not available. Make sure you have the package manager for Void Linux installed." && exit 1
fi

export PATH="$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':' | sed 's/:$//g')"
