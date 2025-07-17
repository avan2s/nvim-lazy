-- ~/.config/nvim/lua/auto_node_attach.lua
-- Auto-attaches nvim-dap to any Node.js process that prints the usual
-- “Debugger listening on ws://…:<port>/…” banner in the terminal.

local dap = require("dap")

local M = {}

local attached_ports = {}

---@param port integer
local function attach(port)
  vim.notify(("[auto-node-attach] Attaching to port %d"):format(port), vim.log.levels.INFO, { title = "DAP" })
  dap.run({
    type = "pwa-node",
    request = "attach",
    name = ("Auto-Attach (%d)"):format(port),
    cwd = vim.fn.getcwd(),
    port = port,
    restart = true,
    autoAttachChildProcesses = false,
    stopOnEntry = false,
  })
end

---@param bufnr integer
local function watch_terminal(bufnr)
  local pattern = vim.regex([[Debugger listening on ws://\S\+:\zs\d\+\ze/]])
  vim.notify(("[auto-node-attach] Watching terminal buffer %d"):format(bufnr), vim.log.levels.INFO, { title = "DAP" })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, b, _, firstline, lastline, _)
      local lines = vim.api.nvim_buf_get_lines(b, firstline, lastline, false)
      for _, line in ipairs(lines) do
        if type(line) == "string" then
          local s, e = pattern:match_str(line)
          if s then
            local port = tonumber(line:sub(s + 1, e))
            if port then
              vim.notify(
                ("[auto-node-attach] Found port %d in line: %s"):format(port, line),
                vim.log.levels.INFO,
                { title = "DAP" }
              )
              if not attached_ports[port] then
                vim.notify(
                  ("[auto-node-attach] Port %d is new, attaching..."):format(port),
                  vim.log.levels.INFO,
                  { title = "DAP" }
                )
                attached_ports[port] = true
                vim.defer_fn(function()
                  attached_ports[port] = nil
                  vim.notify(
                    ("[auto-node-attach] Port %d timeout expired."):format(port),
                    vim.log.levels.DEBUG,
                    { title = "DAP" }
                  )
                end, 5000)
                attach(port)
                return -- Exit after attaching
              else
                vim.notify(
                  ("[auto-node-attach] Port %d already being attached, skipping."):format(port),
                  vim.log.levels.WARN,
                  { title = "DAP" }
                )
              end
            end
          end
        end
      end
    end,
  })
end

function M.enable()
  if M.enabled then
    return
  end
  M.enabled = true
  vim.notify("[auto-node-attach] enabled", vim.log.levels.INFO, { title = "DAP" })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("AutoNodeAttach", { clear = true }),
    pattern = "*",
    callback = function(args)
      vim.notify(
        ("[auto-node-attach] TermOpen event for buffer %d"):format(args.buf),
        vim.log.levels.INFO,
        { title = "DAP" }
      )
      watch_terminal(args.buf)
    end,
  })
end

function M.disable()
  if not M.enabled then
    return
  end
  M.enabled = false
  vim.notify("[auto-node-attach] disabled", vim.log.levels.INFO, { title = "DAP" })
  vim.api.nvim_del_augroup_by_name("AutoNodeAttach")
end

return M
