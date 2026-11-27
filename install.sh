#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR
export SCRIPTS_DIR="$DOTFILES_DIR/scripts"

exec > >(tee -a "$DOTFILES_DIR/install.log") 2>&1

source "$SCRIPTS_DIR/common.sh"

trap 'fail "Error on line $LINENO. Check $DOTFILES_DIR/install.log for details."' ERR

banner

if [ "$(id -u)" -eq 0 ]; then
    fail "Do not run this script as root. Use your normal user (sudo is requested internally)."
    exit 1
fi

OS_ID="unknown"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-unknown}"
fi

case "$OS_ID" in
    arch|endeavouros|manjaro|cachyos|garuda)
        ok "Arch-based system detected: ${PRETTY_NAME:-$OS_ID}"
        ;;
    *)
        if [[ "${ID_LIKE:-}" == *arch* ]]; then
            ok "Arch-based system detected: ${PRETTY_NAME:-$OS_ID}"
        else
            fail "Detected system: ${PRETTY_NAME:-$OS_ID}"
            if ! confirm "This script targets Arch Linux and derivatives. Continue anyway?"; then
                fail "Installation cancelled by user."
                exit 1
            fi
        fi
        ;;
esac

MISSING_TOOLS=()
for cmd in git curl wget unzip; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING_TOOLS+=("$cmd")
done

if [ "${#MISSING_TOOLS[@]}" -gt 0 ]; then
    info "Installing missing required tools: ${MISSING_TOOLS[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_TOOLS[@]}"
fi

for cmd in git curl wget unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "Missing required command: $cmd"
        exit 1
    fi
done

source "$SCRIPTS_DIR/arch.sh"
