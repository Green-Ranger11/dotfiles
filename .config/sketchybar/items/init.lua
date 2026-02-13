local function safe_require(path)
  local ok, err = pcall(require, path)
  if not ok then
    print("⚠️ Failed to load " .. path .. ": " .. err)
  end
end

local function is_enabled(mod)
  return MODULES[mod] and MODULES[mod].enable ~= false
end

local function add_divider(name)
  SBAR.add("item", "divider." .. name, {
    position = "right",
    icon = {
      string = "│",
      color = COLORS.surface1,
      font = { size = 16.0 },
      padding_left = 4,
      padding_right = 4,
    },
    label = { drawing = false },
    background = { drawing = false },
  })
end

-- LEFT
if is_enabled("logo") then
  safe_require("items.logo.apple")
end
if is_enabled("spaces") then
  safe_require("items.spaces.spaces")
end
if is_enabled("menus") then
  safe_require("items.menus.menus")
end
if is_enabled("front_app") then
  safe_require("items.front_app.front_app")
end

-- RIGHT — config (far right, loaded first)
if is_enabled("power_menu") then
  safe_require("items.power_menu.power_menu")
end
if is_enabled("battery") then
  safe_require("items.battery.battery")
end
if is_enabled("volume") then
  safe_require("items.volume.volume")
end
if is_enabled("brew") then
  safe_require("items.brew.brew")
end
if is_enabled("wifi") then
  safe_require("items.monitor.wifi")
end

add_divider("config_info")

-- RIGHT — system tray (menu bar extras)
if is_enabled("system_tray") then
  safe_require("items.system_tray.system_tray")
end

add_divider("tray_info")

-- RIGHT — info
if is_enabled("calendar") then
  safe_require("items.calendar.calendar")
end

add_divider("info_stats")

-- RIGHT — system tray (inside, loaded last)
if is_enabled("netspeed") then
  safe_require("items.monitor.netspeed")
end
if is_enabled("disk") then
  safe_require("items.monitor.disk")
end
if is_enabled("mem") then
  safe_require("items.monitor.mem")
end
if is_enabled("cpu") then
  safe_require("items.monitor.cpu")
end

-- Disabled modules
if is_enabled("music") then
  safe_require("items.music.music")
end
if is_enabled("chat") then
  safe_require("items.chat.qq_wechat")
end
if is_enabled("toggle_stats") then
  safe_require("items.toggle_stats.toggle_stats")
end
