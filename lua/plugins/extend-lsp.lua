-- LSP keymaps
-- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
return {
  "neovim/nvim-lspconfig",
  opts = function()
    local key = require("lazyvim.plugins.lsp.keymaps").get()
    -- disable a keymap
    -- keys[#keys + 1] = { "K", false }
    key[#key + 1] = { "<leader>gi", vim.lsp.buf.implementation, desc = "Goto Implementation" }
    key[#key + 1] = { "<M-CR>", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
    key[#key + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "rename", has = "rename" }
    key[#key + 1] = {
      "<leader>rf",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
      mode = { "n" },
      has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
    }
    -- Configure specific server options
    -- return {
    --   keymaps = key,
    --   servers = {
    --     tsserver = {
    --       keys = {
    --         { "<leader>co", "<cmd>TypescriptOrganizeImports<CR>", desc = "Organize Imports" },
    --         { "<leader>cR", "<cmd>TypescriptRenameFile<CR>", desc = "Rename File" },
    --       },
    --     },
    --   },
    -- }
  end,
}

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
-- { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
-- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
-- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
