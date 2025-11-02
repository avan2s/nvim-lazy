-- LSP keymaps
-- https://www.lazyvim.org/plugins/lsp
-- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
return {
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
        on_init = function(client)
          client.handlers["tsserver/request"] = function(_, result, context)
            local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
            if #clients == 0 then
              vim.notify("Could not found `vtsls` lsp client, vue_lsp would not work without it.", vim.log.levels.ERROR)
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
}

-- just for getting inspiration, how it is working (picked from the default ls configs)
-- { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
-- { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
-- { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
-- { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
-- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
-- { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
-- { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
-- { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
-- { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
-- { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
-- { "<vim.cmd("resize | vertical resize")>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
-- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
-- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
