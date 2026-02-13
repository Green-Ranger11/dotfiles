local sbar_utils = require("helpers.spaces_util.sbar_util")

local Window_Manager = {
  events = {
    window_change = "space_windows_change",
    focus_change = "space_change",
  },
}

function Window_Manager:init()
  -- Query current focused space on startup
  SBAR.exec("echo $(/usr/local/bin/yabai -m query --spaces --space | /usr/local/bin/jq '.index') 2>/dev/null || echo 1", function(focused)
    local focused_id = tonumber(focused) or 1

    for i = 1, 5 do
      local space = sbar_utils:add_space_item(i, i)

      -- Highlight if this is the focused space
      sbar_utils:highlight_focused_space(space, i == focused_id)

      space:subscribe(self.events.focus_change, function(env)
        -- On space_change, SELECTED is only "true" for the newly focused space
        sbar_utils:highlight_focused_space(space, env.SELECTED == "true")
      end)

      space:subscribe("mouse.clicked", function(env)
        self:perform_switch_desktop(env.BUTTON, i)
      end)
    end
  end)
end

function Window_Manager:start_watcher()
  -- no-op: labels are hidden, no need to watch window changes
end

--- @param button string the mouse button clicked
--- @param sid number clicked space's id
function Window_Manager:perform_switch_desktop(button, sid)
  local key_codes = { 18, 19, 20, 21, 23, 22, 26, 28, 25, 29 }
  if button == "left" then
    SBAR.exec('osascript -e \'tell application "System Events" to key code ' .. key_codes[sid] .. " using {control down}'")
  elseif button == "right" then
    SBAR.exec("osascript -e 'tell application \"Mission Control\" to activate'")
  end
end

return Window_Manager
