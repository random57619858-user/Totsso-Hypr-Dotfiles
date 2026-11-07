<div align="center">

#  Totsso-Hypr-Dotfiles (v4.5)

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/1fa6bccc-d3e4-45bd-8dd5-0528b57836e1" />


<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/9f6c778b-12b9-4382-b553-8e827c035aac" />



Una configuración de **Hyprland** exclusiva para **Arch Linux y sus derivadas** (como CachyOS o EndeavourOS). 

*Olvída de los temas estáticos.* Este dotfile convierte tu escritorio en un entorno **dinámico**. Extrae la paleta de colores de tu fondo de pantalla (ya sea una imagen o un video) y la aplica en tiempo real a los bordes de Hyprland, Waybar, Kitty, Rofi e Hyprlock usando **Matugen**.

</div>

>  **Nota sobre otras distros:** Las versiones anteriores para Ubuntu, Debian, Solus y openSUSE han sido descontinuadas. Este repositorio ahora aprovecha el ecosistema de Arch (`pacman`, `yay`, AUR) para ofrecer la mejor experiencia sin limitaciones, esas distros tienen soporte de paquetes inexistentes o muy limitado y se me hizo inviable aplicar estas nuevas mejoras, asi que ahora solo hay para Arch :(

---

##  Novedades

-  **Soporte de Fondos Animados:** Integración nativa con `mpvpaper` para reproducir videos (`.mp4`, `.webm`, `.mkv`) como fondo de pantalla.
-  **Tematización Dinámica (Material You):** Usa `matugen` para generar paletas de colores a partir de tus fondos. Si eliges un video, el script extrae automáticamente el primer frame con `ffmpeg` para calcular los colores.
-  **Integración Total:** Los colores cambian automáticamente en:
  -  Bordes de ventanas de **Hyprland**.
  -  Barra de estado **Waybar**.
  -  **Kitty** (terminal).
  -  **Rofi** (lanzador de aplicaciones y selector de fondos).
  -  **Hyprlock** (pantalla de bloqueo con fondo dinámico).

---

##  Instalación

###  Requisitos previos
- Una instalación limpia de **Arch Linux** o derivadas (CachyOS, EndeavourOS, etc.).
- `git` y `sudo` instalados.
- Conexión a internet.

###  Clonar el repositorio

Ejecuta esto en tu terminal:

```bash
git clone https://github.com/random57619858-user/Totsso-Hypr-Dotfiles
cd Totsso-Hypr-Dotfiles
```

###  Ejecutar el instalador

El script se encargará de instalar los paquetes oficiales, los de AUR (`matugen`, `mpvpaper`), desplegar las configuraciones y crear los respaldos necesarios.

```bash
chmod +x arch-install.sh
./arch-install.sh
```

---

##  ¿Qué instala?

### 🖥️ Entorno Base (Wayland)
| Paquete | Función |
| :--- | :--- |
| **Hyprland** | Compositor de ventanas. |
| **Waybar** | Barra de estado. |
| **Rofi** | Lanzador de aplicaciones y selector de wallpapers. |
| **Kitty** | Terminal. |
| **Cava** | Visualizador de audio. |

###  Fondos y Tematización
| Paquete | Función |
| :--- | :--- |
| **Hyprpaper** | Fondos estáticos. |
| **mpvpaper** | Fondos animados (video). |
| **ffmpeg** | Extracción de frames para Matugen. |
| **matugen** | Generación de paletas Material You. |

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

##  Keybindings (Atajos Principales)

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
