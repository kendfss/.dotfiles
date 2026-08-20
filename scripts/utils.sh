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
