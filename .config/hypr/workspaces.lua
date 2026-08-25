-- Workspace Configuration
-- Workspace assignments and monitor bindings

-- Window-to-workspace assignments (silent = don't switch to workspace)
hl.window_rule({ name = "ws-kitty",   match = { class = "^(kitty)$" },                       workspace = "2 silent" })
hl.window_rule({ name = "ws-firefox", match = { class = "^(firefox)$" },                     workspace = "3 silent" })
hl.window_rule({ name = "ws-vesktop", match = { class = "^(vesktop|Vesktop|VencordDesktop)$" }, workspace = "1 silent" })
-- Steam: main window + login/friends windows all use class "steam".
-- Game windows use class steam_app_<id> instead, so they need their own rules.
hl.window_rule({ name = "ws-steam",   match = { class = "^(steam)$" },                       workspace = "4 silent" })
-- Baldur's Gate 3 (Steam 1086940, runs under Proton/XWayland).
-- Class is the exe name, NOT steam_app_<id>: bg3 = Vulkan, bg3_dx11 = DirectX11.
-- Not silent: launching the game should actually take you to it.
hl.window_rule({ name = "ws-bg3",     match = { class = "^(bg3|bg3_dx11)$" },                workspace = "4" })
-- Lock the cursor inside the game window while it's focused, so it can't slip
-- onto the ultrawide at screen edges. (In the old hyprlang config this rule
-- required the match:class form -- the class: form was rejected.)
hl.window_rule({ name = "bg3-confine", match = { class = "^(bg3|bg3_dx11)$" }, confine_pointer = 1 })

-- Monitor-workspace bindings
-- Workspaces 1/3/4 on the laptop panel.
-- Bound by description, not connector: these previously said eDP-2, which does
-- not exist (the panel is eDP-1), so all three bindings silently did nothing.
hl.workspace_rule({ workspace = "1", monitor = "desc:Thermotrex Corporation TL140VDXP10", default = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:Thermotrex Corporation TL140VDXP10" })
hl.workspace_rule({ workspace = "4", monitor = "desc:Thermotrex Corporation TL140VDXP10" })

-- Workspace 2 on external monitor (Philips ultrawide)
-- Bind by description, not connector name: DP-2/DP-1 swap across replugs.
-- NOTE: a workspace can only be bound to ONE monitor; the LAST binding wins.
-- Binding to two monitors put ws2 on the disconnected one -> fell back to eDP-2.
hl.workspace_rule({ workspace = "2", monitor = "desc:Philips Consumer Electronics Company PHL 346B1C 1322131231233", default = true })

-- Keep workspace 2 on the external monitor, wherever we are.
-- A workspace rule binds to exactly ONE monitor, so the rule above only fires
-- at work (Philips). This puts ws2 on whatever non-laptop monitor is attached
-- -- Philips at work, AOC at home -- at startup and on every hotplug.
local LAPTOP_DESC = "Thermotrex"

local function place_external_workspace()
    for _, m in ipairs(hl.get_monitors()) do
        if not m.description:find(LAPTOP_DESC, 1, true) then
            -- focus first: Hyprland reaps empty workspaces, so ws2 may not
            -- exist yet and move alone fails with "Workspace not found".
            hl.dispatch(hl.dsp.focus({ workspace = 2 }))
            hl.dispatch(hl.dsp.workspace.move({ workspace = "2", monitor = m.name }))
            return
        end
    end
end

hl.on("hyprland.start", place_external_workspace)
hl.on("monitor.added", place_external_workspace)
