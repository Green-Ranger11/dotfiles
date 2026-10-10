-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.g.transparent_groups = vim.list_extend(
  vim.g.transparent_groups or {},
  vim.tbl_map(function(v)
    return v.hl_group
  end, vim.tbl_values(require("bufferline.config").highlights))
)

-- Scratchpad (Super+S in Hyprland opens ~/Documents/scratch.md): autosave so
-- hiding the window or closing it never loses notes; next open shows them.
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "FocusLost", "BufLeave" }, {
  pattern = vim.fn.expand("~/Documents/scratch.md"),
  command = "silent! update",
})
