hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "$HOME/.config/rofi/launcher.sh"
local scripts     = "$HOME/.config/hypr/scripts"
local wallpaper   = "$HOME/.config/rofi/wallpaper.sh"

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("sleep 2 && " .. wallpaper .. " restore")
end)

hl.env("HYPRCURSOR_THEME", "Fluent-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "24")

pcall(require, "colors")

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 16,

        border_size = 2,

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 2,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.8,

        shadow = {
            enabled      = true,
            range        = 5,
            render_power = 3,
        },

        blur = {
            enabled        = true,
            size           = 3,
            passes         = 4,
            vibrancy       = 0.1,
            ignore_opacity = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("fluidEase", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

hl.animation({ leaf = "global",      enabled = true, speed = 10, bezier = "fluidEase" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "fluidEase" })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "fluidEase" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 7,  bezier = "fluidEase", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "fluidEase", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6,  bezier = "fluidEase" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 8,  bezier = "fluidEase" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 8,  bezier = "fluidEase" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 7,  bezier = "fluidEase", style = "slide" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 7,  bezier = "fluidEase", style = "slide" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 7,  bezier = "fluidEase", style = "slide" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

hl.config({
    input = {
        kb_layout  = "latam",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",     hl.dsp.exec_cmd(wallpaper))
hl.bind(mainMod .. " + C",     hl.dsp.window.close())
hl.bind(mainMod .. " + V",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd(scripts .. "/totsso-lock.sh"))
hl.bind(mainMod .. " + A",     hl.dsp.exec_cmd(menu .. " -show clipboard"))
hl.bind(mainMod .. " + M",     hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" -t png - | wl-copy --type image/png'))

hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd(scripts .. "/totsso-power.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scripts .. "/totsso-power.sh"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name  = "nautilus-opaque",
    match = { class = "org.gnome.Nautilus" },

    opaque = true,
})
