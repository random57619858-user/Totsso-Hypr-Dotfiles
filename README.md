<div align="center">

# Totsso-Hypr-Dotfiles (v6.0)

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/5f750989-8207-475a-ac84-5e0a143a488f" />

Un dotfile dinámico que se integra con **Hyprland**, Waybar, Kitty, Rofi, Mako y Matugen.
Pensado para **Arch Linux y sus derivadas** (CachyOS, EndeavourOS…), con **systemd**.

*Olvídate de los temas estáticos.* La paleta se extrae de tu fondo de pantalla
y se aplica en tiempo real a los bordes de Hyprland, Waybar,
Kitty, Rofi, Mako, Wlogout, Hyprlock y a los colores nombrados de GTK3/GTK4.

</div>

---

## Novedades (v6.0)

**Lanzador unificado** — Un solo `SUPER + D` abre Rofi con tres apartados: **apps** (drun), **wallpapers** y **clipboard**. Se cambian con las flechas izquierda/derecha o clicando los botones de arriba. Campo de búsqueda tipo pastilla, filas sin cebra, resaltado con `primary-container` y scrollbar fino, todo derivado de Matugen.

**Portapapeles visual** — El historial de `cliphist` se explora dentro del mismo lanzador con miniaturas reales de las imágenes copiadas, vista previa de una línea para texto y borrado con `Ctrl+X`. Al copiar una entrada se muestra una notificación breve y las imágenes se restauran con su tipo MIME original (`image/png`).

**Selector de wallpapers** — Cada imagen de `~/Pictures` aparece con su miniatura (cacheada en `~/.cache/totsso-wallpapers`), marca `●` en la que está activa y aplica Matugen al elegirla. Las fotos enormes (8K) también generan miniatura. El fondo elegido se guarda en `hypr/hyprpaper.conf`, así que **hyprpaper lo restaura solo** en cada arranque aunque la sesión tarde en montar la barra.

**Menú de apagado con wlogout** — Cuadrícula de tarjetas redondeadas (cerrar sesión, suspender, reiniciar, apagar) tematizada con Matugen. Si `wlogout` no está instalado, cae al menú de Rofi.

**Waybar ampliada** — Bloque deslizante `Info` con CPU, RAM y temperatura, píldoras independientes de volumen, red y batería, SSID completo de la red y controles de MPRIS con clic y scroll.

**Modo No Molestar** — Módulo interactivo en Waybar que silencia Mako con un clic, cambiando icono y color según el estado.

**Menú deslizante de apps** — Una píldora con la palabra `Apps` entre los workspaces y el cava que, al pasar el ratón, se desliza hacia la derecha y muestra los iconos reales de las apps abiertas, estén en el workspace que estén. Clic para activar, clic central para cerrar. Reemplaza al taskbar fijo de la barra.

**Bloque deslizante Info** — CPU, RAM y temperatura viven dentro de un desplegable con la palabra `Info`, junto a las píldoras de volumen, red y batería. Al pasar el ratón se despliega hacia la izquierda y deja la barra más despejada.

**Tooltips enriquecidos** — CPU, RAM, MPRIS y Reloj muestran información detallada al pasar el ratón, incluyendo un calendario completo.

**Integración Matugen completa** — Bordes activos en degradado, sombra, Waybar, Kitty, Rofi, Mako, Wlogout, Hyprlock y GTK3/GTK4/libadwaita.

**Notificaciones dinámicas con Mako** — Urgencias (`critical`/`low`), modo No Molestar y recarga automática al cambiar de paleta.

---

## Instalación

### Requisitos

- Instalación limpia de **Arch Linux** o derivada

- **Hyprland 0.55 o superior**: la configuración es **Lua nativo** (`hyprland.lua`), el formato que Hyprland usa por defecto desde la 0.55.

- Conexión a internet.

> No necesitas instalar nada más: si falta `git`, `curl`, `wget` o `unzip`, el instalador los instala primero (requiere `sudo`).

### Clonar y ejecutar

```bash
git clone https://github.com/random57619858-user/Totsso-Hypr-Dotfiles
cd Totsso-Hypr-Dotfiles
./install.sh
```

> Añade `--yes` para el modo desatendido: acepta todas las confirmaciones e instala la **opción recomendada** de cada app opcional.

> El instalador compila **`matugen`** desde el código fuente con `cargo install --locked` y usa **trizen** como helper de AUR para `wlogout` y las apps opcionales.

---

## Componentes

### Entorno base

- **Hyprland** — Compositor Wayland configurado en **Lua nativo** (dwindle, animaciones `fluidEase`, blur y opacidad).

- **Waybar** — Barra de estado con workspaces, menú deslizante de apps, cava, MPRIS, bloque deslizante de Info, red y sesión.

- **Rofi** — Lanzador unificado (apps, wallpapers, clipboard) con tarjetas redondeadas.

- **Kitty** — Terminal.

- **Fish** — Shell interactiva (opcional, se desactiva el saludo).

- **Cava** — Visualizador de audio integrado en Waybar.

### Tematización y fondos

- **Hyprpaper** — Gestión de fondos estáticos, el nativo de Hyprland.

- **Matugen** — Paletas Material You.

- **Mako** — Notificaciones dinámicas.

### Utilidades

- **Cliphist** — Historial del portapapeles.

- **Grim + Slurp** — Capturas de pantalla optimizadas para tuberías.

- **PipeWire + WirePlumber** — Servidor de audio (servicios de usuario de systemd).

- **hyprlock** — Bloqueo de pantalla con la paleta del fondo.

- **hyprpolkitagent** — Agente de autenticación.

- **wlogout** — Menú de apagado tematizado.

- **Fastfetch** — Resumen del sistema con los colores del fondo.

- **GDM** — Gestor de inicio (opcional).

- **CUPS** — Soporte de impresoras (opcional).

- **Flatpak** — Repositorio Flathub configurado (opcional).

> El audio se gestiona con **systemd** en el usuario: `pipewire.socket`, `pipewire-pulse.socket` y `wireplumber.service`. Los servicios de sistema (GDM, CUPS, Avahi) se habilitan con `systemctl enable --now`.

---

## Optional Apps (instalación interactiva)

Durante la instalación el script te preguntará qué aplicaciones opcionales quieres instalar (todas vía **trizen** desde AUR). Puedes elegir **0) Skip** para no instalar ninguna:

- **Navegador:** `brave-bin`, `ungoogled-chromium`, `zen-browser-bin`
- **Cliente de Discord:** `serein-bin`, `legcord-bin`, `dissent-bin`
- **Música streaming:** `simpmusic-bin`, `limusic-bin`
- **Suite de ofimática:** `onlyoffice-bin`, `openoffice-bin`
- **Editor de código:** `vscodium-bin`, `lapce-git`

---

## Atajos principales

| Atajo | Acción |
| :--- | :--- |
| `SUPER + Q` | Terminal (Kitty) |
| `SUPER + D` | Lanzador unificado: apps / wallpapers / clipboard (`←` `→` cambia de apartado) |
| `SUPER + W` | Selector de wallpaper |
| `SUPER + A` | Portapapeles (dentro del lanzador) |
| `SUPER + C` | Cerrar ventana activa |
| `SUPER + V` | Alternar flotante |
| `SUPER + M` | Reproducir / pausar |
| `SUPER + L` | Bloquear pantalla con `hyprlock` |
| `SUPER + SHIFT + E` / `X` | Menú de apagado (wlogout) |
| `SUPER + 1-0` | Cambiar de workspace |
| `SUPER + SHIFT + 1-0` | Mover ventana a workspace |
| `SUPER + Print` | Captura de pantalla y copiado al portapapeles |
| `SUPER + arrastrar` | Mover ventana |
| `SUPER + clic derecho + arrastrar` | Redimensionar ventana |

---

## Estructura del repositorio

```text
Totsso-Hypr-Dotfiles/
├── install.sh
├── scripts/
│   ├── common.sh
│   └── arch.sh
├── hypr/
│   ├── hyprland.lua       # configuración activa (Lua nativo)
│   ├── hyprlock.conf
│   ├── player.sh
│   └── scripts/
│       ├── totsso-lock.sh
│       ├── totsso-power.sh
│       └── totsso-theme-mode.sh
├── waybar/  (config, style.css, cava.sh, net.sh, temp.sh, dnd.sh)
├── rofi/    (config.rasi, launcher.sh, clipboard.sh, wallpaper.sh)
├── matugen/ (config.toml + templates)
├── mako/
├── kitty/
├── wlogout/ (layout)
├── fastfetch/
└── wallpapers/
```

## Respaldos y logs

Antes de modificar cualquier archivo en `~/.config/`, el instalador pregunta si deseas respaldar la configuración actual en `backup/`.

Toda la actividad se registra en `install.log`. Si se produce un error, el script indica la línea exacta y sugiere revisar ese archivo.

Además, respalda `/etc/nsswitch.conf` antes de configurar mDNS para impresoras en red.

---

<div align="center">
  <i>No es el mejor dotfile del mundo pero espero que te guste :)</i>
</div>
