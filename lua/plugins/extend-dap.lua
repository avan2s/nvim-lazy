-- https://tsx.is/vscode
--[[
  LazyVim's lang.typescript extra (pulled in transitively by lang.vue) already
  registers the js-debug adapters and the default "Launch file" / "Attach"
  (pick-process) configs. Here we only add the fixed-port attach used to debug
  test runners started with --inspect-brk on :9229 (vitest, jest, bun --inspect).
]]
return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    local test_attach = {
      type = "pwa-node",
      request = "attach",
      name = "Attach to test runner (:9229)",
      address = "127.0.0.1",
      port = 9229,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
      skipFiles = { "<node_internals>/**", "**/node_modules/**" },
      restart = true,
    }

    for _, ft in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[ft] = dap.configurations[ft] or {}
      table.insert(dap.configurations[ft], test_attach)
    end
  end,
  keys = {
    { "<F8>", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dn", function() require("dap").step_over() end, desc = "Step Over" },
    { "<F7>", function() require("dap").step_into() end, desc = "Step Into" },
    { "<S-F7>", function() require("dap").step_out() end, desc = "Step Out" },
    { "<F9>", function() require("dap").continue() end, desc = "Run/Continue" },
  },
}
