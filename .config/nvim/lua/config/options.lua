-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt
opt.relativenumber = true -- Relative line numbers
-- Set to false to disable auto format
vim.g.lazyvim_eslint_auto_format = true
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false
