#!/bin/bash

mode="${1:-dark}"

GTK_DARK="Adwaita-dark"
GTK_LIGHT="Adwaita"
ICON_DARK="Fluent-dark"
ICON_LIGHT="Fluent-light"

palette_mode() {
    local f="$HOME/.config/waybar/colors.css" hex
    [ -f "$f" ] || return 1
    hex=$(sed -n 's/^@define-color bg[[:space:]]*#\([0-9a-fA-F]\{6\}\).*/\1/p' "$f" | head -n1)
    [ -n "$hex" ] || return 1
    python3 - "$hex" <<'PY'
import sys

hexv = sys.argv[1]
r, g, b = (int(hexv[i:i + 2], 16) / 255 for i in (0, 2, 4))
luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
print("light" if luma > 0.5 else "dark")
PY
}

case "$mode" in
    light|dark) ;;
    *)
        mode=$(palette_mode 2>/dev/null)
        case "$mode" in
            light|dark) ;;
            *) mode="dark" ;;
        esac
        ;;
esac

case "$mode" in
    light)
        gtk_theme="$GTK_LIGHT"
        icon_theme="$ICON_LIGHT"
        prefer_dark=0
        color_scheme="prefer-light"
        ;;
    *)
        mode="dark"
        gtk_theme="$GTK_DARK"
        icon_theme="$ICON_DARK"
        prefer_dark=1
        color_scheme="prefer-dark"
        ;;
esac

update_ini() {
    local f="$1"
    if [ ! -f "$f" ]; then
        mkdir -p "$(dirname "$f")"
        printf '[Settings]\n' > "$f"
    fi
    if grep -q '^gtk-theme-name=' "$f"; then
        sed -i "s|^gtk-theme-name=.*|gtk-theme-name=$gtk_theme|" "$f"
    else
        printf 'gtk-theme-name=%s\n' "$gtk_theme" >> "$f"
    fi
    if grep -q '^gtk-icon-theme-name=' "$f"; then
        sed -i "s|^gtk-icon-theme-name=.*|gtk-icon-theme-name=$icon_theme|" "$f"
    else
        printf 'gtk-icon-theme-name=%s\n' "$icon_theme" >> "$f"
    fi
    if grep -q '^gtk-application-prefer-dark-theme=' "$f"; then
        sed -i "s|^gtk-application-prefer-dark-theme=.*|gtk-application-prefer-dark-theme=$prefer_dark|" "$f"
    else
        printf 'gtk-application-prefer-dark-theme=%s\n' "$prefer_dark" >> "$f"
    fi
}

update_gtkrc2() {
    local f="$HOME/.gtkrc-2.0"
    [ -f "$f" ] || return 0
    sed -i -E "s|^gtk-theme-name=.*|gtk-theme-name=\"$gtk_theme\"|" "$f"
    sed -i -E "s|^gtk-icon-theme-name=.*|gtk-icon-theme-name=\"$icon_theme\"|" "$f"
}

update_xsettingsd() {
    local f="$HOME/.config/xsettingsd/xsettingsd.conf"
    [ -f "$f" ] || return 0
    sed -i -E "s|^Net/ThemeName .*|Net/ThemeName \"$gtk_theme\"|" "$f"
    sed -i -E "s|^Net/IconThemeName .*|Net/IconThemeName \"$icon_theme\"|" "$f"
    pgrep -x xsettingsd >/dev/null && pkill -HUP xsettingsd 2>/dev/null
}

accent_from_primary() {
    local hex
    hex=$(sed -n 's/^@define-color primary[[:space:]]*\(#[0-9a-fA-F]*\);.*/\1/p' "$HOME/.config/waybar/colors.css" 2>/dev/null | head -n1)
    [ -z "$hex" ] && return 1

    python3 - "$hex" <<'PY'
import colorsys, sys

hexv = sys.argv[1].lstrip('#')
r, g, b = (int(hexv[i:i+2], 16) / 255 for i in (0, 2, 4))
h, l, s = colorsys.rgb_to_hls(r, g, b)
hue = h * 360
if s < 0.10:
    print("slate")
else:
    targets = {"red": 0, "orange": 30, "yellow": 55, "green": 130,
               "teal": 180, "blue": 220, "purple": 280, "pink": 330}
    best = min(targets, key=lambda k: min(abs(hue - targets[k]), 360 - abs(hue - targets[k])))
    print(best)
PY
}

update_ini "$HOME/.config/gtk-3.0/settings.ini"
update_ini "$HOME/.config/gtk-4.0/settings.ini"
update_gtkrc2
update_xsettingsd

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" 2>/dev/null || true
    accent=$(accent_from_primary 2>/dev/null)
    [ -n "$accent" ] && gsettings set org.gnome.desktop.interface accent-color "$accent" 2>/dev/null || true
fi

if [ -f "$HOME/.config/rofi/config.rasi" ]; then
    sed -i -E "s|icon-theme:[[:space:]]*\"[^\"]*\"|icon-theme: \"$icon_theme\"|" "$HOME/.config/rofi/config.rasi"
fi

if command -v flatpak >/dev/null 2>&1; then
    flatpak override --user --env=GTK_THEME="$gtk_theme" >/dev/null 2>&1 || true
fi

exit 0
