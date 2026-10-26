# Totsso-Hypr-Dotfiles

A basic Hyprland dotfile setup for **Debian**, **Ubuntu**, **Solus**, and **openSUSE Tumbleweed**. It sets up a minimal, gruvbox-themed desktop: compositor, bar, launcher, terminal, wallpaper and a few tools so you can log in after a reboot and just use it.

<img width="1366" height="768" alt="imagen" src="https://github.com/user-attachments/assets/af45162d-e01c-4bf4-ae1d-ac44420ef289" />


## ⚠️ About the scripts

There are **five** different install scripts at the root of this repository. Pick the one for your system:

| Script | Distro | Notes |
|--------|--------|-------|
| `debian-install.sh` | Debian | Switches `/etc/apt/sources.list` to **Debian unstable (Sid)**. Hyprland and some of its dependencies are only available there, so there's no way around it if you want a modern setup on Debian. Sid is a rolling release. Breakage happens. That's the trade-off. If you're not comfortable with that, this script isn't for you D: |
| `ubuntu-install.sh` | Ubuntu | Installs Hyprland from the `cppiber` repository. Also gives you the option to completely remove Snap at the beginning. |
| `solus-install.sh` | Solus | Uses `eopkg` and works out of the box without needing to change repositories. |
| `opensuse-tumbleweed-install.sh` | openSUSE Tumbleweed | Uses `zypper` and works out of the box. Hyprland is available in the official repos, so no extra repositories are needed. The script also takes care of a few openSUSE-specific quirks (firewall zone, `nss-mdns` setup for printer discovery, etc.). |

## Requirements

- A **Debian**, **Ubuntu**, **Solus**, or **openSUSE Tumbleweed** installation

- `git` and `sudo` installed

- A working internet connection


## Installation

First, clone the repository:

```bash
git clone [https://github.com/random57619858-user/Totsso-Hypr-Dotfiles](https://github.com/random57619858-user/Totsso-Hypr-Dotfiles)
cd Totsso-Hypr-Dotfiles
```

Then, run the script for your specific distribution:

<details>
<summary><b>Ubuntu</b></summary>

```bash
chmod +x ubuntu-install.sh
./ubuntu-install.sh
```

</details>

<details>
<summary><b>Debian</b></summary>

```bash
chmod +x debian-install.sh
./debian-install.sh
```

</details>

<details>
<summary><b>Solus</b></summary>

```bash
chmod +x solus-install.sh
./solus-install.sh
```

</details>

<details>
<summary><b>openSUSE Tumbleweed</b></summary>

```bash
chmod +x opensuse-tumbleweed-install.sh
./opensuse-tumbleweed-install.sh
```

</details>

## What it installs

### Core desktop

- **Hyprland** — compositor

- **Waybar** — status bar

- **Rofi** — app launcher and wallpaper picker

- **Kitty** — terminal

- **Cava** — audio visualizer

- **Hyprpaper** — wallpaper daemon


### Extra tools

- **GDM** — login manager

- **Wlogout** — power menu

- **Hypridle + Hyprlock** — idle and lock screen

- **Cliphist** — clipboard history

- **Grim + Slurp + wl-clipboard** — screenshots

- **PipeWire + WirePlumber** — audio

- **XDG Desktop Portal Hyprland** — screen sharing

- **Hyprpolkitagent** — auth dialogs

- **Fluent icon theme**

- **JetBrainsMono Nerd Font**


### Optional (asked during install)

- Printer support (CUPS)

- Flatpak + Flathub

- Steam, OnlyOffice, Discord, VSCodium, OBS Studio


## Keybindings

| Keybind | Action |
|---------|--------|
| `SUPER + Q` | Open kitty |
| `SUPER + D` | App launcher (rofi) |
| `SUPER + W` | Change wallpaper |
| `SUPER + C` | Close window |
| `SUPER + V` | Toggle floating window |
| `SUPER + A` | Clipboard history |
| `SUPER + L` | Lock screen |
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + SHIFT + E` | Power menu (wlogout) |
| `SUPER + Print` | Screenshot |

## Backups

The script asks before overwriting anything in `~/.config/`. If you say yes, a copy gets saved to `backup/` inside this repo. Your `sources.list` can also be backed up before it's replaced (Debian/Ubuntu only).

It's not the best dotfile, but I hope you like it :)

## Rofi: 

<img width="760" height="380" alt="imagen" src="https://github.com/user-attachments/assets/7fb0b784-571d-45ea-a46c-1a262ae832ec" />

## Waybar 

<img width="1366" height="62" alt="imagen" src="https://github.com/user-attachments/assets/878e87ce-cc33-495a-a0a9-e556a3f2875e" />
