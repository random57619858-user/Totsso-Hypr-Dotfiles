#!/usr/bin/env bash

pkill -f "cava -p $HOME/.config/cava/config" 2>/dev/null

stdbuf -oL cava -p "$HOME/.config/cava/config" 2>/dev/null | while read -r line; do
    echo "$line" | sed 's/;//g;s/0/ /g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g'
done
