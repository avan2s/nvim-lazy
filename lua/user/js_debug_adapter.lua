-- lua/user/js_debug_adapter.lua
-- Provides a “node-terminal” adapter that:
-- 1) launches node (or a shell) with --inspect=<inspectPort>
--    in the `cwd` specified by the launch config
-- 2) starts js-debug as a TCP server on <inspectPort+1>
-- 3) converts an initial "launch" request into an "attach" for js-debug

local M = {}

local function find_js_debug()
  local mason = vim.env.MASON or vim.fn.stdpath("data") .. "/mason"
  local server = mason .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
  if vim.fn.filereadable(server) == 1 then
    return server
  end
  vim.notify("js-debug-adapter not found; run → :MasonInstall js-debug-adapter", vim.log.levels.WARN)
  return nil
end

function M.setup()
  local server = find_js_debug()
  if not server then
    return
  end

  local dap = require("dap")

  dap.adapters["node-terminal"] = function(callback, config)
    local inspectPort = config.port or 9229
    local dapPort = inspectPort + 1
    local cwd = config.cwd or vim.fn.getcwd()

    if config.request == "launch" then
      local runtime = config.runtimeExecutable or "node"
      local nodeFlags = { "--inspect=" .. inspectPort }
      if config.runtimeArgs then
        vim.list_extend(nodeFlags, config.runtimeArgs)
      end

      local scriptArgs = {}
      if not config.openShell then
        if config.program then
          table.insert(scriptArgs, config.program)
        end
        if config.args then
          vim.list_extend(scriptArgs, config.args)
        end
      end

      local allArgs = vim.list_extend(nodeFlags, scriptArgs)
      local cmdline = runtime .. " " .. table.concat(allArgs, " ")

      local ok, Terminal = pcall(require, "toggleterm.terminal")
      if ok then
        Terminal.Terminal
          :new({
            cmd = cmdline,
            direction = config.direction or "horizontal",
            close_on_exit = false,
            hidden = false,
            dir = cwd,
          })
          :toggle()
      else
        vim.cmd("belowright split")
        vim.cmd("lcd " .. vim.fn.fnameescape(cwd))
        vim.cmd("terminal " .. cmdline)
      end

      config.request = "attach"
      config.type = "pwa-node"
      config.address = config.address or "127.0.0.1"
      config.port = inspectPort

      for _, f in ipairs({
        "program",
        "runtimeExecutable",
        "runtimeArgs",
        "args",
        "openShell",
        "shell",
      }) do
        config[f] = nil
      end
    end

    callback({
      type = "server",
      host = "127.0.0.1",
      port = dapPort,
      executable = {
        command = "node",
        args = { server, tostring(dapPort) },
      },
      cwd = cwd,
    })
  end

  dap.adapters["pwa-node-terminal"] = dap.adapters["node-terminal"]
end

return M
