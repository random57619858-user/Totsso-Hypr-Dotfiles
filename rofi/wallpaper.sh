#!/bin/bash
set -euo pipefail

CACHE_FILE="$HOME/.cache/current_wallpaper"

detect_image_dir() {
    for dir in "$HOME/Pictures" "$HOME/Images" "$HOME/Imágenes"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

require_cmd() {
    if ! command -v "$1" &>/dev/null; then
        notify-send "Wallpaper" "$1 is not installed" 2>/dev/null || echo "$1 is not installed" >&2
        exit 1
    fi
}

cleanup_wallpaper() {
    pkill -x mpvpaper 2>/dev/null || true
    hyprctl hyprpaper unload all >/dev/null 2>&1 || true
}

apply_wallpaper() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}"

    cleanup_wallpaper

    case "$ext" in
        mp4|webm|mkv)
            if ! command -v mpvpaper &>/dev/null; then
                notify-send "Wallpaper" "mpvpaper is not installed" 2>/dev/null || true
                echo "mpvpaper is not installed" >&2
                return 1
            fi
            mpvpaper -f -o "no-audio loop" ALL "$file" >/dev/null 2>&1 || true
            ;;
        png|jpg|jpeg|webp)
            hyprctl hyprpaper preload "$file" >/dev/null 2>&1 || true
            hyprctl hyprpaper wallpaper ",$file" >/dev/null 2>&1 || true
            ;;
        *)
            notify-send "Wallpaper" "Unsupported format: $ext" 2>/dev/null || true
            return 1
            ;;
    esac
}

apply_matugen() {
    local file="$1"
    command -v matugen &>/dev/null || return 0

    local ext="${file##*.}"
    ext="${ext,,}"
    local cache_img="$HOME/.cache/current_wallpaper.jpg"

    case "$ext" in
        mp4|webm|mkv)
            if ! command -v ffmpeg &>/dev/null; then
                return 0
            fi
            ffmpeg -i "$file" -vf "select=eq(n\,0)" -vframes 1 "$cache_img" -y >/dev/null 2>&1 || true
            if [ -f "$cache_img" ]; then
                matugen image "$cache_img" --source-color-index 0 >/dev/null 2>&1 || true
            fi
            ;;
        *)
            cp "$file" "$cache_img" 2>/dev/null || true
            matugen image "$file" --source-color-index 0 >/dev/null 2>&1 || true
            ;;
    esac

    hyprctl reload >/dev/null 2>&1 || true
    pkill -x waybar 2>/dev/null || true
    (waybar &) >/dev/null 2>&1 || true
    pkill -SIGUSR1 kitty 2>/dev/null || true
}

if [ "${1:-}" = "restore" ]; then
    sleep 0.5
    [ -f "$CACHE_FILE" ] || exit 0
    saved=$(cat "$CACHE_FILE")
    [ -f "$saved" ] || exit 0
    apply_wallpaper "$saved"
    apply_matugen "$saved"
    exit 0
fi

require_cmd hyprctl
require_cmd rofi

IMAGE_DIR=$(detect_image_dir) || {
    notify-send "Wallpaper" "No image directory found" 2>/dev/null || echo "No image directory found" >&2
    exit 1
}

TEMP_LIST=$(mktemp)
trap 'rm -f "$TEMP_LIST"' EXIT

find "$IMAGE_DIR" -type f \( \
    -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \
    -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" \
\) -printf "%P|%p\n" | sort > "$TEMP_LIST"

if [ ! -s "$TEMP_LIST" ]; then
    notify-send "Wallpaper" "No images or videos found in $IMAGE_DIR" 2>/dev/null || echo "No images or videos found" >&2
    exit 1
fi

chosen=$(awk -F'|' '{print $1}' "$TEMP_LIST" | rofi -dmenu -p "󰸉 Wallpaper" -i -matching fuzzy)

if [ -n "${chosen:-}" ]; then
    full_path=$(grep -F "$chosen|" "$TEMP_LIST" | head -n 1 | cut -d'|' -f2-)
    if [ -f "$full_path" ]; then
        mkdir -p "$(dirname "$CACHE_FILE")"
        echo "$full_path" > "$CACHE_FILE"
        apply_wallpaper "$full_path"
        apply_matugen "$full_path"
    fi
fi
