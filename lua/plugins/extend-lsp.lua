-- LSP keymaps
-- https://www.lazyvim.org/plugins/lsp
-- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vue-language-server",
        "typescript-language-server",
      },
    },
  },
  -- Treesitter configuration (required for vue)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vue", "css", "typescript", "javascript" },
    },
  },
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
        volar = {
          -- vue template to ts communication
          on_init = function(client)
            client.handlers["tsserver/request"] = function(_, result, context)
              local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
              if #clients == 0 then
                vim.notify(
                  "Could not find `vtsls` lsp client, vue_lsp would not work without it.",
                  vim.log.levels.ERROR
                )
                return
              end

              local ts_client = clients[1]
              local param = unpack(result)
              local id, command, payload = unpack(param)

              -- Retry logic with exponential backoff
              local function try_request(attempt)
                attempt = attempt or 1

                ts_client:exec_cmd({
                  title = "vue_request_forward",
                  command = "typescript.tsserverRequest",
                  arguments = { command, payload },
                }, { bufnr = context.bufnr }, function(err, r)
                  if err then
                    vim.notify(err, vim.log.levels.ERROR)
                    return
                  end

                  -- If response is nil and we have retries left, try again
                  if not r or not r.body then
                    -- try for 8 seconds
                    if attempt < 80 then
                      local delay = 100 * attempt -- 100ms, 200ms, 300ms, 400ms
                      vim.defer_fn(function()
                        try_request(attempt + 1)
                      end, delay)
                    end
                    return
                  end

                  -- Success - send response back to volar
                  local response_data = { { id, r.body } }
                  client:notify("tsserver/response", response_data)
                end)
              end

              -- Sometimes the typescript server is not ready yet delivering a good response and the repsonse r is nil in that case
              -- so we retry
              try_request()
            end
          end,
        },
        vtsls = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = LazyVim.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}
