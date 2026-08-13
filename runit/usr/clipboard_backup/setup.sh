#!/bin/sh

NAME="$(dirname "$0" | xargs -d '\n' basename)"

error() {
	printf '%s\n' "$@" >&2
}

fatal() {
	error "$@"
	exit 1
}
