return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      -- Flatten base/mantle/crust onto crust so the editor, floats, sidebars
      -- and statusline are all #11111b -- the same background kitty and the
      -- Quickshell bar use. surface0/1 still carry cursorline and visual.
      -- No editor background: kitty's 0.85 crust (blurred by Hyprland) shows
      -- through, same as the shell. Floats keep their crust fill.
      transparent_background = true,
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
      -- "catppuccin-mocha", not "catppuccin": Neovim 0.12 ships its own
      -- runtime colors/catppuccin.vim, which wins for the bare name and
      -- ignores every option above (no crust, no transparency).
      colorscheme = "catppuccin-mocha",
    },
  },
}
