-- provide xml supprt
return {
  {
    "mason-org/mason.nvim",
    -- Use the 'opts' function to safely modify the existing options
    opts = {
      ensure_installed = { "lemminx" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lemminx = {
          settings = {
            catalogs = { vim.fn.stdpath("config") .. "/catalog.xml" },
          },
        },
      },
    },
  },
}
