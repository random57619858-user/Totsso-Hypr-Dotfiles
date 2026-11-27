#!/bin/bash

ssid=""
signal=""

if command -v nmcli >/dev/null 2>&1; then
    ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2; exit }')
    signal=$(nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2; exit }')
fi

[ -z "$ssid" ] && ssid=$(iwgetid -r 2>/dev/null)

if [ -n "$ssid" ]; then
    ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{ print $4 }' | cut -d/ -f1 | head -n1)
    printf '{"text": "󰤨 %s", "class": "wifi", "tooltip": "%s\\n%s\\nSignal: %s%%"}\n' \
        "$ssid" "$ssid" "${ip:-no IP}" "${signal:-0}"
    exit 0
fi

ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{ print $4 }' | cut -d/ -f1 | head -n1)
if [ -n "$ip" ]; then
    printf '{"text": "󰈀 %s", "class": "ethernet", "tooltip": "Ethernet\\n%s"}\n' "$ip" "$ip"
    exit 0
fi

printf '{"text": "󰤭 No network", "class": "disconnected", "tooltip": "No connection"}\n'
