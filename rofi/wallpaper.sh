#!/bin/bash

CACHE_FILE="$HOME/.cache/current_wallpaper"
MATUGEN_BIN="$HOME/.cargo/bin/matugen"

CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
THUMB_DIR="$CACHE_HOME/totsso-wallpapers/thumbs"
THUMB_SIZE=96

thumb_path() {
    printf '%s/%s.png' "$THUMB_DIR" "$(printf '%s' "$1" | md5sum | cut -d' ' -f1)"
}

make_thumb() {
    local src="$1" out
    out=$(thumb_path "$src")
    mkdir -p "$THUMB_DIR"
    if magick "$src" -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
            -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
            "png:$out" 2>/dev/null; then
        :
    else
        rm -f "$out"
    fi
}

detect_image_dir() {
    local dir
    if command -v xdg-user-dir >/dev/null 2>&1; then
        dir="$(xdg-user-dir PICTURES 2>/dev/null)"
        if [ -n "$dir" ] && [ "$dir" != "$HOME" ] && [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    fi
    for dir in "$HOME/Pictures" "$HOME/Images" "$HOME/Imágenes"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    echo "$HOME"
}

cleanup_wallpaper() {
    pkill -x mpvpaper 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || true
    hyprctl hyprpaper unload all >/dev/null 2>&1 || true
}

write_hyprpaper_conf() {
    local file="$1"
    local conf="$HOME/.config/hypr/hyprpaper.conf"

    if [ -f "$conf" ] && grep -qxF "wallpaper = ,$file" "$conf"; then
        return 0
    fi

    mkdir -p "$(dirname "$conf")"
    printf 'splash = false\nipc = on\npreload = %s\nwallpaper = ,%s\n' "$file" "$file" > "$conf"
}

apply_wallpaper() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}"

    case "$ext" in
        png|jpg|jpeg|webp) ;;
        *)
            notify-send "Wallpaper" "Unsupported format: $ext" 2>/dev/null || true
            return 1
            ;;
    esac

    if pgrep -x hyprpaper >/dev/null 2>&1 &&
       hyprctl hyprpaper listactive 2>/dev/null | grep -qF -- "$file"; then
        write_hyprpaper_conf "$file"
        return 0
    fi

    write_hyprpaper_conf "$file"
    cleanup_wallpaper

    if ! pgrep -x hyprpaper >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ] &&
       command -v hyprpaper >/dev/null 2>&1; then
        setsid hyprpaper >/dev/null 2>&1 </dev/null &
        local i
        for i in $(seq 1 30); do
            hyprctl hyprpaper listloaded >/dev/null 2>&1 && break
            sleep 0.1
        done
    fi

    hyprctl hyprpaper preload "$file" >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper ",$file" >/dev/null 2>&1 || true
}

detect_mode() {
    local file="$1"
    local luma=""

    if command -v magick >/dev/null 2>&1; then
        luma=$(magick "$file" -background black -alpha remove -alpha off -colorspace Gray -resize '1x1!' -format '%[fx:mean]' info: 2>/dev/null)
    elif command -v convert >/dev/null 2>&1; then
        luma=$(convert "$file" -background black -alpha remove -alpha off -colorspace Gray -resize '1x1!' -format '%[fx:mean]' info: 2>/dev/null)
    fi

    if [ -z "$luma" ]; then
        echo "smart"
        return 0
    fi

    if awk -v l="$luma" 'BEGIN { exit !(l > 0.55) }'; then
        echo "light"
    else
        echo "dark"
    fi
}

apply_matugen() {
    local file="$1"

    if [ ! -x "$MATUGEN_BIN" ]; then
        notify-send "Wallpaper" "matugen not found at $MATUGEN_BIN"
        return 1
    fi

    cp "$file" "$HOME/.cache/current_wallpaper.jpg" 2>/dev/null

    local mode
    mode=$(detect_mode "$file")

    "$MATUGEN_BIN" image "$file" \
        --source-color-index 0 \
        --type scheme-tonal-spot \
        --mode "$mode" >/dev/null 2>&1

    local theme_script="$HOME/.config/hypr/scripts/totsso-theme-mode.sh"
    [ -x "$theme_script" ] && "$theme_script" "$mode" >/dev/null 2>&1

    local mode_file="$HOME/.cache/matugen_mode"
    local prev_mode
    prev_mode=$(cat "$mode_file" 2>/dev/null)
    if [ "$mode" != "smart" ] && [ "$mode" != "$prev_mode" ]; then
        echo "$mode" > "$mode_file"
        case "$mode" in
            light) notify-send -u low -a "Wallpaper" "Light theme" "Light wallpaper: light scheme and light GTK" ;;
            dark)  notify-send -u low -a "Wallpaper" "Dark theme" "Dark wallpaper: dark scheme and dark GTK" ;;
        esac
    fi

    if pgrep -x waybar >/dev/null 2>&1; then
        pkill -SIGUSR2 -x waybar 2>/dev/null || true
    else
        setsid waybar >/dev/null 2>&1 </dev/null &
    fi

    pkill -SIGUSR1 -x kitty 2>/dev/null || true
    hyprctl reload >/dev/null 2>&1 || true
}

modi_wallpapers() {
    local retv="${ROFI_RETV:-0}"
    local target dir current p rel display files

    if [ "$retv" != "0" ]; then
        target="${ROFI_INFO:-}"
        if [ -z "$target" ]; then
            rel="${1:-}"
            rel="${rel#● }"
            rel="${rel#  }"
            [ -n "$rel" ] && target="$(detect_image_dir)/$rel"
        fi
        [ -n "$target" ] && [ -f "$target" ] || return 0
        mkdir -p "$(dirname "$CACHE_FILE")"
        printf '%s\n' "$target" > "$CACHE_FILE"
        apply_wallpaper "$target"
        apply_matugen "$target"
        return 0
    fi

    dir=$(detect_image_dir)
    current=$(cat "$CACHE_FILE" 2>/dev/null)
    printf '\0prompt\x1f󰸉\n'

    files=$(find "$dir" -maxdepth 3 -type f \( \
        -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
    \) 2>/dev/null | sort)

    [ -n "$files" ] || return 0

    printf '%s\n' "$files" | while IFS= read -r p; do
        t=$(thumb_path "$p")
        { [ -s "$t" ] && [ ! "$p" -nt "$t" ]; } || printf '%s\n' "$p"
    done | xargs -r -d '\n' -P 4 -n 1 "$0" --thumb

    printf '%s\n' "$files" | while IFS= read -r p; do
        rel="${p#$dir/}"
        if [ "$p" = "$current" ]; then
            display="● $rel"
        else
            display="  $rel"
        fi
        icon=$(thumb_path "$p")
        [ -s "$icon" ] || icon="$p"
        printf '%s\0icon\x1f%s\n' "$display" "$icon"
    done
}

case "${1:-}" in
    --modi)
        modi_wallpapers "${2:-}"
        ;;
    --thumb)
        [ -f "${2:-}" ] && make_thumb "$2"
        ;;
    set)
        file="${2:-}"
        if [ ! -f "$file" ]; then
            notify-send "Wallpaper" "Image not found: ${file:-<empty>}"
            exit 1
        fi
        mkdir -p "$(dirname "$CACHE_FILE")"
        printf '%s\n' "$file" > "$CACHE_FILE"
        apply_wallpaper "$file"
        apply_matugen "$file"
        ;;
    restore)
        sleep 0.5
        [ -f "$CACHE_FILE" ] || exit 0
        saved=$(cat "$CACHE_FILE")
        [ -f "$saved" ] || exit 0
        apply_wallpaper "$saved"
        apply_matugen "$saved"
        ;;
    *)
        echo "Usage: ${0##*/} {set <image>|restore|--modi}" >&2
        exit 1
        ;;
esac
