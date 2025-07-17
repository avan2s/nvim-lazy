if true then
  return {}
end
-- lua/plugins/dap.lua
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "folke/snacks.nvim",
    "Weissle/persistent-breakpoints.nvim",
    "nvim-neotest/nvim-nio",
    { "jbyuki/one-small-step-for-vimkind", name = "osv" },
  },

  keys = {
    ------------------------------------------------------------------
    -- Smart start / continue
    ------------------------------------------------------------------
    {
      "<F5>",
      function()
        local dap = require("dap")
        if dap.session() then
          dap.continue()
        else
          -- load launch.json, prelaunch, etc...
          local ft = vim.bo.filetype
          local cfgs = dap.configurations[ft] or {}

          if #cfgs == 1 then
            dap.run(cfgs[1])
          else
            local snacks = require("snacks")
            snacks.picker.pick(nil, {
              title = "DAP Configurations",
              items = cfgs, -- your table of configs
              format = function(item) -- display only the `name`
                return item.name
              end,
              confirm = function(picker, item) -- on selection...
                picker:close()
                dap.run(item)
              end,
            })
          end
        end
      end,
      mode = { "n", "i", "v", "t" },
      desc = "DAP • Continue / Start",
    },

    ------------------------------------------------------------------
    -- Other DAP mappings
    ------------------------------------------------------------------
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
        require("dapui").toggle({ reset = true })
      end,
      desc = "DAP • Toggle UI",
    },
    {
      "<leader>df",
      function()
        require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames)
      end,
      desc = "DAP • Frames popup",
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

  --------------------------------------------------------------------
  -- Main configuration (unchanged except for the auto-attach toggle)
  --------------------------------------------------------------------
  config = function()
    local dap = require("dap")
    local auto = require("user.auto_node_attach") -- no auto.enable() here
    require("user.load_launch_json").load()

    require("nvim-dap-virtual-text").setup()

    require("persistent-breakpoints").setup({
      load_breakpoints_event = { "BufReadPost" }, -- load on every file open
      always_reload = true,
      save_dir = vim.fn.stdpath("data") .. "/dap_breakpoints",
    })

    -- use its API so every toggle / clear is persisted automatically
    local pb = require("persistent-breakpoints.api")
    vim.keymap.set(
      { "n", "i", "v" },
      "<leader>db",
      pb.toggle_breakpoint,
      { desc = "DAP • Toggle breakpoint (persist)" }
    )
    vim.keymap.set("n", "<leader>dc", pb.clear_all_breakpoints, { desc = "DAP • Clear all breakpoints (persist)" })

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
    require("user.js_debug_adapter").setup()

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
      dap.adapters["node"] = dap.adapters["node"] or make_adapter()
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
      "vue",
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

    dap.listeners.after.event_stopped["focus_source"] = function()
      vim.schedule(function()
        local session = require("dap").session()
        if session == nil or session.current_frame == nil then
          return
        end

        local frame = session.current_frame
        local path = frame.source and frame.source.path
        local line = frame.line or frame.lineno

        if not (path and line) or vim.fn.filereadable(path) == 0 then
          return
        end

        vim.cmd("keepalt edit " .. vim.fn.fnameescape(path))
        local win = vim.fn.bufwinid(vim.fn.bufnr(path))
        if win ~= -1 then
          vim.fn.win_gotoid(win)
          vim.api.nvim_win_set_cursor(win, { line, 0 })
        end
      end)
    end
    ----------------------------------------------------------------
    -- Helper commands for auto-attach
    ----------------------------------------------------------------
    vim.api.nvim_create_user_command("AutoNodeAttachEnable", function()
      auto.enable()
    end, { desc = "Enable auto Node attach" })

    vim.api.nvim_create_user_command("AutoNodeAttachDisable", function()
      auto.disable()
    end, { desc = "Disable auto Node attach" })

    vim.api.nvim_create_user_command("AutoNodeAttachToggle", function()
      if auto.enabled then
        auto.disable()
      else
        auto.enable()
      end
    end, { desc = "Toggle auto Node attach" })

    ----------------------------------------------------------------
    -- Start nvim-lua debug server helper (unchanged)
    ----------------------------------------------------------------
    vim.api.nvim_create_user_command("NvimStartDebugServer", function()
      require("osv").launch({ port = 8086 })
    end, {
      desc = "Start nvim-dap server for Lua debugging",
    })
    local function enable_arrow_stepping()
      vim.keymap.set("n", "<Down>", function()
        dap.step_over()
      end, { silent = true, desc = "DAP • Step over" })
      vim.keymap.set("n", "<Right>", function()
        dap.step_into()
      end, { silent = true, desc = "DAP • Step into" })
      vim.keymap.set("n", "<Left>", function()
        dap.step_out()
      end, { silent = true, desc = "DAP • Step out" })
      vim.keymap.set("n", "<Up>", function()
        dap.continue()
      end, { silent = true, desc = "DAP • Continue" })
    end

    -- Helper to clear those mappings when the session ends
    local function disable_arrow_stepping()
      vim.keymap.del("n", "<Right>")
      vim.keymap.del("n", "<Down>")
      vim.keymap.del("n", "<Left>")
      vim.keymap.del("n", "<Up>")
    end

    -- Apply on initialize
    dap.listeners.after.event_initialized["arrow_keys"] = function()
      enable_arrow_stepping()
    end

    -- Clear on terminate or exit
    dap.listeners.before.event_terminated["arrow_keys"] = function()
      disable_arrow_stepping()
    end
    dap.listeners.before.event_exited["arrow_keys"] = function()
      disable_arrow_stepping()
    end
  end,
}
