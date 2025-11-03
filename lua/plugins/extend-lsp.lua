-- LSP keymaps
-- https://www.lazyvim.org/plugins/lsp
-- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- Only set this keymap for servers that support code actions
            { "<M-CR>", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
          },
        },
      },
    },
  },
}
