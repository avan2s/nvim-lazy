-- :help SymbolKind
return {
  "stevearc/aerial.nvim",
  -- event = "LazyFile",
  opts = {
    autojump = true,
    sort = "name",
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Method",
      "Struct",
    },

    layout = {
      max_width = 0.5,
      -- width = nil,
      min_width = 0.2,
      -- When the symbols change, resize the aerial window (within min/max constraints) to fit
      resize_to_content = true,
    },
    float = {
      relative = "window",
    },
  },
  keys = {
    { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
  },
}
