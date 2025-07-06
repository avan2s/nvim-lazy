return {
  "echasnovski/mini.diff",
  event = "VeryLazy",
  keys = {
    {
      "<leader>oc",
      function()
        require("mini.diff").toggle_overlay(0)
      end,
      desc = "(o)pen all (c)hanges in biffer",
    },
    {
      "<leader>gha",
      function()
        require("mini.diff").toggle_overlay(0)
      end,
      desc = "Toggle all hunks",
    },
  },
  opts = {
    view = {
      style = "sign",
      signs = {
        add = "▎",
        change = "▎",
        delete = "",
      },
    },
  },
  config = function(_, opts)
    require("mini.diff").setup(opts)

    -- Set up highlight groups for better visibility
    -- vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = "#50fa7b" })
    vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = "#f1fa8c" })
    -- vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = "#ff5555" })

    -- For overlay mode - make changed lines have yellow background
    vim.api.nvim_set_hl(0, "MiniDiffOverChange", { bg = "#f1fa8c", fg = "#282a36" })
    -- vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { bg = "#50fa7b", fg = "#282a36", blend = 20 })
    -- vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { bg = "#ff5555", fg = "#f8f8f2" })
  end,
}
