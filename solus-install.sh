#!/usr/bin/env bash
set -euo pipefail

ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
GREEN="${ESC}[32m"
CYAN="${ESC}[36m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
RED="${ESC}[31m"

banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo "┌──────────────────────────────────────────────────┐"
    echo "│         SOLUS HYPRLAND DOTFILES INSTALLER        │"
    echo "└──────────────────────────────────────────────────┘"
    echo -e "${RESET}"
}

info()  { echo -e "\n${BLUE}${BOLD}==> ${1}${RESET}"; }
ok()    { echo -e "${GREEN}✔ ${1}${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ ${1}${RESET}"; }
fail()  { echo -e "${RED}✖ ${1}${RESET}" >&2; }

confirm() {
    local msg="$1"
    local reply=""
    read -p "$msg (y/N): " reply < /dev/tty || true
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

banner

if [ "$(id -u)" -eq 0 ]; then
    fail "Do not run this script as root. Use your normal user (sudo is requested internally)."
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "${ID:-}" != "solus" ]; then
        warn "This script is designed for Solus (detected: ${ID:-unknown})."
        confirm "Continue anyway?" || { fail "Aborted by user."; exit 0; }
    fi
fi

if ! command -v sudo >/dev/null 2>&1; then
    fail "sudo is required but not installed. Aborting."
    exit 1
fi

if ! sudo -v; then
    fail "sudo is required. Aborting."
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$DOTFILES_DIR/backup"
mkdir -p "$BACKUP_ROOT"

info "Updating eopkg repositories..."
sudo eopkg update-repo

info "Upgrading system..."
sudo eopkg upgrade -y

info "Installing Hyprland..."
sudo eopkg install -y hyprland

info "Installing base packages..."
sudo eopkg install -y \
    firefox nautilus kitty cava rofi hyprpaper playerctl \
    light waybar wl-clipboard grim slurp \
    zenity wlogout xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
    hyprpolkitagent hypridle hyprlock \
    xdg-user-dirs git unzip curl wget

info "Installing development tools..."
sudo eopkg install -c system.devel -y

info "Installing Go (required to build cliphist)..."
if ! command -v go >/dev/null 2>&1; then
    sudo eopkg install -y golang
else
    ok "Go already installed."
fi

info "Building cliphist from source..."
if command -v cliphist >/dev/null 2>&1; then
    ok "cliphist already installed."
else
    TMP_CLIPHIST="$(mktemp_tracked)"
    git clone --depth=1 https://github.com/sentriz/cliphist.git \
        "$TMP_CLIPHIST/cliphist"
    ( cd "$TMP_CLIPHIST/cliphist" && go build -o cliphist . )
    sudo install -Dm755 "$TMP_CLIPHIST/cliphist/cliphist" /usr/local/bin/cliphist
    ok "cliphist installed to /usr/local/bin."
fi

info "Configuring display manager..."
if systemctl is-enabled lightdm 2>/dev/null || systemctl is-enabled sddm 2>/dev/null; then
    warn "Another display manager is already enabled. GDM will not be enabled automatically."
elif confirm "Install and enable GDM as display manager?"; then
    info "Installing GDM..."
    sudo eopkg install -y gdm
    sudo systemctl enable gdm
    ok "GDM enabled."
else
    warn "Skipping GDM. You can start Hyprland manually from TTY with 'exec Hyprland'."
fi

info "Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if [ -d "$FONT_DIR" ] && command -v fc-list >/dev/null 2>&1 \
   && fc-list | grep -qi "JetBrainsMono"; then
    ok "JetBrainsMono Nerd Font already installed."
else
    mkdir -p "$HOME/.local/share/fonts"
    FONT_TEMP="$(mktemp_tracked)"
    curl -fsSL -o "$FONT_TEMP/JetBrainsMono.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -oq "$FONT_TEMP/JetBrainsMono.zip" -d "$FONT_DIR"
    fc-cache -f "$HOME/.local/share/fonts" > /dev/null
    ok "JetBrainsMono Nerd Font installed."
fi

info "Optional components..."

if confirm "Install printer support?"; then
    sudo eopkg install -y cups avahi
    sudo systemctl enable --now cups avahi-daemon
    sudo usermod -aG lpadmin "$USER" 2>/dev/null || true
    ok "Printer support ready."
fi

if confirm "Install Flatpak + Flathub?"; then
    sudo eopkg install -y flatpak
    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    ok "Flatpak and Flathub configured."
fi

if confirm "Install extra apps via Flatpak (Steam, Discord, OnlyOffice, VSCodium, OBS Studio)?"; then
    for app in \
        com.valvesoftware.Steam \
        com.discordapp.Discord \
        org.onlyoffice.desktopeditors \
        com.vscodium.codium \
        com.obsproject.Studio
    do
        info "Installing $app..."
        flatpak install -y --noninteractive flathub "$app"
    done
    ok "Extra apps installed via Flatpak."
fi

info "Setting up user directories..."
if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update
fi

if [ -d "$HOME/Imágenes" ]; then
    IMG_DIR="$HOME/Imágenes"
elif [ -d "$HOME/Pictures" ]; then
    IMG_DIR="$HOME/Pictures"
else
    IMG_DIR="$HOME/Pictures"
    mkdir -p "$IMG_DIR"
fi

info "Installing Fluent icon theme..."
TMP_ICONS="$(mktemp_tracked)"
if git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git \
        "$TMP_ICONS/Fluent-icon-theme"; then
    ( cd "$TMP_ICONS/Fluent-icon-theme" && chmod +x install.sh && \
      ./install.sh -d "$HOME/.local/share/icons" )
    ok "Icons installed."
else
    warn "Failed to clone Fluent-icon-theme; skipping."
fi

info "Applying GTK settings..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

GTK_SETTINGS='[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Fluent-dark
gtk-font-name=Sans 10'

printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-3.0/settings.ini"
printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-4.0/settings.ini"

if command -v gsettings &> /dev/null && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true
    gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark' || true
else
    warn "gsettings or D-Bus session not available; skipping runtime GTK settings."
fi

info "Deploying dotfiles..."

deploy() {
    local src="$1" dest="$2" name="$3"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if confirm "Back up your existing $name config?"; then
            mkdir -p "$BACKUP_ROOT/$name"
            if [ -L "$dest" ]; then
                cp -Pf "$dest" "$BACKUP_ROOT/$name/"
            elif [ -f "$dest" ]; then
                cp -f "$dest" "$BACKUP_ROOT/$name/"
            else
                cp -rf "$dest/." "$BACKUP_ROOT/$name/"
            fi
            ok "Saved $name to $BACKUP_ROOT/$name"
        fi
    fi

    if [ ! -e "$src" ]; then
        warn "Source not found: $src (skipping $name)"
        return 0
    fi

    if [ -L "$dest" ]; then
        rm -f "$dest"
    fi

    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -f "$src" "$dest"
    elif [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -rf "$src/." "$dest/"
    fi
}

deploy "$DOTFILES_DIR/cava"     "$HOME/.config/cava"     "cava"
deploy "$DOTFILES_DIR/kitty"    "$HOME/.config/kitty"    "kitty"
deploy "$DOTFILES_DIR/waybar"   "$HOME/.config/waybar"   "waybar"
deploy "$DOTFILES_DIR/wlogout"  "$HOME/.config/wlogout"  "wlogout"
deploy "$DOTFILES_DIR/hypr"     "$HOME/.config/hypr"     "hypr"
deploy "$DOTFILES_DIR/rofi"     "$HOME/.config/rofi"     "rofi"

info "Setting up lockscreen wallpaper..."

if [ -f "$DOTFILES_DIR/wallpapers/astronaut.jpg" ]; then
    cp "$DOTFILES_DIR/wallpapers/astronaut.jpg" \
       "$HOME/.config/hypr/lockscreen.jpg"
    ok "Lockscreen wallpaper set (copy of astronaut.jpg)"
else
    warn "astronaut.jpg not found in wallpapers/, skipping lockscreen setup."
fi

info "Setting up wlogout icons from Fluent-dark..."
ICON_SRC="$HOME/.local/share/icons/Fluent-dark/scalable/apps"

if [ -d "$ICON_SRC" ]; then
    mkdir -p "$HOME/.config/wlogout/icons"
    declare -A ICONS=(
        [lock]="system-lock-screen"
        [logout]="gnome-logout"
        [suspend]="system-suspend"
        [hibernate]="system-suspend-hibernate"
        [reboot]="system-reboot"
        [shutdown]="system-shutdown"
    )
    for dest in "${!ICONS[@]}"; do
        src_file="$ICON_SRC/${ICONS[$dest]}.svg"
        if [ -f "$src_file" ]; then
            cp "$src_file" "$HOME/.config/wlogout/icons/$dest.svg"
        else
            warn "Icon not found: ${ICONS[$dest]}.svg"
        fi
    done
    ok "wlogout icons installed."
else
    warn "Fluent-dark icon theme not found, skipping wlogout icons."
fi

if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -rf "$DOTFILES_DIR/wallpapers/." "$IMG_DIR/"
    ok "Wallpapers copied to $IMG_DIR"
else
    warn "No wallpapers directory in repo, skipping."
fi

info "Fixing script permissions..."
for d in hypr waybar rofi wlogout kitty cava; do
    if [ -d "$HOME/.config/$d" ]; then
        find "$HOME/.config/$d" -type f -name "*.sh" \
            -exec chmod +x {} + 2>/dev/null || true
    fi
done
find "$DOTFILES_DIR" -maxdepth 2 -type f -name "*.sh" \
    -exec chmod +x {} + 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}┌──────────────────────────────────────────────────┐"
echo "│              All done! Reboot when ready :)        │"
echo "└──────────────────────────────────────────────────┘${RESET}\n"
echo -e "${CYAN}Backups saved to: ${BOLD}$BACKUP_ROOT${RESET}\n"
