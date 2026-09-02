-- Window Rules Configuration
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Path of Exile - Awakened PoE Trade overlay
hl.window_rule({ name = "apt-tag",     match = { title = "Awakened PoE Trade" }, tag = "+apt" })
hl.window_rule({ name = "apt-style", match = { tag = "apt" },
    float       = true,
    no_blur     = true,
    no_focus    = true,
    no_shadow   = true,
    border_size = 0,
    size        = "100% 100%",
    center      = true,
})

-- Path of Exile - main game
hl.window_rule({ name = "poe-tag-title", match = { title = "Path of Exile" },     tag = "+poe" })
hl.window_rule({ name = "poe-tag-class", match = { class = "steam_app_238960" },  tag = "+poe" })
hl.window_rule({ name = "poe-float",     match = { tag = "poe" },                 float = true })

-- Wakfu
hl.window_rule({ name = "wak-tag",  match = { title = "WAKFU" }, tag = "+wak" })
hl.window_rule({ name = "wak-tile", match = { tag = "wak" },     tile = true, workspace = "5" })

-- Firefox Picture-in-Picture
hl.window_rule({ name = "ff-pip", match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
    keep_aspect_ratio = true,
    border_size       = 0,
    pin               = true,
    float             = true,
})
hl.window_rule({ name = "ff-main-pin", match = { class = "^(firefox)$", title = "^(Firefox)$" },
    pin   = true,
    float = true,
})

-- Dofus
hl.window_rule({ name = "dofus-tag",  match = { title = "Dofus" }, tag = "+dofus" })
hl.window_rule({ name = "dofus-tile", match = { tag = "dofus" },   tile = true })

-- Yazi floating file manager
hl.window_rule({ name = "yazi-float", match = { class = "^(yazi-float)$" }, float = true })

-- swaync notification slide-in from right
hl.layer_rule({ name = "notif-slide", match = { namespace = "notifications" }, animation = "slide right" })

-- Remmina: session windows fill the workspace, main window stays behind.
-- Both windows share class org.remmina.Remmina; only the session window has
-- initial_title "Remmina" (its title becomes the profile name), while the
-- main window's is "Remmina Remote Desktop Client". maximize (not fullscreen)
-- keeps waybar visible and draws above the floating main window, which is
-- there again when the session closes.
hl.window_rule({
    name  = "remmina-session-maximize",
    match = { class = "^(org\\.remmina\\.Remmina)$", initial_title = "^(Remmina)$" },
    maximize = true,
})
