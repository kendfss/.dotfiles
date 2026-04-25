#!/bin/sh

CLIPBOARD_BACKUP_FOLDER="$HOME/.clipboard_backup"
CLIPBOARD_BACKUP_COUNT_LIMIT=50

writeToFile() {
	file=""

	_count="$(find "$CLIPBOARD_BACKUP_FOLDER" -name "$1.*" | wc -l)"
	case "$1" in
		clipboard | primary) file="$CLIPBOARD_BACKUP_FOLDER/$1.$_count" ;;
		*) return 1 ;;
	esac

	data="$(xclip -o -selection "$1" | sed -E "s/^\s+//;s/\s+$//")"
	[ -n "$data" ] || return 0

	printf '%s\n' "$data" >"$file" # && CLIPBOARD_BACKUP_COUNT="$((CLIPBOARD_BACKUP_COUNT + 1))"

	[ "$_count" -ge "$CLIPBOARD_BACKUP_COUNT_LIMIT" ] && {
		# find "$CLIPBOARD_BACKUP_FOLDER" -name "$1.*" |
		# sort -t. -k2 -n |
		ls -1ctr "$CLIPBOARD_BACKUP_FOLDER/$1"* |
			head -n "$((CLIPBOARD_BACKUP_COUNT_LIMIT - 1))" |
			xargs -d '\n' rm
	}
}
