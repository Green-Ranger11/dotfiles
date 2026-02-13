local popup_width = 180
local popup_font = { family = FONT.label_font, style = FONT.style_map["Regular"], size = 12.0 }
local popup_icon_font = { family = FONT.icon_font, style = FONT.style_map["Regular"], size = 12.0 }
local hover_color = COLORS.surface0

local power = SBAR.add("item", "power_menu", {
  position = "right",
  icon = {
    string = ICONS.power_menu,
    color = COLORS.lavender,
    font = { size = 15.0 },
  },
  label = { drawing = false },
  popup = {
    align = "right",
    height = 30,
  },
})

local menu_items = {
  {
    label = "Lock Screen",
    icon = "󰌾",
    command = "pmset displaysleepnow",
  },
  {
    label = "Sleep",
    icon = "󰤄",
    command = "pmset sleepnow",
  },
  {
    label = "Restart",
    icon = "󰜉",
    command = "osascript -e 'tell app \"System Events\" to restart'",
  },
  {
    label = "Shut Down",
    icon = "󰐥",
    command = "osascript -e 'tell app \"System Events\" to shut down'",
  },
  {
    label = "Log Out",
    icon = "󰍃",
    command = "osascript -e 'tell app \"System Events\" to log out'",
  },
}

for i, item in ipairs(menu_items) do
  local menu_item = SBAR.add("item", "power_menu.item." .. i, {
    position = "popup." .. power.name,
    icon = {
      string = item.icon,
      color = COLORS.lavender,
      font = popup_icon_font,
      padding_left = 10,
      padding_right = 8,
    },
    label = {
      string = item.label,
      color = COLORS.text,
      font = popup_font,
      width = popup_width - 40,
      align = "left",
    },
    background = { color = COLORS.transparent, height = 26, corner_radius = 6 },
    click_script = item.command,
  })

  menu_item:subscribe("mouse.entered", function()
    menu_item:set({ background = { color = hover_color } })
  end)
  menu_item:subscribe("mouse.exited", function()
    menu_item:set({ background = { color = COLORS.transparent } })
  end)
end

local function toggle_popup()
  local should_draw = power:query().popup.drawing == "off"
  power:set({ popup = { drawing = should_draw } })
end

local function hide_popup()
  power:set({ popup = { drawing = false } })
end

power:subscribe("mouse.clicked", toggle_popup)
power:subscribe("mouse.exited.global", hide_popup)
