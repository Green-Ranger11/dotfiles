-- Appearance Configuration
-- General, decoration, animations, cursor, and group settings

hl.config({
    general = {
        gaps_in     = 10,
        gaps_out    = 20,
        border_size = 2,
        col = {
            active_border   = "0xffcba6f7",
            inactive_border = "0xff313244",
        },
        layout           = "master",
        resize_on_border = true,
    },

    group = {
        col = {
            border_active          = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
            border_inactive        = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
            border_locked_active   = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
            border_locked_inactive = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
        },
    },

    decoration = {
        rounding = 1,

        blur = {
            enabled           = true,
            size              = 5,
            passes            = 1,
            new_optimizations = true,
        },
    },

    cursor = {
        -- Hardware cursors are still glitchy on the NVIDIA-driven HDMI output even
        -- on driver 610 (laggy/jumpy cursor on the external monitor), so force
        -- software cursors. Known trade-off: Hyprland then never reprograms the
        -- hardware cursor plane, so a cursor left on screen by plasmalogin can sit
        -- frozen for the session -- if that artifact returns, it needs a separate
        -- fix (clear the plane at login) rather than re-enabling HW cursors.
        no_hardware_cursors = true,
    },

    animations = {
        enabled = true,
    },
})

hl.curve("wind",   { type = "bezier", points = { { 0.05, 0.9 },  { 0.1, 1.05 } } })
hl.curve("winIn",  { type = "bezier", points = { { 0.1, 1.1 },   { 0.1, 1.1 }  } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 },  { 0, 1 }      } })
hl.curve("liner",  { type = "bezier", points = { { 1, 1 },       { 1, 1 }      } })

hl.animation({ leaf = "windows",     enabled = true, speed = 6,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,  bezier = "winIn",   style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,  bezier = "winOut",  style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 1,  bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner",   style = "loop" })
hl.animation({ leaf = "fade",        enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "wind" })
