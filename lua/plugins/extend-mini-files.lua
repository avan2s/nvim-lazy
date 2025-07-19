-- ~/.config/nvim/lua/plugins/extend-mini-files.lua
return {
  "echasnovski/mini.files",
  opts = {
    options = {
      use_as_default_explorer = true,
    },
    mappings = {
      go_out = "<M-h>",
      go_in = "<M-l>",
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
