#!/bin/bash

WLOGOUT=""
if command -v wlogout >/dev/null 2>&1; then
    WLOGOUT="wlogout"
elif [ -x "$HOME/.local/bin/wlogout" ]; then
    WLOGOUT="$HOME/.local/bin/wlogout"
fi

if [ -n "$WLOGOUT" ]; then
    exec "$WLOGOUT" -b 4
fi

logout="Close session"
suspend="Suspend"
reboot="Reboot"
shutdown="Shutdown"

choice=$(printf '%s\n' "$logout" "$suspend" "$reboot" "$shutdown" |
    rofi -dmenu -i -no-custom -p " Session" \
        -theme-str 'window { width: 420px; } listview { lines: 4; } entry { placeholder: ""; } element { padding: 12px 16px; } element-icon { size: 32px; }')

case "$choice" in
    "$logout") hyprctl dispatch exit ;;
    "$suspend") loginctl suspend ;;
    "$reboot") loginctl reboot ;;
    "$shutdown") loginctl poweroff ;;
esac
