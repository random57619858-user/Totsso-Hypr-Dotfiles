# Totsso-Hypr-Dotfiles

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)

Una configuración de Hyprland **exclusiva para Arch Linux y sus derivadas** (como CachyOS o EndeavourOS). 

Este dotfile ya no es un simple tema estático de Gruvbox: ahora es un **escritorio dinámico**. Extrae la paleta de colores de tu fondo de pantalla (ya sea una imagen o un video) y la aplica en tiempo real a los bordes de Hyprland, Waybar, Kitty, Rofi y la pantalla de bloqueo usando **Matugen**.

> **Nota sobre otras distros:** Las versiones anteriores para Ubuntu, Debian, Solus y openSUSE han sido descontinuadas. Este repositorio ahora aprovecha las ventajas de `pacman`, `yay` y el ecosistema de Arch para funcionar al 100%.

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/2836ee20-77c3-4240-a4bd-bced0a728471" />

---

## Novedades (v4.5)

- **Soporte de Fondos Animados:** Utiliza `mpvpaper` para reproducir videos (`.mp4`, `.webm`, `.mkv`) como fondo de pantalla.
- **Tematización Dinámica (Material You):** Usa `matugen` para generar paletas de colores a partir de tus fondos. Si usas un video, el script extrae automáticamente el primer frame con `ffmpeg` para calcular los colores.
- **Integración Total:** Los colores cambian automáticamente en:
  - Bordes de ventanas de Hyprland.
  - Waybar (barra de estado).
  - Kitty (terminal).
  - Rofi (lanzador de aplicaciones).
  - Hyprlock (pantalla de bloqueo).

---

## 📜 Instalación

### Requisitos previos
- Una instalación limpia de **Arch Linux** o derivadas (CachyOS, EndeavourOS, etc.).
- `git` y `sudo` instalados.
- Conexión a internet.

### Paso 1: Clonar el repositorio

Ejecuta esto en tu terminal:

```bash
git clone https://github.com/random57619858-user/Totsso-Hypr-Dotfiles
cd Totsso-Hypr-Dotfiles
```
Luego ejecuta:

```bash
chmod +x arch-install.sh
./arch-install.sh
```

 Paquetes que instala
Entorno Base (Wayland)

    Hyprland — Compositor.

    Waybar — Barra de estado.

    Rofi — Lanzador de aplicaciones.

    Kitty — Terminal.

    SwayNC / Dunst — Notificaciones.

    Cava — Visualizador de audio.

Fondos y Tematización

    Hyprpaper — Fondos estáticos.

    mpvpaper — Fondos animados (video).

    ffmpeg — Extracción de frames para Matugen.

    matugen — Generación de paletas Material You.


Utilidades del Sistema

    GDM — Display Manager.

    Wlogout — Menú de apagado.

    Hypridle / Hyprlock — Inactividad y bloqueo.

    Cliphist — Historial del portapapeles.

    Grim + Slurp + wl-clipboard — Capturas de pantalla.

    PipeWire + WirePlumber — Servidor de audio.

Keybindings (Atajos Principales)
```
Atajo	Acción
SUPER + Q	Abrir terminal (Kitty)
SUPER + D	Lanzador de aplicaciones (Rofi)
SUPER + W	Selector de Wallpaper (Imagen/Video)
SUPER + C	Cerrar ventana activa
SUPER + V	Alternar ventana flotante
SUPER + A	Historial de portapapeles
SUPER + L	Bloquear pantalla (Hyprlock)
SUPER + 1-0	Cambiar de Workspace
SUPER + SHIFT + 1-0	Enviar ventana a Workspace
SUPER + SHIFT + E	Menú de energía (Wlogout)
SUPER + Print	Screenshot
```

Respaldos

El instalador realiza un respaldo preventivo en una carpeta backup/ dentro del repositorio antes de tocar cualquier archivo en ~/.config/. También respalda /etc/nsswitch.conf antes de configurar mDNS.

No es el mejor dotfile del mundo, pero ahora es dinámico, animado y espero que te guste :)
