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

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        volar = {
          on_init = function(client)
            client.handlers["tsserver/request"] = function(_, result, context)
              local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
              if #clients == 0 then
                vim.notify(
                  "Could not found `vtsls` lsp client, vue_lsp would not work without it.",
                  vim.log.levels.ERROR
                )
                return
              end
              local ts_client = clients[1]
              local param = unpack(result)
              local id, command, payload = unpack(param)
              ts_client:exec_cmd({
                title = "vue_request_forward",
                command = "typescript.tsserverRequest",
                arguments = {
                  command,
                  payload,
                },
              }, { bufnr = context.bufnr }, function(_, r)
                local response_data = { { id, r.body } }
                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify("tsserver/response", response_data)
              end)
            end
          end,
        },
        vtsls = {},
      },
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
