#!/bin/sh

CLIPBOARD_BACKUP_FOLDER="$HOME/.clipboard_backup"
CLIPBOARD_BACKUP_COUNT_LIMIT=50
CLIPBOARD_BACKUP_COUNT=0
PRIMARY_BACKUP_COUNT=0

writeToFile() {
	_file=""
	_index=0
	_count="$(find "$CLIPBOARD_BACKUP_FOLDER" -name "$1.*" | wc -l)"

	case "$1" in
		clipboard)
			CLIPBOARD_BACKUP_COUNT="$((CLIPBOARD_BACKUP_COUNT + 1))"
			_index="$CLIPBOARD_BACKUP_COUNT"
			;;
		primary)
			PRIMARY_BACKUP_COUNT="$((PRIMARY_BACKUP_COUNT + 1))"
			_index="$PRIMARY_BACKUP_COUNT"
			;;
	esac
	case "$1" in
		clipboard | primary) _file="$CLIPBOARD_BACKUP_FOLDER/$1.$_index" ;;
		*) return 1 ;;
	esac

	data="$(printf '%s' "$2" | sed -E "s/^\s*//;s/\s*$//")"
	[ -n "$data" ] || return 0

	printf '%s\n' "$data" >"$_file" # && CLIPBOARD_BACKUP_COUNT="$((CLIPBOARD_BACKUP_COUNT + 1))"

	[ "$_count" -ge "$CLIPBOARD_BACKUP_COUNT_LIMIT" ] && {
		# find "$CLIPBOARD_BACKUP_FOLDER" -name "$1.*" |
		# sort -t. -k2 -n |
		ls -1ctr $CLIPBOARD_BACKUP_FOLDER/$1.* |
			head -n "$((CLIPBOARD_BACKUP_COUNT_LIMIT - 1))" |
			xargs -d '\n' rm
	}
}
