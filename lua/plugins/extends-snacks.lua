-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#lsp_symbols
local Util = require("lazyvim.util")
return {
  "folke/snacks.nvim",
  keys = {
    -- deactivate explorer commands
    { "<leader>e", false },
    { "<leader>E", false },
    {
      "<leader>oo",
      function()
        require("snacks").picker.lsp_symbols({
          filter = {
            -- This sets the filter to only show "Method" symbols by default
            default = {
              "Class",
              "Constructor",
              "Enum",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Struct",
              "Trait",
            },
          },
        })
      end,
      desc = "Find default symbols (Snacks)",
    },
    {
      "<leader>oO",
      function()
        require("snacks").picker.lsp_workspace_symbols({
          filter = {
            -- This sets the filter to only show "Method" symbols by default
            default = {
              "Class",
              "Constructor",
              "Enum",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Struct",
              "Trait",
            },
          },
        })
      end,
      desc = "Find default symbols in workspace (Snacks)",
    },
    {
      "<leader>om",
      function()
        require("snacks").picker.lsp_symbols({
          filter = {
            -- This sets the filter to only show "Method" symbols by default
            default = {
              "Method",
            },
          },
        })
      end,
      desc = "open method inside buffer (Snacks)",
    },

    {
      "<leader>fi",
      function()
        require("snacks").picker.lsp_workspace_symbols({
          filter = {
            -- This sets the filter to only show "Method" symbols by default
            default = {
              "Interface",
            },
          },
        })
      end,
      desc = "Find interfaces in workspace",
    },
    {
      "<leader>fF",
      function()
        require("snacks").picker.files({
          hidden = true,
        })
      end,
      desc = "Find Files (cwd)",
    },
    {
      "<leader><leader>",
      function()
        require("snacks").picker.files({
          hidden = true,
        })
      end,
      desc = "Find Files (cwd)",
    },
    {
      "<leader>ff",
      function()
        require("snacks").picker.files({
          hidden = true,
          cwd = Util.root(),
        })
      end,
      desc = "Find Files (Root Dir)",
    },
  },
  opts = {
    explorer = {},
    picker = {
      files = { hidden = true },
    },
    -- configure lazygit window
    lazygit = {
      configure = true,
      config = {
        os = { editPreset = "nvim-remote" },
        gui = {
          nerdFontsVersion = "3",
        },
      },
      win = {
        style = "lazygit",
        width = vim.o.columns,
        height = vim.o.lines,
        border = "none",
      },
    },
  },
}
