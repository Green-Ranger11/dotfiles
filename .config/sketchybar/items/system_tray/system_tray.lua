local tray_items = MODULES.system_tray and MODULES.system_tray.items or {}

for _, app_item in ipairs(tray_items) do
  SBAR.add("alias", app_item, {
    position = "right",
    alias = {
      color = COLORS.text,
    },
    padding_left = 2,
    padding_right = 2,
  })
end
