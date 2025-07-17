-- ~/.config/nvim/lua/user/dap_prelaunch.lua

local dap = require("dap")
local original_run = dap.run

local pre_tasks, post_tasks = {}, {}
local pre_buffers, post_buffers = {}, {}

local function substitute_vars(str, config)
  local ws = config.workspaceFolder or vim.fn.getcwd()
  local ws_base = vim.fn.fnamemodify(ws, ":t")
  return str:gsub("${workspaceFolder}", ws):gsub("${workspaceFolderBasename}", ws_base)
end

local function resolve_cwd(config)
  local cwd = config.cwd
  if type(cwd) == "function" then
    cwd = cwd()
  elseif type(cwd) == "string" then
    cwd = substitute_vars(cwd, config)
  end
  return cwd or vim.fn.getcwd()
end

local function run_task_in_buf(name, task, cwd, title_prefix, buffers, filetype, on_exit_cb)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, title_prefix .. ": " .. name)
  vim.bo[buf].filetype = filetype
  buffers[name] = buf

  vim.cmd("botright split")
  vim.cmd("resize 12")
  vim.api.nvim_win_set_buf(0, buf)
  vim.notify(("▶️ %s '%s'…"):format(title_prefix, task), vim.log.levels.INFO)

  local function on_data(_, data)
    if not data then
      return
    end
    for _, line in ipairs(data) do
      if line ~= "" then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
      end
    end
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      local lc = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(win, { lc, 0 })
    end
  end

  local cancelled = false
  local job = vim.fn.jobstart({ "npm", "run", "--prefix", cwd, task }, {
    cwd = cwd,
    on_stdout = on_data,
    on_stderr = on_data,

    on_exit = function(_, code)
      if cancelled then
        return
      end
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          local win_id = vim.fn.bufwinid(buf)
          -- if win_id ~= -1 then
          --   vim.api.nvim_win_close(win_id, true)
          -- end
        end
        if code == 0 then
          vim.notify(("✅ %s '%s' succeeded"):format(title_prefix, task), vim.log.levels.INFO)
        else
          vim.notify(("❌ %s '%s' failed (exit %d)"):format(title_prefix, task, code), vim.log.levels.ERROR)
        end
        if on_exit_cb then
          on_exit_cb(code)
        end
      end, 100)
    end,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<C-c>", "", {
    noremap = true,
    silent = true,
    callback = function()
      cancelled = true
      vim.fn.jobstop(job)
      vim.notify(("🚫 %s cancelled."):format(title_prefix), vim.log.levels.WARN)
      if vim.api.nvim_buf_is_valid(buf) then
        local win_id = vim.fn.bufwinid(buf)
        if win_id ~= -1 then
          vim.api.nvim_win_close(win_id, true)
        else
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end,
  })
end

local M = {}

local last_launched_name = nil

function M.setup()
  for _, list in pairs(dap.configurations) do
    for _, cfg in ipairs(list) do
      local key = cfg.name or cfg.__originalName
      if cfg.preLaunchTask and key then
        pre_tasks[key] = cfg.preLaunchTask
        vim.notify(("🔧 Configured preLaunchTask for '%s': %s"):format(key, cfg.preLaunchTask), vim.log.levels.DEBUG)
        cfg.preLaunchTask = nil
      end
      if cfg.postDebugTask and key then
        post_tasks[key] = cfg.postDebugTask
        vim.notify(("🔧 Configured postDebugTask for '%s': %s"):format(key, cfg.postDebugTask), vim.log.levels.DEBUG)
        cfg.postDebugTask = nil
      end
    end
  end

  dap.run = function(config)
    if type(config) ~= "table" then
      vim.notify("⚠️ DAP config is not a table. Aborting run.", vim.log.levels.WARN)
      return original_run(config)
    end

    config.__originalName = config.name
    last_launched_name = config.name

    vim.notify(
      ("📦 DAP Launch: '%s' (%s) → %s"):format(
        config.name or "<unnamed>",
        config.type or "?",
        config.__originalName
      ),
      vim.log.levels.INFO
    )

    if config.program and config.program:find("vitest") then
      local pattern = vim.fn.input("🔍 Vitest test file or name pattern: ")
      if pattern and pattern ~= "" then
        vim.notify("➕ Appending test pattern: " .. pattern, vim.log.levels.INFO)
        config.args = config.args or {}
        table.insert(config.args, pattern)
      end
    end

    local task = pre_tasks[config.__originalName or config.name]
    if not task then
      vim.notify("⏩ No preLaunchTask defined. Launching debugger immediately.", vim.log.levels.INFO)
      return original_run(config)
    end

    local cwd = resolve_cwd(config)
    vim.notify(("▶️ Running preLaunchTask '%s' in %s…"):format(task, cwd), vim.log.levels.INFO)

    run_task_in_buf(config.__originalName or config.name, task, cwd, "DAP PreLaunchTask", pre_buffers, "dap.prelaunch")

    vim.defer_fn(function()
      original_run(config)
    end, 100)
  end

  function M.force_post_task()
    local session = dap.session()
    if not session or not session.config then
      vim.notify("⚠️ No active session to run postDebugTask for.", vim.log.levels.WARN)
      return
    end
    local name = session.config.__originalName or last_launched_name or session.config.name
    local task = post_tasks[name]
    if not task then
      vim.notify("ℹ️ No postDebugTask configured for '" .. name .. "'", vim.log.levels.INFO)
      return
    end
    local cwd = resolve_cwd(session.config)
    vim.notify(("⏳ Forcing postDebugTask '%s' for '%s'"):format(task, name), vim.log.levels.INFO)
    run_task_in_buf(name, task, cwd, "DAP PostDebugTask", post_buffers, "dap.postdebug", function()
      require("dap").terminate()
    end)
  end

  local function run_post_task(_, body)
    local session = dap.session()
    if not session or not session.config then
      return
    end
    local name = session.config.__originalName or last_launched_name or session.config.name
    local task = post_tasks[name]

    vim.notify("📤 dap event 'terminated' or 'exited' received", vim.log.levels.DEBUG)
    vim.notify(("🕵️ Looking for postDebugTask for '%s'…"):format(name), vim.log.levels.DEBUG)

    if not task then
      vim.notify("ℹ️ No postDebugTask for session '" .. name .. "'", vim.log.levels.DEBUG)
      return
    end

    local cwd = resolve_cwd(session.config)
    vim.defer_fn(function()
      vim.notify(("📦 DAP Finished: Running postDebugTask '%s' for '%s'"):format(task, name), vim.log.levels.INFO)
      run_task_in_buf(name, task, cwd, "DAP PostDebugTask", post_buffers, "dap.postdebug", function()
        require("dap").terminate()
      end)
    end, 100)
  end

  dap.listeners.after.event_terminated["dap_tasks_post"] = run_post_task
  dap.listeners.after.event_exited["dap_tasks_post"] = run_post_task
end

function M.open_prelaunch(name)
  local buf = pre_buffers[name]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.notify("⚠️ No DAP prelaunch buffer for '" .. name .. "'", vim.log.levels.WARN)
  end
end

function M.open_postdebug(name)
  local buf = post_buffers[name]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.notify("⚠️ No DAP post-debug buffer for '" .. name .. "'", vim.log.levels.WARN)
  end
end

return M
