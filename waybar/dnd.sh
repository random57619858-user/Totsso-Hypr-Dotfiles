#!/bin/bash

case "$1" in
    toggle)
        makoctl mode -t do-not-disturb
        ;;
esac

if makoctl mode | grep -q 'do-not-disturb'; then
    echo '{"text": "󰚣", "tooltip": "Do Not Disturb: On", "class": "active"}'
else
    echo '{"text": "󰚢", "tooltip": "Do Not Disturb: Off", "class": "inactive"}'
fi
