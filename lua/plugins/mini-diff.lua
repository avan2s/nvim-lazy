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
}
