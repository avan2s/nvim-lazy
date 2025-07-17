-- ~/.config/nvim/lua/plugins/extend-mini-files.lua
return {
  "echasnovski/mini.files",
  opts = {
    windows = {
      preview = true,
      -- Increase focused window width to show full filenames
      width_focus = 50,
      -- -- Keep non-focused windows narrow
      width_nofocus = 30,
      -- -- Make preview window take up remaining space
      width_preview = 80,
    },
  },
}
