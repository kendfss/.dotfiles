#!/bin/env sh

error() {
	# shellcheck disable=2154
	printf "%s:" "$self"
	# shellcheck disable=2068
	printf " %s" $@
	printf '\n'
}

fatal() {
	error "$@"
	exit 1
}
