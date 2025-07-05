return {
  "folke/snacks.nvim",
  opts = {
    -- configure lazygit window
    lazygit = {
      configure = true,
      config = {
        os = { editPreset = "nvim-remote" },
        gui = {
          nerdFontsVersion = "3",
        },
      },
      win = {
        style = "lazygit",
        width = vim.o.columns,
        height = vim.o.lines,
        row = 0,
        col = 0,
        border = "none",
      },
    },
  },
}

-- if the  above snacks configuration makes issues, use the following alternative in keymaps.lua
-- if vim.fn.executable("lazygit") == 1 then
--   vim.keymap.set("n", "<leader>gg", function()
--     Snacks.lazygit({
--       cwd = LazyVim.root.git(),
--       win = {
--         style = "lazygit",
--         width = vim.o.columns,
--         height = vim.o.lines,
--         row = 0,
--         col = 0,
--         border = "none",
--       }
--     })
--   end, { desc = "Lazygit (Root Dir) - Fullscreen" })
-- end
