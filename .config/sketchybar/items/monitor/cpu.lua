local cpu = SBAR.add("item", "widgets.cpu", {
  position = "right",
  icon = { string = ICONS.cpu, color = COLORS.lavender },
  label = {
    string = "??%",
    font = { size = 12.0 },
    color = COLORS.text,
  },
  padding_right = PADDINGS,
})

cpu:subscribe({ "system_stats" }, function(env)
  local usage = tonumber(env.CPU_USAGE) or 0
  cpu:set({
    label = { string = string.format("%d%%", usage) },
  })
end)

cpu:subscribe("mouse.clicked", function(env)
  SBAR.exec("open -a 'Activity Monitor'")
end)
