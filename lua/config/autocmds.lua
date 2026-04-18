-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Preserve terminal normal mode when switching windows/buffers.
-- TermLeave is the only reliable signal that the user is now in normal mode
-- (fires exactly when jk → <C-\><C-n> is pressed). WinLeave mode polling is unreliable.
-- vim.schedule on stopinsert ensures it wins even if snacks calls startinsert first.
local term_in_normal = {}

vim.api.nvim_create_autocmd("TermLeave", {
  callback = function()
    term_in_normal[vim.api.nvim_get_current_buf()] = true
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "terminal" then return end
    if term_in_normal[buf] then
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == buf then
          vim.cmd("stopinsert")
        end
      end)
    else
      vim.cmd("startinsert")
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(ev)
    term_in_normal[ev.buf] = nil
  end,
})
