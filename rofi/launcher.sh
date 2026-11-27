#!/bin/bash

ROFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"

exec rofi \
    -show drun \
    -modi "drun,wallpapers:$ROFI_DIR/wallpaper.sh --modi,clipboard:$ROFI_DIR/clipboard.sh --modi" \
    -kb-mode-next "Right" \
    -kb-mode-previous "Left" \
    -kb-move-char-back "Control+b" \
    -kb-move-char-forward "Control+f" \
    -kb-delete-entry "Ctrl+x" \
    "$@"
