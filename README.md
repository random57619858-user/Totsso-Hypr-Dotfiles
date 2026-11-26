<div align="center">

# Totsso-Hypr-Dotfiles (v5.0)

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/5f750989-8207-475a-ac84-5e0a143a488f" />

ATENCION:  eh detectado un error que no permite instalar el dotfile, esta relacionado con trizen, pronto sera parcheado

Una configuración de **Hyprland** dinámica, animada y exclusiva para **Arch Linux y sus derivadas** (como CachyOS o EndeavourOS). 

*Olvídate de los temas estáticos.* Este dotfile extrae la paleta de colores de tu fondo de pantalla (ya sea una imagen o un video) y la aplica en tiempo real a los bordes de Hyprland, Waybar, Kitty, Rofi, Mako e Hyprlock usando **Matugen**.

</div>

---

##  Novedades (v5.0)

- **Notificaciones Dinámicas con Mako:** Integración completa con `mako`, tematizado automáticamente mediante `matugen` para adaptarse a tu fondo de pantalla.
- **Modo No Molestar (DND):** Módulo interactivo en Waybar que silencia y desactiva las notificaciones con un solo clic, cambiando de icono y color según el estado.
- **Waybar Rediseñada y Tooltips Enriquecidos:** Barra superior optimizada y estilizada. Los módulos de CPU, RAM, MPRIS y Reloj muestran información detallada e interactiva al pasar el ratón (incluyendo calendario completo).
- **Soporte de Fondos Animados:** Integración nativa con `mpvpaper` para reproducir videos (`.mp4`, `.webm`, `.mkv`) como fondo de pantalla.
- **Tematización Dinámica (Material You):** Los colores cambian automáticamente en bordes de ventanas, barra, terminal, lanzador, notificaciones y pantalla de bloqueo.

---

##  Instalación

### Requisitos previos
- Una instalación limpia de **Arch Linux** o derivadas (CachyOS, EndeavourOS, etc.).
- `git` y `sudo` instalados.
- Conexión a internet.

### Clonar el repositorio

Ejecuta esto en tu terminal:

```bash
git clone https://github.com/random57619858-user/Totsso-Hypr-Dotfiles
cd Totsso-Hypr-Dotfiles
```

### Ejecutar el instalador

El script se encargará de instalar los paquetes oficiales y de AUR (`mpvpaper`, `wlogout`), desplegar las configuraciones y crear los respaldos necesarios. Usa **trizen** como helper de AUR

```bash
chmod +x arch-install.sh
./arch-install.sh
```

---

## 🛠️ ¿Qué instala?

###  Entorno Base (Wayland)
| Paquete | Función |
| :--- | :--- |
| **Hyprland** | Compositor de ventanas. |
| **Waybar** | Barra de estado con DND y tooltips avanzados. |
| **Rofi** | Lanzador de aplicaciones y selector de wallpapers. |
| **Kitty** | Terminal. |
| **Cava** | Visualizador de audio. |

###  Tematización y Notificaciones
| Paquete | Función |
| :--- | :--- |
| **Hyprpaper** | Fondos estáticos. |
| **mpvpaper** | Fondos animados (video). |
| **ffmpeg** | Extracción de frames para Matugen. |
| **matugen** | Generación de paletas Material You. |
| **Mako** | Gestor de notificaciones dinámicas. |

###  Utilidades del Sistema
| Paquete | Función |
| :--- | :--- |
| **GDM** | Display Manager (gestor de inicio). |
| **Wlogout** | Menú de apagado/energía. |
| **Hypridle / Hyprlock** | Gestión de inactividad y bloqueo. |
| **Cliphist** | Historial del portapapeles. |
| **Grim + Slurp** | Capturas de pantalla. |
| **PipeWire + WirePlumber** | Servidor de audio. |

---

##  Optional Apps (instalación interactiva)

Durante la instalación, el script te preguntará qué aplicaciones opcionales quieres instalar (todas vía **trizen** desde AUR). Puedes elegir **0) Skip** para no instalar ninguna:

- **Navegador:** `brave-bin`, `ungoogled-chromium`, `zen-browser-bin`
- **Cliente de Discord:** `serein-bin`, `legcord-bin`, `dissent-bin`
- **Música streaming:** `simpmusic-bin`, `limusic-bin`
- **Suite de ofimática:** `onlyoffice-bin`, `openoffice-bin`
- **Editor de código:** `vscodium-bin`, `lapce-git`

---

## ⌨️ Keybindings (Atajos Principales)

| Atajo | Acción |
| :--- | :--- |
| `SUPER + Q` | Abrir terminal (Kitty) |
| `SUPER + D` | Lanzador de aplicaciones (Rofi) |
| `SUPER + W` | **Selector de Wallpaper (Imagen/Video)** |
| `SUPER + C` | Cerrar ventana activa |
| `SUPER + V` | Alternar ventana flotante |
| `SUPER + A` | Historial de portapapeles |
| `SUPER + L` | Bloquear pantalla (Hyprlock) |
| `SUPER + 1-0` | Cambiar de Workspace |
| `SUPER + SHIFT + 1-0` | Enviar ventana a Workspace |
| `SUPER + SHIFT + E` | Menú de energía (Wlogout) |
| `SUPER + Print` | Captura de pantalla |

---

##  Respaldos

El instalador es seguro. Antes de tocar cualquier archivo en `~/.config/`, te preguntará si deseas respaldar tu configuración actual en una carpeta `backup/` dentro del repositorio. Además, respalda `/etc/nsswitch.conf` antes de configurar mDNS para impresoras en red.

---

<div align="center">
  <i>No es el mejor dotfile del mundo, pero ahora es dinámico, animado y espero que te guste :)</i>
</div>
