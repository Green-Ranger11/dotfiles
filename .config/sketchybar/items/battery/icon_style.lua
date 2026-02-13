local popup_font = { family = FONT.label_font, style = FONT.style_map["Regular"], size = 12.0 }
local hover_color = COLORS.surface0

local battery = SBAR.add("item", "battery", {
  position = "right",
  icon = { font = { size = 15.0 }, color = COLORS.lavender },
  label = { drawing = false },
  update_freq = 180,
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  SBAR.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local _, _, charge = batt_info:find("(%d+)%%")
    if charge then
      charge = tonumber(charge)
    end
    local charging = batt_info:find("AC Power")

    if charging then
      icon = ICONS.battery.charging
    else
      if charge then
        if charge > 80 then
          icon = ICONS.battery._100
        elseif charge > 60 then
          icon = ICONS.battery._75
        elseif charge > 40 then
          icon = ICONS.battery._50
        elseif charge > 20 then
          icon = ICONS.battery._25
        else
          icon = ICONS.battery._0
        end
      end
    end
    battery:set({ icon = { string = icon, color = COLORS.lavender } })
  end)
end)

local battery_percent = SBAR.add("item", {
  position = "popup." .. battery.name,
  icon = { string = "Percentage:", width = 100, align = "left", font = popup_font },
  label = { string = "??%", width = 100, align = "right", font = popup_font },
  background = { color = COLORS.transparent, height = 26, corner_radius = 6 },
})

local remaining_time = SBAR.add("item", {
  position = "popup." .. battery.name,
  icon = { string = "Time remaining:", width = 100, align = "left", font = popup_font },
  label = { string = "??:??h", width = 100, align = "right", font = popup_font },
  background = { color = COLORS.transparent, height = 26, corner_radius = 6 },
})

battery_percent:subscribe("mouse.entered", function()
  battery_percent:set({ background = { color = hover_color } })
end)
battery_percent:subscribe("mouse.exited", function()
  battery_percent:set({ background = { color = COLORS.transparent } })
end)

remaining_time:subscribe("mouse.entered", function()
  remaining_time:set({ background = { color = hover_color } })
end)
remaining_time:subscribe("mouse.exited", function()
  remaining_time:set({ background = { color = COLORS.transparent } })
end)

battery:subscribe("mouse.clicked", function()
  local drawing = battery:query().popup.drawing
  battery:set({ popup = { drawing = "toggle" } })
  if drawing == "off" then
    SBAR.exec("pmset -g batt", function(batt_info)
      local _, _, charge = batt_info:find("(%d+)%%")
      battery_percent:set({ label = charge and (charge .. "%") or "N/A" })
      local _, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local time_label = remaining and (remaining .. "h") or "No estimate"
      remaining_time:set({ label = time_label })
    end)
  end
end)

battery:subscribe("mouse.exited.global", function()
  battery:set({ popup = { drawing = false } })
end)
