--[[
  Vue language server (Volar) 3.x requires the classic TypeScript JavaScript
  API (ts.server.protocol). Mason installs `typescript` unpinned, which now
  resolves to the native TypeScript 7 "tsgo" build that ships no JS API, so
  Volar crashes on startup with:
    TypeError: Cannot read properties of undefined (reading 'protocol')

  This hook pins classic TypeScript 5.x inside the vue-language-server package
  and re-applies it automatically after any Mason (re)install, so a fresh
  install / reset script stays fixed without manual intervention.

  SELF-DISABLING: the fix only runs for Volar major version <= 3. Once Volar 4+
  ships with native TypeScript 7 support it will no longer need (or have) the
  classic API, the guard below turns this into a no-op, and this whole file can
  be safely deleted. See https://github.com/vuejs/language-tools/releases
]]

local uv = vim.uv or vim.loop

local COMPATIBLE_WITHOUT_PIN = 4

local function volar_major(install_path)
  local fd = io.open(install_path .. "/node_modules/@vue/language-server/package.json", "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  local major = content:match('"version"%s*:%s*"(%d+)')
  return major and tonumber(major) or nil
end

local function ensure_classic_typescript(install_path)
  local major = volar_major(install_path)
  if not major or major >= COMPATIBLE_WITHOUT_PIN then
    return
  end

  local classic_api = install_path .. "/node_modules/typescript/lib/typescript.js"
  if uv.fs_stat(classic_api) then
    return
  end

  vim.notify("Pinning classic TypeScript 5.x for vue-language-server…", vim.log.levels.INFO)
  vim.system({ "npm", "install", "typescript@^5.9.0" }, { cwd = install_path }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify("vue-language-server: classic TypeScript pinned. Run :LspRestart", vim.log.levels.INFO)
      else
        vim.notify("vue-language-server TypeScript pin failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local registry = require("mason-registry")

      registry:on("package:install:success", function(pkg)
        if pkg.name == "vue-language-server" then
          ensure_classic_typescript(pkg:get_install_path())
        end
      end)

      local ok, pkg = pcall(registry.get_package, "vue-language-server")
      if ok and pkg:is_installed() then
        ensure_classic_typescript(pkg:get_install_path())
      end

      return opts
    end,
  },
}
