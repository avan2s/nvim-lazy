if true then
  return {}
end
return {
  "rcarriga/nvim-dap-ui",
  event = "VeryLazy",
  dependencies = { "mfussenegger/nvim-dap" },

  config = function()
    local dap, dapui = require("dap"), require("dapui")

    dapui.setup({
      -- controls = { enabled = false },
      floating = { border = "rounded" },
      -- layouts = { -- minimal, Edgy will place the windows
      --   {
      --     elements = {
      --       { id = "scopes", size = 0.25 },
      --       { id = "breakpoints", size = 0.25 },
      --       { id = "stacks", size = 0.25 },
      --       { id = "watches", size = 0.25 },
      --       { id = "repl", size = 0.25 },
      --     },
      --     position = "bottom",
      --     size = 1, -- full height; Edgy rescales
      --   },
    })

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    local function close_dapui_after_delay()
      if vim.g.dapui_auto_close then
        vim.defer_fn(function()
          if not require("dap").session() then
            dapui.close()
          end
        end, vim.g.dapui_close_delay) -- Use configurable delay
      end
    end

    dap.listeners.after.event_terminated["dapui_close"] = close_dapui_after_delay
    dap.listeners.after.event_exited["dapui_close"] = close_dapui_after_delay
  end,
}
