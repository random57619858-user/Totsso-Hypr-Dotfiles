#!/bin/bash

# First-run welcome dialog for Debian-Dotfile
# Shows only once (flag-based)

FLAG_FILE="$HOME/.cache/debian-dotfile-welcomed"

# Si ya se mostró, salimos sin decir nada
[ -f "$FLAG_FILE" ] && exit 0

# Idioma del sistema
LANG_CODE="${LANG:0:2}"

if [ "$LANG_CODE" = "es" ]; then
    TITLE="Debian-Dotfile"
    TEXT="<b>Ya está todo listo </b>

Tu entorno está montado sobre Hyprland con estética gruvbox.
Aquí van los atajos que más vas a usar:

<b>SUPER + Q</b>       abrir kitty
<b>SUPER + D</b>       lanzador de apps (rofi)
<b>SUPER + W</b>       cambiar wallpaper
<b>SUPER + C</b>       cerrar ventana
<b>SUPER + V</b>       flotar/desflotar ventana
<b>SUPER + A</b>       historial del portapapeles
<b>SUPER + L</b>       bloquear pantalla
<b>SUPER + 1-0</b>     cambiar de workspace
<b>SUPER + SHIFT + 1-0</b>  mover ventana a otro workspace
<b>SUPER + SHIFT + E</b>    menú de apagado
<b>SUPER + Print</b>   captura de pantalla

Las configs viven en <b>~/.config/</b> y el repo en <b>~/Debian-Dotfile</b>.
Si algo se rompe, mira el README del repo.

Que lo disfrutes
else
    TITLE="Debian-Dotfile"
    TEXT="<b>You're all set </b>

Your desktop runs on Hyprland with a gruvbox look.
Here are the shortcuts you'll actually use:

<b>SUPER + Q</b>       open kitty
<b>SUPER + D</b>       app launcher (rofi)
<b>SUPER + W</b>       change wallpaper
<b>SUPER + C</b>       close window
<b>SUPER + V</b>       toggle floating window
<b>SUPER + A</b>       clipboard history
<b>SUPER + L</b>       lock screen
<b>SUPER + 1-0</b>     switch workspace
<b>SUPER + SHIFT + 1-0</b>  move window to workspace
<b>SUPER + SHIFT + E</b>    power menu
<b>SUPER + Print</b>   screenshot

Configs live in <b>~/.config/</b> and the repo is at <b>~/Debian-Dotfile</b>.


Enjoy"
fi

zenity --info \
    --title="$TITLE" \
    --width=500 \
    --height=520 \
    --text="$TEXT" \
    --ok-label="OK" 2>/dev/null

mkdir -p "$(dirname "$FLAG_FILE")"
touch "$FLAG_FILE"
exit 0
