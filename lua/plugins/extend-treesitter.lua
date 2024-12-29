return {
  "nvim-treesitter/nvim-treesitter", -- Ensure this is the correct plugin name
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      "json",
      "prisma",
      "sql",
      "vue",
      "xml",
      "yaml",
    },
  },
}
