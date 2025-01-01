return {
  {
    "ibhagwan/fzf-lua",
    -- opts = {
    --   lsp = {
    --     -- Default configurations for LSP, you can adjust this
    --     document_symbols = {
    --       symbols = { "Class" }, -- Default to Class filtering (if no regex_filter)
    --     },
    --   },
    -- },
    keys = {
      {
        "<leader>sc", -- Keybinding for searching classes
        function()
          require("fzf-lua").lsp_live_workspace_symbols({
            regex_filter = function(entry, ctx)
              -- Restrict search to "Class" symbols only
              return entry.kind == "Class"
            end,
          })
        end,
        desc = "Search for Classes",
      },
    },
  },
}
