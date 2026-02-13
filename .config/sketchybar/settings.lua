--- @type "macos_native" | "aerospace" | "yabai"
WINDOW_MANAGER = "yabai"
--- @type "gnix" | "compact"
PRESET = "gnix"
--- @type "catppuccin_mocha" | "catppuccin_latte" | "rose_pine" | "tokyo_night" | "nord_light"
THEME = "catppuccin_mocha"

SBAR_HOME = (os.getenv("HOME") or "~") .. "/.config/sketchybar/"
ITEMS_HOME = SBAR_HOME .. "items/"
HELPERS_HOME = SBAR_HOME .. "helpers/"

PRESET_OPTIONS = {
  gnix = {
    BOREDER_WIDTH = 2,
    HEIGHT = 36,
    Y_OFFSET = 10,
    MARGIN = 30,
    CORNER_RADIUS = 0,
  },
  compact = {
    BOREDER_WIDTH = 0,
    HEIGHT = 27,
    Y_OFFSET = 0,
    MARGIN = 0,
    CORNER_RADIUS = 0,
  },
}

FONT = {
  icon_font = "FiraCode Nerd Font",
  label_font = "FiraCode Nerd Font", -- SF Mono, Monaspace Radon
  style_map = {
    ["Regular"] = "Regular",
    ["Semibold"] = "Medium",
    ["Bold"] = "Bold",
    ["Black"] = "ExtraBold",
  },
}

MODULES = {
  logo = { enable = true },
  menus = { enable = true },
  spaces = { enable = true },
  front_app = { enable = true },
  calendar = { enable = true },
  battery = { enable = true, style = "icon" },
  wifi = { enable = true },
  volume = { enable = true },
  chat = { enable = false },
  brew = { enable = false },
  toggle_stats = { enable = false },
  netspeed = { enable = false },
  cpu = { enable = true },
  mem = { enable = true },
  music = { enable = false },
  disk = { enable = true },
  power_menu = { enable = true },
  system_tray = {
    enable = true,
    items = {
      "Control Center,Bluetooth",
      "TextInputMenuAgent,Item-0",
    },
  },
}

SPACES = {
  --- @type "greek_uppercase" | "greek_lowercase" | nil
  ID_STYLE = nil,
  ITEM_PADDING = 12,
}

MUSIC = {
  CONTROLLER = "media-control",
  ALBUM_ART_SIZE = 1280,
  TITLE_MAX_CHARS = 15,
  DEFAULT_ARTIST = "Various Artists",
  DEFAULT_ALBUM = "No Album",
  DEFAULT_ALBUM_ART_PATH = ITEMS_HOME .. "music/default_albumarts/various_artists_mocha.jpg",
  POPUP_WIDTH = 80,
  POPUP_ITEMS = { shuffle = false, repeating = false },
}

WIFI = { PROXY_APP = "FlClash" }

PADDINGS = 5
GROUP_PADDINGS = 5
