local sbar_utils = require("helpers.spaces_util.sbar_util")

local Window_Manager = {
  events = {
    window_change = "space_windows_change",
    focus_change = "space_change",
  },
}

local FOCUSED_SPACE_CMD = "yabai -m query --spaces --space 2>/dev/null | jq '.index' || echo 1"

function Window_Manager:init()
  local spaces = {}
  for i = 1, 5 do
    local space = sbar_utils:add_space_item(i, i)
    spaces[i] = space

    space:subscribe("mouse.clicked", function(env)
      self:perform_switch_desktop(env.BUTTON, i)
    end)
  end

  -- Plain items (not sketchybar "space" items) get no SELECTED on
  -- space_change, so ask yabai which space is focused and repaint all of them.
  local function refresh()
    SBAR.exec(FOCUSED_SPACE_CMD, function(focused)
      local focused_id = tonumber(focused) or 1
      for i, space in ipairs(spaces) do
        sbar_utils:highlight_focused_space(space, i == focused_id)
      end
    end)
  end

  spaces[1]:subscribe({ self.events.focus_change, "display_change", "system_woke" }, refresh)
  refresh()
end

function Window_Manager:start_watcher()
  -- no-op: labels are hidden, no need to watch window changes
end

--- @param button string the mouse button clicked
--- @param sid number clicked space's id
function Window_Manager:perform_switch_desktop(button, sid)
  if button == "left" then
    SBAR.exec("yabai -m space --focus " .. sid)
  elseif button == "right" then
    SBAR.exec("osascript -e 'tell application \"Mission Control\" to activate'")
  end
end

return Window_Manager
