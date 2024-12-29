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
  },
}
