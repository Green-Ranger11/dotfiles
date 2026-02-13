local popup_width = 250
local popup_font = { family = FONT.label_font, style = FONT.style_map["Regular"], size = 12.0 }
local popup_icon_font = { family = FONT.icon_font, style = FONT.style_map["Regular"], size = 12.0 }
local hover_color = COLORS.surface0

local wifi = SBAR.add("item", "wifi", {
  position = "right",
  label = { drawing = false },
  click_script = "sketchybar --set wifi popup.drawing=toggle",
})

-- Header item always exists so popup can open
local wifi_header = SBAR.add("item", "wifi.header", {
  position = "popup." .. wifi.name,
  icon = {
    string = ICONS.wifi.router,
    color = COLORS.lavender,
    font = popup_icon_font,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    string = "Wi-Fi Networks",
    color = COLORS.text,
    font = popup_font,
  },
  width = popup_width,
  background = {
    height = 2,
    color = COLORS.surface1,
    y_offset = -15,
  },
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  SBAR.exec("ipconfig getifaddr en0", function(ip)
    local connected = not (ip == "")
    wifi:set({
      icon = {
        string = connected and ICONS.wifi.connected or ICONS.wifi.disconnected,
        color = connected and COLORS.lavender or COLORS.red,
      },
    })
  end)
end)

local function load_networks()
  SBAR.remove("/wifi.network\\.*/")
  wifi_header:set({ label = { string = "Scanning..." } })

  SBAR.exec("networksetup -getairportnetwork en0 | sed 's/Current Wi-Fi Network: //'", function(current_ssid)
    current_ssid = current_ssid:gsub("%s+$", "")

    SBAR.exec("networksetup -listpreferredwirelessnetworks en0 2>/dev/null | tail -n +2 | sed 's/^[[:space:]]*//'", function(networks)
      local counter = 0
      local seen = {}

      for network in string.gmatch(networks, "[^\r\n]+") do
        if counter >= 10 then break end
        network = network:gsub("^%s+", ""):gsub("%s+$", "")
        if network ~= "" and not seen[network] then
          seen[network] = true
          local is_current = (network == current_ssid)
          local color = is_current and COLORS.text or COLORS.overlay0
          local icon_str = is_current and ICONS.wifi.connected or ICONS.wifi.disconnected

          local net_item = SBAR.add("item", "wifi.network." .. counter, {
            position = "popup." .. wifi.name,
            width = popup_width,
            icon = {
              string = icon_str,
              color = color,
              font = popup_icon_font,
              padding_left = 10,
              padding_right = 6,
            },
            label = {
              string = network,
              color = color,
              font = popup_font,
              max_chars = 30,
            },
            background = { color = COLORS.transparent, height = 26, corner_radius = 6 },
            click_script = 'networksetup -setairportnetwork en0 "' .. network .. '"',
          })

          net_item:subscribe("mouse.entered", function()
            net_item:set({ background = { color = hover_color } })
          end)
          net_item:subscribe("mouse.exited", function()
            net_item:set({ background = { color = COLORS.transparent } })
          end)

          counter = counter + 1
        end
      end

      wifi_header:set({ label = { string = "Wi-Fi Networks" } })

      if counter == 0 then
        SBAR.add("item", "wifi.network.none", {
          position = "popup." .. wifi.name,
          width = popup_width,
          icon = { drawing = false },
          label = {
            string = "No networks found",
            color = COLORS.overlay0,
            font = popup_font,
            align = "center",
          },
        })
      end
    end)
  end)
end

wifi:subscribe("mouse.clicked", function()
  load_networks()
end)

wifi:subscribe("mouse.exited.global", function()
  wifi:set({ popup = { drawing = false } })
  SBAR.remove("/wifi.network\\.*/")
end)
