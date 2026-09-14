-- Ctrl+h/j/k/l across Neovim windows and herdr panes (herdr's vim-tmux-navigator).
-- Pairs with the herdr-splits herdr plugin bound in ~/.config/herdr/config.toml.
return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  event = "VeryLazy",
  opts = {
    -- Stop at edges like vim-tmux-navigator did, instead of wrapping around.
    at_edge = "stop",
    nav_at_edge = "stop",
  },
  keys = {
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end, desc = "Navigate left" },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end, desc = "Navigate down" },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end, desc = "Navigate up" },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Navigate right" },
  },
}
