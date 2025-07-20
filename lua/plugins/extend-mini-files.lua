-- ~/.config/nvim/lua/plugins/extend-mini-files.lua
return {
  "echasnovski/mini.files",
  keys = {
    {
      "<CR>",
      function()
        require("mini.files").go_in()
      end,
      desc = "Go in entry",
    },
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
    -- {
    --   "<leader>fm",
    --   function()
    --     require("mini.files").open(LazyVim.root(), true)
    --   end,
    --   desc = "Open mini.files (root)",
    -- },
  },
  opts = {
    options = {
      use_as_default_explorer = true,
    },
    mappings = {
      go_out = "<M-h>",
      go_out_plus = "<C-h>",
      go_in = "<M-l>",
      go_in_plus = "<C-l>",
    },
    windows = {
      preview = true,
      -- Increase focused window width to show full filenames
      width_focus = 45,
      -- -- Keep non-focused windows narrow
      width_nofocus = 30,
      -- -- Make preview window take up remaining space
      width_preview = 70,
    },
  },
}
