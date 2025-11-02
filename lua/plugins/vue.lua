-- local vue_language_server_path = vim.fn.stdpath("data")
--   .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
-- log it in a notification for testing
-- local vue_plugin = {
--   name = "@vue/typescript-plugin",
--   location = vue_language_server_path,
--   languages = { "vue" },
--   configNamespace = "typescript",
--   enableForWorkspaceTypeScriptVersions = true,
-- }
-- ./lua/plugins/vue.lua
return {
  -- Ensure Mason installs required packages
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vue-language-server",
        "typescript-language-server", -- Also ensure TypeScript LSP is installed
      },
    },
  },

  -- Treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vue", "css", "typescript", "javascript" },
    },
  },

  -- Configure vtsls with Vue support
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure vtsls handles vue files
      table.insert(opts.servers.vtsls.filetypes, "vue")

      -- Add Vue TypeScript plugin
      LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@vue/typescript-plugin",
          location = LazyVim.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
          languages = { "vue" },
          configNamespace = "typescript",
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },
}
