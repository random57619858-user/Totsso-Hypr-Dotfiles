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
    clear
    echo -e "${CYAN}${BOLD}"
    echo "┌──────────────────────────────────────────────────┐"
    echo "│       OPENSUSE HYPRLAND DOTFILES INSTALLER       │"
    echo "└──────────────────────────────────────────────────┘"
    echo -e "${RESET}"
}

info()  { echo -e "\n${BLUE}${BOLD}==> ${1}${RESET}"; }
ok()    { echo -e "${GREEN}✔ ${1}${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ ${1}${RESET}"; }
fail()  { echo -e "${RED}✖ ${1}${RESET}" >&2; }

AUTO_INSTALL=false
if [[ "${1:-}" == "--yes" ]]; then AUTO_INSTALL=true; fi

confirm() {
    if [ "$AUTO_INSTALL" = true ]; then return 0; fi
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

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "${ID:-}" != "opensuse-tumbleweed" ] && [[ "${ID_LIKE:-}" != *"opensuse"* ]]; then
        fail "This script is intended for openSUSE Tumbleweed. Detected: ${PRETTY_NAME:-unknown}"
        exit 1
    fi
    ok "openSUSE detected: ${PRETTY_NAME:-unknown}"
else
    fail "Could not detect OS (/etc/os-release not found)."
    exit 1
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

info "Refreshing zypper repositories..."
sudo zypper refresh
ok "Repositories refreshed."

info "Installing base packages..."

sudo zypper install -y \
    hyprland kitty nautilus cava rofi hyprpaper playerctl \
    brightnessctl waybar wl-clipboard grim slurp nwg-look \
    zenity wlogout xdg-desktop-portal-hyprland \
    cliphist wireplumber xdg-user-dirs git unzip wget \
    hyprpolkitagent hypridle hyprlock 

ok "Base packages installed."

info "Setting up display manager (GDM)..."
sudo zypper install -y gdm
sudo update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/gdm 2>/dev/null \
    || sudo update-alternatives --set default-displaymanager /usr/sbin/gdm 2>/dev/null \
    || warn "Could not set GDM as default. Run 'sudo update-alternatives --config default-displaymanager' manually."
sudo systemctl enable gdm
ok "GDM configured."

info "Checking PipeWire services (Tumbleweed ships them by default)..."
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

if [ -d "$XDG_RUNTIME_DIR" ] && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    systemctl --user enable --now pipewire.socket  || warn "Could not enable pipewire.socket"
    systemctl --user enable --now pipewire-pulse.socket || warn "Could not enable pipewire-pulse.socket"
    systemctl --user enable --now wireplumber.service || warn "Could not enable wireplumber.service"
    ok "PipeWire services enabled."
else
    warn "No user session bus available. Enable PipeWire manually after login:"
    warn "  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service"
fi

info "Installing JetBrainsMono Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
FONT_TEMP="$(mktemp_tracked)"

curl -fsSL -o "$FONT_TEMP/JetBrainsMono.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq "$FONT_TEMP/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/JetBrainsMono"
fc-cache -f "$HOME/.local/share/fonts" > /dev/null
ok "Font installed."

info "Optional components..."

if confirm "Install printer support?"; then
    sudo zypper install -y cups cups-client avahi cups-filters nss-mdns system-config-printer

    if command -v nss-mdns-config >/dev/null 2>&1; then
        sudo nss-mdns-config --enable
    else
        warn "nss-mdns-config not found; mDNS resolution may not be enabled."
    fi

    ACTIVE_ZONE=$(sudo firewall-cmd --get-default-zone)
    sudo firewall-cmd --zone="$ACTIVE_ZONE" --add-service=mdns --permanent
    sudo firewall-cmd --zone="$ACTIVE_ZONE" --add-service=ipps --permanent
    sudo firewall-cmd --zone="$ACTIVE_ZONE" --add-service=ipps-client --permanent
    sudo firewall-cmd --reload

    sudo systemctl enable --now cups avahi-daemon
    sudo usermod -aG lp "$USER" 2>/dev/null || true
    ok "Printer support ready."
fi


if confirm "Install Flatpak + Flathub?"; then
    sudo zypper install -y flatpak
    flatpak remote-add  --user --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    ok "Flatpak and Flathub configured."
fi

if confirm "Install extra apps via Flatpak (Steam, Discord, OnlyOffice, VSCodium, OBS Studio, Brave)?"; then
    info "Steam..."
    flatpak install -y --user flathub com.valvesoftware.Steam

    info "Discord..."
    flatpak install -y --user flathub com.discordapp.Discord

    info "OnlyOffice..."
    flatpak install -y --user flathub org.onlyoffice.desktopeditors

    info "VSCodium..."
    flatpak install -y --user flathub com.vscodium.codium

    info "OBS Studio..."
    flatpak install -y --user flathub com.obsproject.Studio

    info "Brave..."
    flatpak install -y --user flathub com.brave.Browser

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

git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git \
    "$TMP_ICONS/Fluent-icon-theme"
( cd "$TMP_ICONS/Fluent-icon-theme" && chmod +x install.sh && \
  ./install.sh -d "$HOME/.local/share/icons" )
ok "Icons installed."

info "Applying GTK settings..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/nwg-look"

GTK_SETTINGS='[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Fluent-dark
gtk-font-name=Sans 10'

printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-3.0/settings.ini"
printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-4.0/settings.ini"

cat > "$HOME/.config/nwg-look/config" <<'EOF'
[General]
icon_theme=Fluent-dark
gtk_theme=Adwaita-dark
cursor_theme=Adwaita
font=Sans 10
EOF

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

    if [ -e "$dest" ]; then
        if confirm "Back up your existing $name config?"; then
            mkdir -p "$BACKUP_ROOT/$name"
            if [ -f "$dest" ]; then
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
find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}┌──────────────────────────────────────────────────┐"
echo "│              All done! Reboot when ready :)        │"
echo "└──────────────────────────────────────────────────┘${RESET}\n"
