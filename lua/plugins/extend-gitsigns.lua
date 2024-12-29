return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      -- virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 0,
      -- ignore_whitespace = false,
      -- virt_text_priority = 100,
      -- use_focus = true,
    },
  },
  keys = {
    {
      "<leader>oc",
      function()
        require("gitsigns").diffthis()
      end,
      desc = "Open Changes",
    },
    -- {
    --   "<leader>grs",
    --   function()
    --     require("gitsigns").reset_buffer()
    --   end,
    --   desc = "Discard Changes in Current File",
    -- },
    {
      "<leader>grs",
      function()
        local gs = require("gitsigns")
        vim.cmd("!git restore --staged %") -- Reset staged changes
        vim.cmd("!git checkout %") -- Reset staged changes
        -- gs.reset_buffer() -- Reset unstaged changes
      end,
      desc = "Discard All Changes in Current File",
    },
  },
}
