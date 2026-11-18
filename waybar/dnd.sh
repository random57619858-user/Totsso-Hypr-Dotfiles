#!/bin/bash

case "$1" in
    toggle)
        makoctl mode -t do-not-disturb
        ;;
esac

if makoctl mode | grep -q 'do-not-disturb'; then
    echo '{"text": "󰚣", "tooltip": "No Molestar: Activado", "class": "active"}'
else
    echo '{"text": "󰚢", "tooltip": "No Molestar: Desactivado", "class": "inactive"}'
fi
