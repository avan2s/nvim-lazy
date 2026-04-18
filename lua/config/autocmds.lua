-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Preserve shell terminal normal mode when switching windows/buffers.
-- vim.b.term_user_normal is set by the jk keymap (the ONLY reliable signal the user
-- chose normal mode). snacks handles startinsert for all terminals (including lazygit)
-- via auto_insert=true. We only intervene to call stopinsert for shell terminals
-- where the user explicitly chose normal mode.

local function is_shell_terminal(buf)
  -- snacks sets vim.b.snacks_terminal.cmd = nil for interactive shells, non-nil for TUIs
  local st = vim.b[buf].snacks_terminal
  return st ~= nil and st.cmd == nil
end

-- User re-entered terminal mode (pressed i/a or startinsert was called) → clear the flag
-- vim.api.nvim_create_autocmd("TermEnter", {
--   callback = function()
--     vim.b.term_user_normal = nil
--   end,
-- })

-- Clear the flag if user leaves the terminal while still in terminal mode (was typing).
-- vim.api.nvim_create_autocmd("WinLeave", {
--   callback = function()
--     local buf = vim.api.nvim_get_current_buf()
--     if vim.bo[buf].buftype == "terminal" and is_shell_terminal(buf) then
--       if vim.api.nvim_get_mode().mode == "t" then
--         vim.b[buf].term_user_normal = nil
--       end
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     local buf = vim.api.nvim_get_current_buf()
--     if vim.bo[buf].buftype ~= "terminal" then return end
--     if is_shell_terminal(buf) and vim.b[buf].term_user_normal then
--       -- User explicitly went to normal mode via jk: restore it.
--       -- vim.schedule ensures this wins after snacks' auto_insert startinsert.
--       vim.schedule(function()
--         if vim.api.nvim_get_current_buf() == buf then
--           vim.cmd("stopinsert")
--         end
--       end)
--     end
--     -- No else: snacks auto_insert=true handles startinsert for all terminals.
--   end,
-- })
