-- LSP keymaps and server settings
-- https://www.lazyvim.org/plugins/lsp
return {
  {
    -- LazyVim declares opts_extend = { "ensure_installed" } on this plugin,
    -- so plain table opts safely append — no function form needed.
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "lemminx", "css-lsp" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "<M-CR>", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
          },
        },
        lemminx = {
          settings = {
            xml = {
              catalogs = { vim.fn.stdpath("config") .. "/catalog.xml" },
            },
          },
        },
        cssls = {},
        vtsls = {
          settings = {
            complete_function_calls = false,
            vtsls = {
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = false,
                },
              },
            },
            typescript = {
              suggest = {
                completeFunctionCalls = false,
              },
              inlayHints = {
                enumMemberValues = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                parameterNames = { enabled = false },
                parameterTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
