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
            -- <leader>ca is already in LazyVim defaults; add only the alt-enter alias
            { "<M-CR>", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
          },
        },
      },
    },
  },
}
