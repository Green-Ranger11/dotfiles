local ram = SBAR.add("item", "widgets.ram", {
  position = "right",
  icon = { string = ICONS.ram, color = COLORS.lavender },
  label = {
    string = "??%",
    font = { size = 12.0 },
    color = COLORS.text,
  },
  padding_right = PADDINGS,
})

ram:subscribe({ "system_stats" }, function(env)
  local usage = tonumber(env.RAM_USAGE) or 0
  ram:set({
    label = { string = string.format("%d%%", usage) },
  })
end)
