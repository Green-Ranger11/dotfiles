return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      -- Flatten base/mantle/crust onto crust so the editor, floats, sidebars
      -- and statusline are all #11111b -- the same background kitty and the
      -- Quickshell bar use. surface0/1 still carry cursorline and visual.
      color_overrides = {
        mocha = {
          base = "#11111b",
          mantle = "#11111b",
          crust = "#11111b",
        },
      },
      custom_highlights = function(c)
        -- Accent is green now (Hyprland borders, kitty cursor, the bar).
        return { CursorLineNr = { fg = c.green } }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
