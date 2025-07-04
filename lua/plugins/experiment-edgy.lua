if true then
  return {}
end
return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    bottom = {
      {
        ft = "toggleterm",
        size = { height = 0.4 },
      },
      {
        ft = "qf",
        title = "Quickfix",
        size = { height = 0.4 },
      },
      {
        ft = "help",
        size = { height = 20 },
      },
      {
        ft = "spectre_panel",
        size = { height = 0.4 },
      },
    },
    left = {
      {
        title = "Neo-Tree",
        ft = "neo-tree",
        size = { width = 30 },
      },
    },
  },
}
