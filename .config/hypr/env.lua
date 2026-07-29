-- Environment Variables
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor
hl.env("XCURSOR_SIZE", "24")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
-- WLR_NO_HARDWARE_CURSORS removed: it is a wlroots variable, and Hyprland no
-- longer uses wlroots -- 0.55.4 ignores it entirely. Cursor behaviour is set
-- via the cursor block in appearance.lua.

-- Wayland
hl.env("XDG_SESSION_TYPE", "wayland")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- Java
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- XDG
hl.env("XDG_MENU_PREFIX", "arch-")

-- MangoHud FPS/mem overlay for all Vulkan apps (i.e. games). Session-wide so it
-- survives Steam re-exec'ing itself, which bypasses the .desktop wrapper. This
-- var is Vulkan-only, so GL desktop apps (kitty, firefox) are unaffected.
hl.env("MANGOHUD", "1")
