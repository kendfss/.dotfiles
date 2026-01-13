#!/bin/env sh

# logfile=~/tmux-rename-session.log
tns_new=0
tmux ls 2>/dev/null | awk -F: '{print $1}' | sort -n | while read -r tns_prev; do
	if [ "$tns_prev" -eq "$tns_prev" ] 2>/dev/null; then
		tmux rename -t "$tns_prev" "$tns_new"
		# echo "renamed $tns_prev to $tns_new" >> $logfile
		tns_new=$((tns_new+1))
		continue
	fi
	# echo "$tns_prev is still $tns_prev" >> $logfile
done
