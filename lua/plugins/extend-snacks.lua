-- lua/plugins/extends-snacks.lua
return {
  {
    "folke/snacks.nvim",

    -- Use the `opts` function to safely modify the default options.
    -- `opts` is the original options table for snacks.nvim.
    ---@param opts snacks.Config
    opts = function(_, opts)
      -- Ensure the nested tables exist before trying to modify them.
      -- This makes the configuration robust.
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}

      -- Now, we surgically override ONLY the lsp_symbols and lsp_workspace_symbols
      -- sources, leaving all other default sources (like files, grep, etc.) untouched.
      opts.picker.sources.lsp_symbols = {
        filter = {
          default = {
            "Class",
            "Constructor",
            "Enum",
            "Field",
            "Function",
            "Interface",
            "Method",
            "Module",
            "Namespace",
            "Package",
            -- "Property",
            "Struct",
            "Trait",
          },
        },
      }

      -- opts.picker.sources.lsp_workspace_symbols = {
      --   filter = {
      --     default = {
      --       "Method",
      --       "Function",
      --       "Class",
      --       "Interface",
      --       "Constructor",
      --     },
      --   },
      -- }
    end,
  },
}
