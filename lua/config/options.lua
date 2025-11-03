-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.expandtab = true -- expand tab to spaces
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.autoindent = true -- copy indent from current line when starting new one
--
-- -- line wrapping
opt.wrap = false -- disable line wrapping
--
-- -- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
--
-- -- cursor line
opt.cursorline = true -- highlight the current cursor line
opt.showtabline = 0

-- deactivate macro key
vim.keymap.set("n", "q", "<Nop>", { noremap = true, silent = true })

vim.g.format_on_save = false
-- backspace
-- opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- Set to false to disable auto format (default true)
-- vim.g.lazyvim_eslint_auto_format = true

-- split windows
-- opt.splitright = true -- split vertical window to the right
-- opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
-- opt.swapfile = false

-- shows replacements with : %s - especially useful in vscode
-- opt.inccommand = "split"
vim.g.lsp_diagnostics_virtual_text = true

-- Disable backup and swap files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
