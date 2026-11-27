#!/usr/bin/env bash

ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
UNDERLINE="${ESC}[4m"

GREEN="${ESC}[38;5;114m"
CYAN="${ESC}[38;5;117m"
YELLOW="${ESC}[38;5;221m"
BLUE="${ESC}[38;5;111m"
RED="${ESC}[38;5;203m"
MAGENTA="${ESC}[38;5;176m"
GRAY="${ESC}[38;5;242m"
WHITE="${ESC}[38;5;255m"

banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo '   ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ '
    echo '   ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗'
    echo '   ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║'
    echo '   ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║'
    echo '   ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝'
    echo '   ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ '
    echo -e "${RESET}"
    echo -e "${GRAY}   ──────────────────────────────────────────${RESET}"
    echo -e "   ${WHITE}${BOLD} Hyprland Dotfiles Installer${RESET}"
    echo -e "   ${DIM}${GRAY}   Arch Linux${RESET}"
    echo -e "${GRAY}   ──────────────────────────────────────────${RESET}\n"
}

info()  { echo -e "\n ${BLUE}${BOLD} ${WHITE}${1}${RESET}"; }
ok()    { echo -e " ${GREEN} ${WHITE}${1}${RESET}"; }
warn()  { echo -e " ${YELLOW} ${WHITE}${1}${RESET}"; }
fail()  { echo -e " ${RED} ${WHITE}${1}${RESET}" >&2; }

step() {
    echo -e "\n${MAGENTA}${BOLD} ── ${1} ${RESET}${GRAY}────────────────────────────────────────${RESET}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

AUTO_INSTALL=false
if [[ "${1:-}" == "--yes" ]]; then AUTO_INSTALL=true; fi

confirm() {
    if [ "$AUTO_INSTALL" = true ]; then return 0; fi
    local msg="$1"
    local reply=""
    if ! { exec 3<>/dev/tty; } 2>/dev/null; then
        warn "No terminal available for the prompt; answering no."
        return 1
    fi
    printf "\n %b%s%b %b[y/N]%b " "${YELLOW}${BOLD}" "$msg" "$WHITE" "$GRAY" "$RESET" >&3
    read -r reply <&3 || reply=""
    printf "\n" >&3
    exec 3>&-
    [[ "${reply:-}" =~ ^[yYsS]$ ]]
}

CLEANUP_DIRS=()
cleanup() {
    local d
    for d in "${CLEANUP_DIRS[@]}"; do
        [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
    done
}
trap cleanup EXIT

mktemp_tracked() {
    local d
    d="$(mktemp -d)"
    CLEANUP_DIRS+=("$d")
    printf '%s' "$d"
}

BACKUP_ROOT="$DOTFILES_DIR/backup"
mkdir -p "$BACKUP_ROOT"

deploy() {
    local src="$1" dest="$2" name="$3"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if confirm "Back up your existing $name config?"; then
            mkdir -p "$BACKUP_ROOT/$name"
            if [ -L "$dest" ]; then cp -Pf "$dest" "$BACKUP_ROOT/$name/"
            elif [ -f "$dest" ]; then cp -f "$dest" "$BACKUP_ROOT/$name/"
            else cp -rf "$dest/." "$BACKUP_ROOT/$name/"; fi
            ok "Saved $name to $BACKUP_ROOT/$name"
        fi
    fi
    if [ ! -e "$src" ]; then warn "Source not found: $src (skipping $name)"; return 0; fi
    if [ -L "$dest" ]; then rm -f "$dest"; fi
    if [ -f "$src" ]; then mkdir -p "$(dirname "$dest")"; cp -f "$src" "$dest"
    elif [ -d "$src" ]; then mkdir -p "$dest"; cp -rf "$src/." "$dest/"; fi
}

install_nerd_font() {
    step "Installing Fonts"
    if command -v fc-list >/dev/null 2>&1 && fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        ok "JetBrainsMono Nerd Font is already installed."
        return 0
    fi
    info "Downloading JetBrainsMono Nerd Font..."
    local TMP_NF="$(mktemp_tracked)"
    mkdir -p "$HOME/.local/share/fonts"

    if wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -O "$TMP_NF/JetBrainsMono.zip"; then
        if unzip -q -o "$TMP_NF/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/"; then
            fc-cache -fv >/dev/null 2>&1 || true
            ok "JetBrainsMono Nerd Font installed."
        else
            fail "Failed to unzip the font file. The download might be corrupted."
            return 1
        fi
    else
        fail "Failed to download the font. Check your internet connection or the URL."
        return 1
    fi
}

install_matugen() {
    step "Installing Matugen"

    if command -v matugen >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/matugen" ]; then
        ok "matugen is already installed."
        return 0
    fi

    if ! command -v cargo >/dev/null 2>&1; then
        info "cargo not found. Installing rustup..."
        sudo pacman -S --needed --noconfirm rustup
        rustup default stable
    fi

    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    export PATH="$HOME/.cargo/bin:$PATH"

    if ! command -v cargo >/dev/null 2>&1; then
        fail "cargo is still not available. Could not install matugen."
        return 1
    fi

    info "Building and installing matugen via cargo (this may take a while)..."
    if cargo install matugen --locked; then
        ok "matugen installed at $HOME/.cargo/bin/matugen"
    else
        fail "Failed to install matugen via cargo."
        return 1
    fi
}

install_icons() {
    step "Installing Icons"
    if compgen -G "$HOME/.local/share/icons/Fluent*" >/dev/null 2>&1; then
        ok "Fluent icon theme is already installed."
        return 0
    fi
    local TMP_ICONS="$(mktemp_tracked)"
    info "Cloning Fluent Icon Theme..."
    if git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme "$TMP_ICONS/Fluent-icon-theme" >/dev/null 2>&1; then
        info "Applying icons..."
        ( cd "$TMP_ICONS/Fluent-icon-theme" && chmod +x install.sh && ./install.sh -d "$HOME/.local/share/icons" >/dev/null 2>&1 )
        ok "Fluent icons installed."
    else
        warn "Failed to clone Fluent-icon-theme; skipping."
        return 1
    fi
}

trizen_enable_sudoloop() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/trizen/trizen.conf"
    [ -f "$conf" ] || return 0
    sed -i -E 's/^([[:space:]]*sudo_autorepeat[[:space:]]*)=>[[:space:]]*0,/\1=> 1,/' "$conf"
    sed -i -E 's/^([[:space:]]*sudo_autorepeat_at_runtime[[:space:]]*)=>[[:space:]]*0,/\1=> 1,/' "$conf"
    ok "trizen sudo_autorepeat enabled."
}

aur_install() {
    local keepalive_pid=""
    local rc=0

    if [ "$#" -eq 0 ]; then
        return 0
    fi

    if sudo -v 2>/dev/null; then
        ( while sleep 60; do sudo -n -v >/dev/null 2>&1 || exit 0; done ) &
        keepalive_pid="$!"
    fi

    trizen -S --needed --noconfirm "$@" || rc=$?

    if [ -n "$keepalive_pid" ]; then
        kill "$keepalive_pid" 2>/dev/null || true
    fi

    return "$rc"
}

apply_default_wallpaper() {
    local dir="$1"
    local picker="$HOME/.config/rofi/wallpaper.sh"
    local default_wall=""

    [ -d "$dir" ] || return 0

    if [ -f "$dir/Kita.png" ]; then
        default_wall="$dir/Kita.png"
    else
        default_wall="$(find "$dir" -maxdepth 1 -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) 2>/dev/null |
            sort | head -n1)"
    fi

    [ -n "$default_wall" ] || { warn "No wallpapers found; skipping palette generation."; return 0; }

    if [ ! -x "$picker" ]; then
        warn "Wallpaper script not found; skipping palette generation."
        return 0
    fi

    info "Applying default wallpaper and generating the color palette..."
    if "$picker" set "$default_wall" >/dev/null 2>&1; then
        ok "Palette generated from $(basename "$default_wall")."
    else
        warn "Could not generate the palette from $(basename "$default_wall")."
    fi
}

ensure_mako_config() {
    local conf="$HOME/.config/mako/config"

    [ -s "$conf" ] && return 0

    warn "mako config is missing; writing a minimal fallback."
    mkdir -p "$(dirname "$conf")"
    cat > "$conf" <<'EOF'
default-timeout=5000
ignore-timeout=1
max-visible=3
anchor=top-center

width=350
margin=10
padding=15
border-size=2
border-radius=12
font=monospace 10
format=<b>%s</b>\n%b

[mode=do-not-disturb]
invisible=1
EOF
}

setup_all_dotfiles() {
    step "Deploying Dotfiles"
    if command -v xdg-user-dirs-update >/dev/null 2>&1; then xdg-user-dirs-update; fi
    if command -v xdg-user-dir >/dev/null 2>&1; then IMG_DIR="$(xdg-user-dir PICTURES)"; else IMG_DIR="$HOME/Pictures"; fi
    if [ ! -d "$IMG_DIR" ] || [ "$IMG_DIR" = "$HOME/Pictures" ]; then mkdir -p "$IMG_DIR"; fi

    deploy "$DOTFILES_DIR/hypr"     "$HOME/.config/hypr"     "hypr"
    deploy "$DOTFILES_DIR/waybar"   "$HOME/.config/waybar"   "waybar"
    deploy "$DOTFILES_DIR/kitty"    "$HOME/.config/kitty"    "kitty"
    deploy "$DOTFILES_DIR/rofi"     "$HOME/.config/rofi"     "rofi"
    deploy "$DOTFILES_DIR/matugen"  "$HOME/.config/matugen"  "matugen"
    deploy "$DOTFILES_DIR/mako"     "$HOME/.config/mako"     "mako"
    deploy "$DOTFILES_DIR/wlogout"  "$HOME/.config/wlogout"  "wlogout"
    deploy "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch" "fastfetch"

    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        info "Copying wallpapers..."
        mkdir -p "$IMG_DIR"
        cp -rf "$DOTFILES_DIR/wallpapers/." "$IMG_DIR/"
        ok "Wallpapers copied to $IMG_DIR"
    fi

    apply_default_wallpaper "$IMG_DIR"
    ensure_mako_config

    step "Finalizing Permissions & Fixes"
    info "Applying executable permissions to scripts..."
    for d in hypr waybar rofi kitty; do
        if [ -d "$HOME/.config/$d" ]; then
            find "$HOME/.config/$d" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
        fi
    done
    find "$DOTFILES_DIR" -maxdepth 3 -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
}

finish_install() {
    echo -e "\n${GRAY}   ──────────────────────────────────────────${RESET}"
    echo -e "   ${GREEN}${BOLD}  Installation Complete!${RESET}"
    echo -e "   ${WHITE}You can now reboot and enjoy Hyprland.${RESET}"
    echo -e "${GRAY}   ──────────────────────────────────────────${RESET}"
    echo -e "   ${CYAN}Backups saved to: ${WHITE}${BOLD}$BACKUP_ROOT${RESET}"
    echo -e "   ${CYAN}Logs saved to:    ${WHITE}${BOLD}$DOTFILES_DIR/install.log${RESET}\n"
}
