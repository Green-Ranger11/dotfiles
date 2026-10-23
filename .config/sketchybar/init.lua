require("settings")
SBAR = require("sketchybar")
LOG = require("helpers.debug_info")
COLORS = require("themes.init")
ICONS = require("icons")
GRAPH_UTILS = require("helpers.graph_utils")
SBAR.begin_config()

local preset_conf = PRESET_OPTIONS[PRESET] or PRESET_OPTIONS["gnix"]

SBAR.bar({
  color = COLORS.crust,
  height = preset_conf.HEIGHT,
  border_width = preset_conf.BOREDER_WIDTH,
  border_color = COLORS.lavender,
  corner_radius = preset_conf.CORNER_RADIUS,
  blur_radius = 15,
  shadow = { drawing = true },
  sticky = true,
  font_smoothing = true,
  -- Wider than PADDINGS so the display's rounded corners don't clip the
  -- outermost items now that the bar is flush with the edges.
  padding_right = 16,
  padding_left = 16,
  y_offset = preset_conf.Y_OFFSET,
  margin = preset_conf.MARGIN,
  notch_width = 200,
})

SBAR.default({
  updates = "when_shown",
  padding_left = PADDINGS,
  padding_right = PADDINGS,
  icon = {
    font = { family = FONT.icon_font, style = FONT.style_map["Regular"], size = 15.0 },
    color = COLORS.text,
    padding_left = PADDINGS,
    padding_right = PADDINGS,
    background = { image = { corner_radius = 9 } },
  },
  label = {
    font = { family = FONT.label_font, style = FONT.style_map["Regular"], size = 13.0 },
    color = COLORS.text,
    padding_left = PADDINGS,
    padding_right = PADDINGS,
    shadow = { drawing = false },
  },
  background = {
    height = 28,
    corner_radius = 9,
    border_width = 0,
    border_color = COLORS.transparent,
    color = COLORS.transparent,
    image = { corner_radius = 9, border_color = COLORS.grey, border_width = 1 },
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 9,
      border_color = COLORS.lavender,
      color = COLORS.crust,
      shadow = { drawing = true },
    },
    blur_radius = 50,
    align = "right",
    y_offset = 6,
  },
  slider = {
    background = {
      height = 6,
      corner_radius = 3,
      color = COLORS.surface1,
    },
    highlight_color = COLORS.blue,
    knob = {
      string = "􀀁",
      drawing = true,
      color = COLORS.lavender,
    },
  },
  scroll_texts = true,
})

SBAR.exec("killall stats_provider >/dev/null; stats_provider --cpu usage --memory ram_usage --network en0 --interval 1 --no-units", function()
  LOG:info("Started stats_provider_rust")
end)

-- Get out of the way while the native menu bar is revealed (mouse at the top edge).
SBAR.exec("killall menubar_watch >/dev/null; " .. HELPERS_HOME .. "menubar_watch/bin/menubar_watch")

-- Accent line along the bar's bottom edge, like the Hyprland bar (sketchybar
-- can't border just one side). Zero layout width, so items aren't shifted;
-- the label's own background spans its width (the bar clips the overflow).
SBAR.add("item", "bar.underline", {
  position = "left",
  width = 0,
  padding_left = -16,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    string = "",
    width = 4000,
    padding_left = 0,
    padding_right = 0,
    background = {
      drawing = true,
      height = 2,
      corner_radius = 0,
      color = COLORS.lavender,
      y_offset = -(preset_conf.HEIGHT / 2) + 1,
    },
  },
})

require("items")

SBAR.end_config()
SBAR.event_loop()
