local disk = SBAR.add("item", "widgets.disk", {
  position = "right",
  icon = { string = ICONS.disk, color = COLORS.lavender },
  label = {
    string = "??%",
    font = { size = 12.0 },
    color = COLORS.text,
  },
  update_freq = 60,
  updates = "when_shown",
  padding_right = PADDINGS,
})

local function update_disk()
  SBAR.exec("df -h / | awk 'NR==2 {gsub(/%/,\"\",$5); print $5}'", function(result)
    local usage = tonumber(result)
    if not usage then return end
    disk:set({
      label = { string = string.format("%d%%", usage) },
    })
  end)
end

disk:subscribe({ "forced", "routine", "system_woke" }, function()
  update_disk()
end)

disk:subscribe("mouse.clicked", function()
  SBAR.exec("open -a 'Disk Utility'")
end)
