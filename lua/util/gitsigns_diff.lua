local M = {}

--[[
  Revision shown by a gitsigns diffthis buffer, shortened for display:
  refs/heads/develop -> develop, refs/remotes/origin/main -> origin/main, :0 -> index.
  Buffers are named gitsigns://<gitdir>//<rev>:<relpath>; returns nil for anything else.
]]
function M.rev(buf)
  local rev = vim.api.nvim_buf_get_name(buf or 0):match("^gitsigns://.*//(.*):[^:]*$")
  if not rev then
    return nil
  end
  if rev == ":0" then
    return "index"
  end
  return (rev:gsub("^refs/heads/", ""):gsub("^refs/remotes/", ""))
end

return M
