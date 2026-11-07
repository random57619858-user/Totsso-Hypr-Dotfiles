# 🎨 Totsso-Hypr-Dotfiles

![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Solus](https://img.shields.io/badge/Solus-5294E2?style=for-the-badge&logo=solus&logoColor=white)
![openSUSE](https://img.shields.io/badge/openSUSE-73BA25?style=for-the-badge&logo=openSUSE&logoColor=white)

Una configuración de Hyprland sencilla con tema gruvbox para **Fedora**, **Debian**, **Ubuntu**, **Arch Linux**, **Solus** y **openSUSE Tumbleweed**. Deja el escritorio listo para usar: compositor, barra, lanzador, terminal, fondo de pantalla y las herramientas necesarias para que inicies sesión y te pongas a trabajar.

> ℹ️ **¿Y la version de BSD?** El port experimental para FreeBSD se ha movido a su propio repositorio. Esa versión contiene parches y ajustes específicos para hardware concreto, asi que no deberias instalarla en tu BSD principal. Puedes encontrarla aquí: [Free-BSD-Dotfile](https://github.com/random57619858-user/Free-BSD-Dotfile)

<img width="1366" height="768" alt="Totsso-Hypr-Dotfiles preview" src="https://github.com/user-attachments/assets/af45162d-e01c-4bf4-ae1d-ac44420ef289" />

---

## 📜 Sobre los scripts

En la raíz del repositorio hay **cinco** scripts de instalación. Elige el que corresponda a tu sistema:

| Script | Distro | Notas |
|--------|--------|-------|
| `debian-install.sh` | Debian | Cambia `/etc/apt/sources.list` a **Debian unstable (Sid)**. Hyprland y algunas dependencias solo están ahí, así que no hay forma de evitarlo si quieres un escritorio moderno en Debian. Sid es una rolling release: las roturas ocurren, ese es el precio. Si no te sientes cómodo con eso, este script no es para ti D: |
| `ubuntu-install.sh` | Ubuntu | Instala Hyprland desde el repositorio `cppiber`. También te ofrece eliminar Snap por completo al inicio. |
| `arch-install.sh` | Arch Linux | Usa `pacman` e instala `yay` automáticamente para traer las dependencias de Hyprland y LibreWolf desde AUR. Opcionalmente habilita `multilib` y configura `nss-mdns` para descubrir impresoras en red. |
| `solus-install.sh` | Solus | Usa `eopkg` y funciona sin tocar repositorios. |
| `opensuse-tumbleweed-install.sh` | openSUSE Tumbleweed | Usa `zypper` y funciona directamente. Hyprland está en los repositorios oficiales, así que no hacen falta repos extra. También resuelve algunas particularidades de openSUSE (zona del firewall, configuración de `nss-mdns` para impresoras, etc.). |

---

## ✅ Requisitos

- Una instalación de **Debian**, **Ubuntu**, **Arch Linux**, **Solus** o **openSUSE Tumbleweed**
- `git` y `sudo` instalados
- Conexión a internet

---

##  Instalación

###  Paso 1: Clonar el repositorio

**Ejecuta esto en tu terminal:**

    git clone https://github.com/random57619858-user/Totsso-Hypr-Dotfiles
    cd Totsso-Hypr-Dotfiles

###  Paso 2: Ejecutar el instalador

**Elige tu distribución y ejecuta el comando correspondiente:**

</details>

<details>
<summary><b>Ubuntu</b></summary>

**Ejecuta el instalador:**

    chmod +x ubuntu-install.sh
    ./ubuntu-install.sh

</details>

<details>
<summary><b>Debian</b></summary>

**Ejecuta el instalador:**

    chmod +x debian-install.sh
    ./debian-install.sh

</details>

<details>
<summary><b>Arch Linux</b></summary>

**Ejecuta el instalador:**

    chmod +x arch-install.sh
    ./arch-install.sh

</details>

<details>
<summary><b>Solus</b></summary>

**Ejecuta el instalador:**

    chmod +x solus-install.sh
    ./solus-install.sh

</details>

<details>
<summary><b>openSUSE Tumbleweed</b></summary>

**Ejecuta el instalador:**

    chmod +x opensuse-tumbleweed-install.sh
    ./opensuse-tumbleweed-install.sh

</details>

---

## 📦 Qué instala

### Escritorio principal

- **Hyprland** — compositor
- **Waybar** — barra de estado
- **Rofi** — lanzador de aplicaciones y selector de fondos
- **Kitty** — terminal
- **Cava** — visualizador de audio
- **Hyprpaper** — demonio de fondos de pantalla

### Herramientas extra

- **GDM** — gestor de inicio de sesión
- **Wlogout** — menú de apagado
- **Hypridle + Hyprlock** — inactividad y bloqueo de pantalla
- **Cliphist** — historial del portapapeles
- **Grim + Slurp + wl-clipboard** — capturas de pantalla
- **PipeWire + WirePlumber** — audio
- **XDG Desktop Portal Hyprland** — compartir pantalla
- **Hyprpolkitagent** — diálogos de autenticación
- **Tema de iconos Fluent**
- **JetBrainsMono Nerd Font**

### Opcional (se pregunta durante la instalación)

- Soporte de impresoras (CUPS)
- Flatpak + Flathub
- Steam, OnlyOffice, Discord, VSCodium, OBS Studio

---

## Atajos de teclado

| Atajo | Acción |
|-------|--------|
| `SUPER + Q` | Abrir kitty |
| `SUPER + D` | Lanzador de aplicaciones (rofi) |
| `SUPER + W` | Cambiar fondo de pantalla |
| `SUPER + C` | Cerrar ventana |
| `SUPER + V` | Alternar ventana flotante |
| `SUPER + A` | Historial del portapapeles |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + 1-0` | Cambiar de espacio de trabajo |
| `SUPER + SHIFT + 1-0` | Mover ventana a otro espacio de trabajo |
| `SUPER + SHIFT + E` | Menú de apagado (wlogout) |
| `SUPER + Print` | Captura de pantalla |

---

##  Copias de seguridad

El script pregunta antes de sobrescribir cualquier cosa en `~/.config/`. Si aceptas, guarda una copia en `backup/` dentro del repositorio. También puedes respaldar tu `sources.list` antes de reemplazarlo (solo Debian/Ubuntu). En Arch Linux se respalda `/etc/nsswitch.conf` antes de habilitar mDNS para impresoras.

---

No es el mejor dotfile del mundo, pero espero que te guste :)

## Rofi

<img width="760" height="380" alt="Rofi" src="https://github.com/user-attachments/assets/7fb0b784-571d-45ea-a46c-1a262ae832ec" />

## Waybar

<img width="1366" height="62" alt="Waybar" src="https://github.com/user-attachments/assets/878e87ce-cc33-495a-a0a9-e556a3f2875e" />
