return {
  "nvim-treesitter/nvim-treesitter", -- Ensure this is the correct plugin name
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "prisma",
      "python",
      "query",
      "regex",
      "sql",
      "tsx",
      "typescript",
      "vim",
      "vue",
      "xml",
      "yaml",
    },
  },
}
