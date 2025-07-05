return {
  "echasnovski/mini.surround",
  opts = {},
  keys = {
    { "gshl", false },
    { "gshn", false },
    { "gsh", false },
    { "gsfl", false },
    { "gsfn", false },
    { "gsf", false },
    { "gsFl", false },
    { "gsFn", false },
    { "gsF", false },
    {
      "S",
      -- This command string is executed after exiting visual mode.
      -- The '<,'> range marks are used by the plugin internally.
      -- Using `require` is more robust than using the global `MiniSurround`.
      ":<C-u>lua require('mini.surround').add('visual')<CR>",
      mode = "x", -- "x" for visual mode
      desc = "Surround: Add surrounding (visual)",
    },
  },
}
