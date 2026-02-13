local cal = SBAR.add("item", "calendar", {
  position = "right",
  icon = { drawing = false },
  label = {
    color = COLORS.text,
    font = { size = 12.0 },
  },
  update_freq = 1,
  padding_right = PADDINGS,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
  cal:set({ label = { string = os.date("%H:%M %m-%d") } })
end)

cal:subscribe("mouse.clicked", function()
  SBAR.exec("open -a Calendar")
end)
