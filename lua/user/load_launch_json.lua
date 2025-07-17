-- ~/.config/nvim/lua/user/load_launch_json.lua
local M = { _loaded = false }

-- Apply smartStep / skipFiles overrides as before
local function apply_overrides()
  local dap = require("dap")
  for _, cfgs in pairs(dap.configurations) do
    if type(cfgs) == "table" then
      for _, cfg in ipairs(cfgs) do
        if cfg.type then
          if vim.g.dap_js_smart_step and cfg.type:match("^pwa") then
            cfg.smartStep = true
          end
          if vim.g.dap_skip_node_modules then
            cfg.skipFiles = cfg.skipFiles or { "<node_internals>/**" }
            local seen = false
            for _, p in ipairs(cfg.skipFiles) do
              if p == "${workspaceFolder}/node_modules/**" then
                seen = true
                break
              end
            end
            if not seen then
              table.insert(cfg.skipFiles, "${workspaceFolder}/node_modules/**")
            end
          end
        end
      end
    end
  end
end

function M.load(opts)
  vim.notify(string.format("[load_launch_json] called (already_loaded=%s)", tostring(M._loaded)), vim.log.levels.DEBUG)
  if M._loaded and not (opts and opts.force) then
    vim.notify("[load_launch_json] skip (already loaded)", vim.log.levels.DEBUG)
    return
  end

  local home = vim.loop.os_homedir()
  local launch_file = vim.fs.find(".vscode/launch.json", {
    upward = true,
    stop = home,
    type = "file",
    limit = 1,
  })[1]

  if not launch_file then
    vim.notify("[load_launch_json] ❌ launch.json not found (up to " .. home .. ")", vim.log.levels.WARN)
    return
  end

  vim.notify("[load_launch_json] found: " .. launch_file, vim.log.levels.INFO)

  local ft_map = {
    ["pwa-node"] = { "typescript" },
    ["pwa-chrome"] = { "javascript", "typescript", "vue" },
    node = { "typescript" },
    chrome = { "javascript", "typescript" },
    js_docker = { "javascript", "typescript", "vue", "svelte" },
  }

  local ok, err = pcall(require("dap.ext.vscode").load_launchjs, launch_file, ft_map)
  if not ok then
    vim.notify("[load_launch_json] ❌ error: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  apply_overrides()
  M._loaded = true
  vim.notify("[load_launch_json] ✔ loaded and overrides applied", vim.log.levels.INFO)
  vim.notify("[load_launch_json] dumping dap.configurations by filetype…", vim.log.levels.DEBUG)

  local dap = require("dap")
  local fts = vim.tbl_keys(dap.configurations)
  table.sort(fts)
  for _, ft in ipairs(fts) do
    local cfgs = dap.configurations[ft] or {}
    local names = vim.tbl_map(function(c)
      return c.name
    end, cfgs)
    vim.notify(string.format("  ft=%s → count=%d; names=%s", ft, #cfgs, vim.inspect(names)), vim.log.levels.DEBUG)
  end
end

return M
