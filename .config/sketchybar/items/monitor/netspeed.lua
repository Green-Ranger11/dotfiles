local net = SBAR.add("item", "widgets.net", {
  position = "right",
  icon = { string = ICONS.network, color = COLORS.lavender },
  label = {
    string = "0 KB/s",
    font = { size = 12.0 },
    color = COLORS.text,
  },
  padding_right = PADDINGS,
})

local function format_speed(speed_str)
  local speed = tonumber(speed_str)
  if speed < 1024 then
    return string.format("%d KB/s", speed)
  elseif speed < 1024 * 1024 then
    return string.format("%.1f MB/s", speed / 1024)
  else
    return string.format("%.1f GB/s", speed / (1024 * 1024))
  end
end

net:subscribe("system_stats", function(env)
  local rx = format_speed(env.NETWORK_RX_en0)
  net:set({
    label = { string = rx },
  })
end)
