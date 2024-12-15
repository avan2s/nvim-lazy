if true then
  return {}
end
return {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      window = {
        border = "single", -- Border style: none, single, double, shadow
        position = "bottom", -- Top or bottom
        margin = { 1, 0, 1, 0 }, -- Margin: top, right, bottom, left
        padding = { 2, 2, 2, 2 }, -- Padding: top, right, bottom, left
        winblend = 0, -- Transparency: 0 (opaque) to 100 (transparent)
      },
      layout = {
        height = { min = 1, max = 25 }, -- Min and max height of the window
        width = { min = 20, max = 100 }, -- Min and max width
        spacing = 3, -- Spacing between columns
        align = "center", -- Align columns: left, center, or right
      },
      ignore_missing = false, -- Show all keys, even if not registered
      show_help = true, -- Show help message on the command line
      triggers = "auto", -- Automatically show which-key when typing
    })
  end,
}
