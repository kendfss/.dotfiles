#!/bin/env sh

error() {
	# shellcheck disable=2154
	printf "%s:" "$self"
	# shellcheck disable=2068
	printf " %s" $@
	printf '\n'
}

fatal() {
	[ $# = 0 ] || error "$@"
	exit 1
}

[ -x "$(command -v bat 2>/dev/null)" ] || bat() { less; }

assure() {
	# Collect missing bins/pkgs into positional params as pairs: bin pkg bin pkg ...
	missing=""
	pkgs=""
	while :; do
		test $# -gt 0 || break # because we could be in strict mode
		bin="$1"
		pkg="$2"
		[ -n "$pkg" ] || fatal "developer error: no package specified for '$bin' binary"
		if ! command -v "$bin" >/dev/null 2>&1; then
			error "need to install '$bin' from the '$pkg' package"
			missing="$missing $bin $pkg"
			pkgs="$pkgs $pkg"
		fi
		shift 2
	done
	[ -n "$missing" ] || return 0
	# reset positional params to the missing pairs
	# shellcheck disable=SC2086
	set -- $pkgs # intentional word splitting
	# shellcheck disable=SC2086
	xbps-install -Su "$@" || return $?
	# shellcheck disable=SC2086
	set -- $missing # intentional word splitting
	code=0
	while :; do
		test $# -gt 0 || break # because we could be in strict mode
		bin="$1" pkg="$2"
		if ! command -v "$bin" >/dev/null 2>&1; then
			fatal "'$bin' from '$pkg' not installed"
		fi
		shift 2
	done
	return $code
}

need() {
	# check if a binary can be found and try to install a package with its name
	missing=""
	while :; do
		test $# -gt 0 || break # because we could be in strict mode
		[ -x "$(command -v "$1")" ] ||
			missing="$missing $1 $1"
		shift
	done
	test ! "${#missing}" = 0 || return 0
	command -v assure >/dev/null 2>&1 || {
		error "need and not sure how to get:"
		# shellcheck disable=SC2086
		printf "'%s' from package '%s'\n" $missing >&2
		return 1
	}
	# shellcheck disable=SC2086
	assure $missing # intentional word split
	return $?
}
