#!/bin/sh

activeWorkspaces=$(swaymsg -t get_workspaces)
focusedWorkspace=$(echo $activeWorkspaces | jq -r '.[] | select(.focused==true).num')
activeWorkspaces=$(echo $activeWorkspaces | jq -r '.[].num')
text=""
for i in $activeWorkspaces; do
	if [ $i -ne $focusedWorkspace ]; then
		text="$text $i "
	else
		text="$text[$i]"
	fi
done
echo $text
