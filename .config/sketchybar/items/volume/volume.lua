local popup_width = 250
local popup_font = { family = FONT.label_font, style = FONT.style_map["Regular"], size = 12.0 }
local hover_color = COLORS.surface0

local volume_icon = SBAR.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = ICONS.volume._100,
    width = 0,
    align = "left",
    color = COLORS.lavender,
  },
  label = {
    width = 25,
    align = "left",
    color = COLORS.lavender,
  },
})

local volume_slider = SBAR.add("slider", popup_width, {
  position = "popup." .. volume_icon.name,
  background = { color = COLORS.base, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

volume_icon:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local new_icon = ICONS.volume._0
  if volume > 60 then
    new_icon = ICONS.volume._100
  elseif volume > 30 then
    new_icon = ICONS.volume._66
  elseif volume > 10 then
    new_icon = ICONS.volume._33
  elseif volume > 0 then
    new_icon = ICONS.volume._10
  end

  volume_icon:set({ icon = new_icon })
  volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
  local drawing = volume_icon:query().popup.drawing == "on"
  if not drawing then
    return
  end
  volume_icon:set({ popup = { drawing = false } })
  SBAR.remove("/volume.device\\.*/")
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    SBAR.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume_icon:query().popup.drawing == "off"
  if should_draw then
    volume_icon:set({ popup = { drawing = true } })
    SBAR.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      SBAR.exec("SwitchAudioSource -a -t output", function(available)
        local current = current_audio_device
        local counter = 0

        for device in string.gmatch(available, "[^\r\n]+") do
          local color = COLORS.overlay0
          if current == device then
            color = COLORS.text
          end
          local dev_item = SBAR.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_icon.name,
            width = popup_width,
            align = "center",
            label = {
              string = device,
              color = color,
              font = popup_font,
              max_chars = 35,
            },
            background = { color = COLORS.transparent, height = 26, corner_radius = 6 },
            click_script = 'SwitchAudioSource -s "'
              .. device
              .. '" && sketchybar --set /volume.device\\.*/ label.color='
              .. COLORS.overlay0
              .. " --set $NAME label.color="
              .. COLORS.text,
          })

          dev_item:subscribe("mouse.entered", function()
            dev_item:set({ background = { color = hover_color } })
          end)
          dev_item:subscribe("mouse.exited", function()
            dev_item:set({ background = { color = COLORS.transparent } })
          end)

          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then
    delta = delta * 10.0
  end

  SBAR.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_icon:subscribe("mouse.exited.global", volume_collapse_details)
