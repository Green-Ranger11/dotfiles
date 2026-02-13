--- @class space_api
--- @field created_spaces table<string, SketchybarItem> key space_id, value SketchyBar space item instance
local space_api = {
  created_spaces = {},
}

-- create a sketchybar space item (using regular "item" so it always renders)
--- @param space_id string | number The ID of the space
--- @param idx number The index of the space
--- @return SketchybarItem the created space item
function space_api:add_space_item(space_id, idx)
  local space = SBAR.add("item", "space." .. space_id, {
    icon = {
      string = tostring(space_id),
      padding_left = SPACES.ITEM_PADDING,
      padding_right = SPACES.ITEM_PADDING,
      color = COLORS.overlay0,
      highlight_color = COLORS.lavender,
      font = { family = FONT.icon_font, style = FONT.style_map["Regular"], size = 14.0 },
    },
    label = { drawing = false },
    padding_right = 2,
    padding_left = 2,
    background = {
      color = COLORS.transparent,
      border_width = 0,
      height = 26,
    },
  })
  space_api.created_spaces[space_id] = space
  return space
end

-- Highlight or unhighlight a space item based on focused
--- @param space_item SketchybarItem
--- @param is_selected boolean whether the space is focused
function space_api:highlight_focused_space(space_item, is_selected)
  space_item:set({
    icon = {
      highlight = is_selected,
      font = {
        family = FONT.icon_font,
        style = is_selected and FONT.style_map["Bold"] or FONT.style_map["Regular"],
        size = 14.0,
      },
    },
  })
end

--- @param space_id string | number The ID of the space to update
--- @param app_names string[] List of application names present in the space
function space_api:update_space(space_id, app_names)
  -- no-op: labels are hidden
end

return space_api
