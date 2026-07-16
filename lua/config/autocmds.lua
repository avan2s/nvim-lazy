-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Preserve shell terminal normal mode when switching windows/buffers.
-- And keep insert mode if you left terminal in insert/terminal mode
-- For that to work the `extends-snacks.lua` has to be configured to the following:
-- terminal = {
--   auto_insert = false,
--   start_insert = true,
-- },

-- figures out if the buffer is a snacks terminal
local function is_shell_terminal(buf)
  -- snacks sets vim.b.snacks_terminal.cmd = nil for interactive shells, non-nil for TUIs
  local st = vim.b[buf].snacks_terminal
  return st ~= nil and st.cmd == nil
end

-- Clear the flag if user leaves the terminal while still in terminal mode (was typing).
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype == "terminal" then
      if vim.api.nvim_get_mode().mode == "t" then
        vim.b[buf].has_left_in_insert_mode = true
      else
        -- we leave in normal mode - so we want to remember the terminal next time we access it
        vim.b[buf].has_left_in_insert_mode = nil
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if is_shell_terminal(buf) and vim.b[buf].has_left_in_insert_mode then
      -- print("hasLeftInInsertMode", vim.b[buf].has_left_in_insert_mode)
      --  keep insert mode, since we left it in that mode
      vim.cmd("startinsert")
    end
  end,
})

-- In diffview's diff buffers ]c / [c already run native change navigation
-- (LazyVim guards the treesitter class move on vim.wo.diff), but which-key still
-- shows "Next/Prev Class". Relabel them buffer-locally so the popup matches.
-- The working-tree side is the real file buffer, so on close we restore the
-- treesitter mapping by re-firing only its FileType autocmd group.
local diff_relabel = vim.api.nvim_create_augroup("diff_change_relabel", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = diff_relabel,
  pattern = "DiffviewDiffBufWinEnter",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.b[buf].diff_change_relabel = true
    vim.keymap.set("n", "]c", "]c", { buffer = buf, desc = "Next change" })
    vim.keymap.set("n", "[c", "[c", { buffer = buf, desc = "Prev change" })
  end,
})

-- Match VSCode: the staged/index side of a diffview diff is the git index
-- buffer, which diffview leaves editable (writing it re-stages the file).
-- Lock it so edits there can't silently rewrite the index, and label each pane
-- via the winbar so the read-only side is obvious. Both diff windows get a
-- winbar so the winbar's extra top line keeps the two sides vertically aligned.
local diff_index_readonly = vim.api.nvim_create_augroup("diff_index_readonly", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = diff_index_readonly,
  pattern = "DiffviewDiffBufWinEnter",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)

    -- The merge tool (conflict stages :1:/:2:/:3:) already shows diffview's own
    -- OURS/BASE/THEIRS winbar; leave it untouched so those labels survive.
    local ok, lib = pcall(require, "diffview.lib")
    local view = ok and lib.get_current_view() or nil
    local in_merge = (view and view.cur_entry and view.cur_entry.kind == "conflicting")
      or name:match("^diffview://.*:[123]:") ~= nil
    if in_merge then
      return
    end

    if name:match("^diffview://") then
      if name:match(":0:") then
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true
      end
      vim.wo.winbar = "%#DiagnosticWarn# 󰌾 read-only %*"
    else
      vim.wo.winbar = "%#DiagnosticOk# 󰏫 editable %*"
    end
  end,
})

-- On close, drop the relabel and let treesitter reclaim ]c / [c on reused buffers.
vim.api.nvim_create_autocmd("User", {
  group = diff_relabel,
  pattern = "DiffviewViewClosed",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].diff_change_relabel then
        vim.b[buf].diff_change_relabel = nil
        pcall(vim.keymap.del, "n", "]c", { buffer = buf })
        pcall(vim.keymap.del, "n", "[c", { buffer = buf })
        pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf, group = "lazyvim_treesitter_textobjects" })
      end
    end
  end,
})
