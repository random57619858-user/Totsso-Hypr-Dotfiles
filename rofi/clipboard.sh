#!/bin/bash

set -o pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/totsso-clipboard"
THUMB_DIR="$CACHE_DIR/thumbs"
MAX_ENTRIES=40
THUMB_SIZE=96

copy_entry() {
    local id="$1" line subtype mime

    [ -n "$id" ] || return 1

    line=$(cliphist list 2>/dev/null | tr -d '\000' | awk -F'\t' -v id="$id" '$1 == id { print; exit }')
    [ -n "$line" ] || return 1

    if [[ "$line" == *"[[ binary data"* ]]; then
        subtype=$(printf '%s' "$line" |
            sed -E 's/.*\[\[ binary data[^]]* ([A-Za-z0-9.+-]+) [0-9]+x[0-9]+ \]\].*/\1/')
        case "$subtype" in
            png|jpeg|jpg|webp|gif|bmp|tiff) mime="image/$subtype" ;;
            *) mime="application/octet-stream" ;;
        esac
        cliphist decode "$id" | wl-copy --type "$mime" || {
            notify-send -u normal "+ Clipboard" "Could not copy this entry."
            return 1
        }
    else
        cliphist decode "$id" | wl-copy || {
            notify-send -u normal "+ Clipboard" "Could not copy this entry."
            return 1
        }
    fi

    notify-send -u low -t 1200 -a Clipboard "Copied to clipboard"
}

delete_entry() {
    local id="$1" line

    [ -n "$id" ] || return 1

    line=$(cliphist list 2>/dev/null | tr -d '\000' | awk -F'\t' -v id="$id" '$1 == id { print; exit }')
    [ -n "$line" ] || return 1

    printf '%s\n' "$line" | cliphist delete >/dev/null 2>&1 &&
        notify-send -u low "Clipboard" "Entry deleted."
}

build_rows() {
    local id content label display thumb keep=" "

    mkdir -p "$THUMB_DIR" || return 1

    while IFS=$'\t' read -r id content; do
        [ -n "$id" ] || continue
        keep="$keep$id "

        if [[ "$content" == "[[ binary data"* ]]; then
            label=$(printf '%s' "$content" |
                sed -E 's/^\[\[ binary data[^]]* ([A-Za-z0-9.+-]+) ([0-9]+x[0-9]+) \]\]$/\1 \2/')
            [ "$label" = "$content" ] && label="image"
            display="Image · $label"

            thumb="$THUMB_DIR/$id.png"
            if [ ! -s "$thumb" ]; then
                cliphist decode "$id" 2>/dev/null |
                    magick - -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
                        -background none -gravity center \
                        -extent "${THUMB_SIZE}x${THUMB_SIZE}" "png:$thumb" 2>/dev/null ||
                    rm -f "$thumb"
            fi
            [ -s "$thumb" ] || thumb=""

            printf '%s\t%s\t%s\n' "$display" "$id" "$thumb"
            continue
        fi

        display=$(printf '%s' "$content" | tr '\n\r\t' '   ' |
            sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
        [ -z "$display" ] && display="(empty)"
        if [ "${#display}" -gt 100 ]; then
            display="${display:0:99}…"
        fi

        printf '%s\t%s\t\n' "$display" "$id"
    done < <(cliphist list 2>/dev/null | tr -d '\000' | head -n "$MAX_ENTRIES")

    for thumb in "$THUMB_DIR"/*.png; do
        [ -e "$thumb" ] || continue
        id=$(basename "$thumb" .png)
        case "$keep" in
            *" $id "*) ;;
            *) rm -f "$thumb" ;;
        esac
    done
}

list_entries() {
    local label id thumb

    build_rows | while IFS=$'\t' read -r label id thumb; do
        if [ -n "$thumb" ]; then
            printf '%s\0icon\x1f%s\n' "$label" "$thumb"
        else
            printf '%s\n' "$label"
        fi
    done
}

id_for_label() {
    local wanted="$1"

    [ -n "$wanted" ] || return 1
    build_rows | awk -F'\t' -v l="$wanted" '$1 == l { print $2; exit }'
}

case "${1:-}" in
    --modi)
        retv="${ROFI_RETV:-0}"
        case "$retv" in
            0)
                printf '\0prompt\x1f󰅌\n'
                list_entries
                ;;
            3|10)
                delete_entry "$(id_for_label "${2:-}")"
                ;;
            *)
                copy_entry "$(id_for_label "${2:-}")"
                ;;
        esac
        ;;
    *)
        echo "Usage: ${0##*/} --modi   (script mode for rofi/launcher.sh)" >&2
        exit 1
        ;;
esac
