-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Disable cursor movement with the space key
-- vim.g.lazyvim_no_defaults = true

local keymap = vim.keymap
keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
-- normally ctrl and and esc behave the same, but in some special scenarios in visual block mode they behave different.
keymap.set("i", "<C-c>", "<Esc>")

keymap.set({ "n", "v" }, "H", "_")
keymap.set({ "n", "v" }, "L", "$")
-- better indenting
keymap.set("v", "<", "<gv", { desc = "indent visual selection to the left" })
keymap.set("v", ">", ">gv", { desc = "indent visual selection to the right" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move in visual mode selected line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move in visual mode selected line up" })

-- if buffers are used for each file
keymap.set("n", "<M-l>", "<cmd>bnext<CR>", { desc = "Go to next buffer" }) --  go to next tab
keymap.set("n", "<M-h>", "<cmd>bprevious<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete and keep clipboard" })

-- prevent overwriting the clipboard
keymap.set("n", "x", [["_x]])
keymap.set("n", "<Space>D", [["_d$]], { desc = "delete rest of the line and keep clipboard" })
keymap.set("n", "C", [["_d$a]], { desc = "change rest of the line and keep clipboard" })
keymap.set("v", "c", [["_di]], { desc = "change and keep current clipboard" })
keymap.set("n", "c", [["_c]], { desc = "change and keep current clipboard" })

-- Resize window using <ctrl> arrow keys
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Add this in your LazyVim keymap configuration
vim.keymap.set("n", "<leader>rn", function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end, { desc = "Toggle relative numbers" })
