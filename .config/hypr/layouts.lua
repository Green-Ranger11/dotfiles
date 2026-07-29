-- Layout Configuration
-- Dwindle, master, and misc settings

hl.config({
    dwindle = {
        preserve_split = true,
    },

    -- master: defaults are fine, nothing configured.
    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        animate_manual_resizes   = true,
        enable_swallow           = true,
        focus_on_activate        = true, -- focus/raise windows that request activation (e.g. clicking a KMail notification)
    },
})
