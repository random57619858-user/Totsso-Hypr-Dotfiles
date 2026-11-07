#!/bin/bash
if playerctl status 2>/dev/null | grep -q "Playing"; then
    artist=$(playerctl metadata --format '{{ artist }}' 2>/dev/null)
    title=$(playerctl metadata --format '{{ title }}' 2>/dev/null)
    line="$artist — $title"
    if [ ${#line} -gt 55 ]; then
        line="${line:0:52}..."
    fi
    echo "$line"
fi
