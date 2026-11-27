#!/bin/bash

if command -v hyprlock >/dev/null 2>&1; then
    exec hyprlock
fi

notify-send -u critical "Screen lock" "Install hyprlock to lock the session."
