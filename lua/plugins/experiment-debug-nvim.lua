if true then
  return {}
end
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "nvim-telescope/telescope-dap.nvim",
    "Weissle/persistent-breakpoints.nvim",
    "nvim-neotest/nvim-nio",
    { "jbyuki/one-small-step-for-vimkind", name = "osv" },
  },
  keys = {
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "DAP • Continue",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "DAP • Terminate",
    },
    {
      "<F6>",
      function()
        require("dap").step_over()
      end,
      desc = "DAP • Step over",
    },
    {
      "<F7>",
      function()
        require("dap").step_into()
      end,
      desc = "DAP • Step into",
    },
    {
      "<F8>",
      function()
        require("dap").step_out()
      end,
      desc = "DAP • Step out",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "DAP • Toggle breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Condition: "))
      end,
      desc = "DAP • Conditional breakpoint",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "DAP • Toggle REPL",
    },
    {
      "<leader>du",
      function()
        require("edgy").toggle()
      end,
      desc = "DAP • Toggle UI",
    },
    {
      "<leader>dl",
      function()
        require("user.load_launch_json").load({ force = true })
      end,
      desc = "DAP • Reload launch.json",
    },
    {
      "<leader>drl",
      function()
        require("dap").run_last()
      end,
      desc = "DAP • Run last",
    },
  },
  config = function()
    local dap = require("dap")

    require("nvim-dap-virtual-text").setup()

    --------------------------------------------------------------------
    -- Resolve js-debug-adapter independent of Mason internals
    --------------------------------------------------------------------
    local function find_js_debug()
      -- Mason’s install root ($MASON env or the default data dir)
      local mason_root = vim.fn.expand("$MASON")
      if mason_root == "" then
        mason_root = vim.fn.stdpath("data") .. "/mason"
      end

      -- Expected server path
      local server = mason_root .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      -- If it’s missing, tell the user how to install and keep going
      if vim.fn.filereadable(server) == 0 then
        vim.notify("js-debug-adapter is not installed — run :MasonInstall js-debug-adapter", vim.log.levels.WARN)
        return nil
      end

      return server
    end

    --------------------------------------------------------------------
    -- Register PWA adapters once the server is available
    --------------------------------------------------------------------
    local debugger = find_js_debug()
    if debugger then
      local function make_adapter()
        return {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = { command = "node", args = { debugger, "${port}" } },
        }
      end
      dap.adapters["pwa-node"] = dap.adapters["pwa-node"] or make_adapter()
      dap.adapters["pwa-chrome"] = dap.adapters["pwa-chrome"] or make_adapter()
    end

    dap.adapters.nlua = function(callback, _)
      callback({ type = "server", host = "127.0.0.1", port = 8086 })
    end

    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim",
        host = "127.0.0.1",
        port = 8086,
      },
    }

    --------------------------------------------------------------------
    -- Language scaffolding (launch.json extends this)
    --------------------------------------------------------------------
    for _, lang in ipairs({
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "svelte",
    }) do
      dap.configurations[lang] = dap.configurations[lang] or {}
    end

    --------------------------------------------------------------------
    -- Signs / glyphs
    --------------------------------------------------------------------
    local signs = {
      DapBreakpoint = { text = "", texthl = "DiagnosticSignError" },
      DapBreakpointCondition = { text = "", texthl = "DiagnosticSignWarn" },
      DapLogPoint = { text = "", texthl = "DiagnosticSignInfo" },
      DapStopped = {
        text = "",
        texthl = "DiagnosticSignHint",
        linehl = "Visual",
        numhl = "DiagnosticSignHint",
      },
    }
    for name, cfg in pairs(signs) do
      vim.fn.sign_define(name, cfg)
    end

    dap.listeners.after.event_initialized["edgy"] = function()
      require("edgy").open()
    end
    dap.listeners.before.event_terminated["edgy"] = function()
      require("edgy").close()
    end
    dap.listeners.before.event_exited["edgy"] = function()
      require("edgy").close()
    end

    vim.api.nvim_create_user_command("NvimStartDebugServer", function()
      require("osv").launch({ port = 8086 })
    end, {
      desc = "Start nvim-dap server for Lua debugging",
    })
  end,
}
