#!/usr/bin/env bash

if ! command -v sudo >/dev/null 2>&1; then
    fail "sudo is required but not installed. Aborting."
    exit 1
fi

if ! sudo -v; then
    fail "sudo is required. Aborting."
    exit 1
fi

info "Enabling multilib repository..."
if grep -q "^#\[multilib\]" /etc/pacman.conf; then
    if confirm "Enable multilib repository (needed for 32-bit apps like native Steam)?"; then
        sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf
        ok "Multilib repository enabled."
        sudo pacman -Sy
    else
        warn "Multilib not enabled. Some 32-bit applications may not work."
    fi
else
    ok "Multilib repository is already enabled."
fi

info "Updating system..."
sudo pacman -Syu --noconfirm

info "Checking/Installing trizen (AUR helper)..."
if ! command -v trizen >/dev/null 2>&1; then
    info "Installing trizen..."
    sudo pacman -S --needed --noconfirm git base-devel
    TMP_TRIZEN="$(mktemp_tracked)"
    git clone https://aur.archlinux.org/trizen.git "$TMP_TRIZEN/trizen"
    ( cd "$TMP_TRIZEN/trizen" && makepkg -si --noconfirm )
    ok "trizen installed."
else
    ok "trizen is already installed."
fi

trizen_enable_sudoloop

info "Installing base packages from official repositories..."
sudo pacman -S --needed --noconfirm \
    hyprland hyprpaper hyprlock hyprpolkitagent \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    kitty fish rofi waybar cava nautilus nwg-look \
    mako libnotify wl-clipboard grim slurp ffmpeg cliphist \
    playerctl brightnessctl \
    pipewire wireplumber pipewire-audio pipewire-pulse \
    imagemagick python fastfetch gdm \
    xdg-user-dirs git unzip base-devel wget curl \
    ttf-jetbrains-mono-nerd noto-fonts-emoji
ok "Base packages installed."

info "Installing AUR packages (wlogout)..."
aur_install wlogout && ok "wlogout installed." || warn "Could not install wlogout."
mkdir -p "$HOME/.local/bin"

install_matugen

info "Checking init system..."
if [ ! -d /run/systemd/system ]; then
    fail "systemd not detected. This installer supports Arch Linux and its derivatives only."
    exit 1
fi
ok "systemd detected."

info "Enabling PipeWire user services (systemd)..."
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

if [ -d "$XDG_RUNTIME_DIR" ]; then
    systemctl --user enable --now pipewire.socket        || warn "Could not enable pipewire.socket"
    systemctl --user enable --now pipewire-pulse.socket  || warn "Could not enable pipewire-pulse.socket"
    systemctl --user enable --now wireplumber.service    || warn "Could not enable wireplumber.service"
else
    warn "No user session bus available. Enable PipeWire manually after login:"
    warn "  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service"
fi

info "Configuring display manager..."
if systemctl is-enabled sddm 2>/dev/null || systemctl is-enabled lightdm 2>/dev/null; then
    warn "Another display manager is already enabled. GDM will not be enabled automatically."
elif confirm "Enable GDM (login screen)?"; then
    sudo systemctl enable gdm.service
    ok "GDM enabled."
else
    warn "Skipped. Start Hyprland manually with: Hyprland"
fi

info "Configuring Fish shell..."
if command -v fish >/dev/null 2>&1; then
    fish -c "set -U fish_greeting"
    ok "Fish greeting disabled."
else
    warn "Fish not found; skipping configuration."
fi

if ! install_nerd_font; then
    warn "JetBrainsMono Nerd Font is missing; install it manually to see the icons."
fi

if ! install_icons; then
    warn "Fluent icons are missing; install them manually to see app icons."
fi

info "Applying GTK settings..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for d in gtk-3.0 gtk-4.0; do
    if [ -L "$HOME/.config/$d/gtk.css" ]; then rm -f "$HOME/.config/$d/gtk.css"; fi
done
GTK_SETTINGS='[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Fluent-dark
gtk-font-name=Sans 10'
printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-3.0/settings.ini"
printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-4.0/settings.ini"

if command -v gsettings >/dev/null 2>&1 && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark' 2>/dev/null || true
fi

step "Optional Apps"

choose_one() {
    local prompt="$1"; shift
    local total="$#"
    local i=1
    local opt

    if [ "$AUTO_INSTALL" = true ]; then
        printf "1\n"
        return 0
    fi

    if ! { exec 3<>/dev/tty; } 2>/dev/null; then
        printf "0\n"
        return 0
    fi

    printf "\n %b%s%b\n" "${WHITE:-}" "$prompt" "${RESET:-}" >&3
    printf " %b  0) Skip%b\n" "${GRAY:-}" "${RESET:-}" >&3
    for opt in "$@"; do
        printf " %b  %d) %b%s%b\n" "${GRAY:-}" "$i" "${WHITE:-}" "$opt" "${RESET:-}" >&3
        i=$((i+1))
    done

    local reply=""
    printf " %b%b%bChoose [0-%d]%b:%b " "${YELLOW:-}" "${BOLD:-}" "${WHITE:-}" "$total" "${GRAY:-}" "${RESET:-}" >&3
    read -r reply <&3 || reply=""
    reply="${reply//[[:space:]]/}"
    printf "\n" >&3
    exec 3>&-

    if ! [[ "$reply" =~ ^[0-9]+$ ]] || [ "$reply" -lt 0 ] || [ "$reply" -gt "$total" ]; then
        printf "0\n"
        return 0
    fi

    printf "%s\n" "$reply"
    return 0
}

PKG=""
sel="$(choose_one "Which browser do you want?" "brave-bin (Recommended)" "ungoogled-chromium" "zen-browser-bin")"
case "$sel" in
    1) PKG="brave-bin" ;;
    2) PKG="ungoogled-chromium" ;;
    3) PKG="zen-browser-bin" ;;
    *) PKG="" ;;
esac
if [ -n "$PKG" ]; then
    info "Installing $PKG via trizen..."
    aur_install "$PKG" && ok "$PKG installed." || warn "Failed to install $PKG."
else
    ok "Skipping browser."
fi

PKG=""
sel="$(choose_one "Which Discord client do you want?" "serein-bin (Recommended)" "legcord-bin" "dissent-bin")"
case "$sel" in
    1) PKG="serein-bin" ;;
    2) PKG="legcord-bin" ;;
    3) PKG="dissent-bin" ;;
    *) PKG="" ;;
esac
if [ -n "$PKG" ]; then
    info "Installing $PKG via trizen..."
    aur_install "$PKG" && ok "$PKG installed." || warn "Failed to install $PKG."
else
    ok "Skipping Discord client."
fi

PKG=""
sel="$(choose_one "Which music streaming app do you want?" "simpmusic-bin (Recommended)" "limusic-bin")"
case "$sel" in
    1) PKG="simpmusic-bin" ;;
    2) PKG="limusic-bin" ;;
    *) PKG="" ;;
esac
if [ -n "$PKG" ]; then
    info "Installing $PKG via trizen..."
    aur_install "$PKG" && ok "$PKG installed." || warn "Failed to install $PKG."
else
    ok "Skipping music app."
fi

PKG=""
sel="$(choose_one "Which office suite do you want?" "onlyoffice-bin (Recommended)" "openoffice-bin")"
case "$sel" in
    1) PKG="onlyoffice-bin" ;;
    2) PKG="openoffice-bin" ;;
    *) PKG="" ;;
esac
if [ -n "$PKG" ]; then
    info "Installing $PKG via trizen..."
    aur_install "$PKG" && ok "$PKG installed." || warn "Failed to install $PKG."
else
    ok "Skipping office suite."
fi

PKG=""
sel="$(choose_one "Which code editor do you want?" "vscodium-bin (Recommended)" "lapce-git (No -bin)")"
case "$sel" in
    1) PKG="vscodium-bin" ;;
    2) PKG="lapce-git" ;;
    *) PKG="" ;;
esac
if [ -n "$PKG" ]; then
    info "Installing $PKG via trizen..."
    aur_install "$PKG" && ok "$PKG installed." || warn "Failed to install $PKG."
else
    ok "Skipping code editor."
fi

step "Optional Components"

info "Setting up printer support (optional)..."
INSTALL_CUPS=false
if confirm "Install printer support (CUPS + network discovery)?"; then
    INSTALL_CUPS=true
    sudo pacman -S --needed --noconfirm cups cups-pdf avahi nss-mdns \
        gutenprint foomatic-db foomatic-db-ppds system-config-printer

    info "Configuring mDNS host resolution for network printer discovery..."
    if ! grep -q "mdns_minimal" /etc/nsswitch.conf; then
        if confirm "Modify /etc/nsswitch.conf to enable .local hostname resolution (required for network printers)?"; then
            sudo cp /etc/nsswitch.conf "/etc/nsswitch.conf.bak.$(date +%s)"
            sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
            ok "nsswitch.conf updated. A backup was saved."
        else
            warn "Skipping nsswitch.conf modification. Network printer discovery may not work."
        fi
    else
        ok "mDNS resolution already configured in /etc/nsswitch.conf."
    fi

    sudo systemctl enable --now cups.service avahi-daemon.service
    sudo cupsctl WebInterface=yes
    ok "Printer support ready."
fi

info "Installing Flatpak + Flathub (optional)..."
if confirm "Install Flatpak + Flathub?"; then
    sudo pacman -S --needed --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ok "Flatpak and Flathub configured."
fi

setup_all_dotfiles
finish_install
