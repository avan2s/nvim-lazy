-- ~/.config/nvim/lua/plugins/diffview.lua
local hint = { winid = nil, bufnr = nil }

local function hide_hint()
  if hint.winid and vim.api.nvim_win_is_valid(hint.winid) then
    vim.api.nvim_win_close(hint.winid, true)
  end
  hint.winid = nil
end

---Name the panel displays for the entry under the cursor: the file basename, or
---the (possibly flattened) path of a directory.
---@return string?
local function name_at_cursor()
  local view = require("diffview.lib").get_current_view()
  local panel = view and view.panel
  if not panel or panel.winid ~= vim.api.nvim_get_current_win() then
    return nil
  end

  local item = panel:get_item_at_cursor()
  return item and (item.basename or item.name)
end

local function show_hint()
  local name = name_at_cursor()
  if not name then
    return hide_hint()
  end

  local win = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local text_width = win.width - win.textoff
  local line = vim.api.nvim_get_current_line()
  local start = line:find(name, 1, true)
  if start and vim.fn.strdisplaywidth(line:sub(1, start - 1 + #name)) <= text_width then
    return hide_hint()
  end

  local col = win.wincol + win.textoff + text_width
  local width = math.min(vim.fn.strdisplaywidth(name), vim.o.columns - col - 1)
  if width < 1 then
    return hide_hint()
  end

  if not (hint.bufnr and vim.api.nvim_buf_is_valid(hint.bufnr)) then
    hint.bufnr = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(hint.bufnr, 0, -1, false, { name })

  local config = {
    relative = "editor",
    row = math.max(0, win.winrow - 2 + (win.winbar or 0) + vim.fn.winline()),
    col = col,
    width = width,
    height = 1,
    focusable = false,
    zindex = 100,
    border = "rounded",
  }

  if hint.winid and vim.api.nvim_win_is_valid(hint.winid) then
    vim.api.nvim_win_set_config(hint.winid, config)
  else
    config.style, config.noautocmd = "minimal", true
    hint.winid = vim.api.nvim_open_win(hint.bufnr, false, config)
    vim.wo[hint.winid].wrap = false
    vim.wo[hint.winid].winhighlight = "NormalFloat:DiffviewFilePanelFileName,FloatBorder:DiffviewPathHintBorder"
  end
end

local function attach_hint(bufnr)
  local group = vim.api.nvim_create_augroup("DiffviewPathHint_" .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinScrolled", "WinResized", "TextChanged" }, {
    group = group,
    buffer = bufnr,
    callback = show_hint,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufWipeout", "InsertEnter", "CmdlineEnter" }, {
    group = group,
    buffer = bufnr,
    callback = hide_hint,
  })
end

---Commit whatever is staged, asking for the message in a `vim.ui.input` prompt.
---Runs in the repo the current view is attached to, then refreshes the panel.
local function commit_staged()
  local view = require("diffview.lib").get_current_view()
  local cwd = view and view.adapter and view.adapter.ctx.toplevel
  if not cwd then
    return
  end

  if vim.system({ "git", "diff", "--cached", "--quiet" }, { cwd = cwd }):wait().code == 0 then
    vim.notify("Nothing staged to commit", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Commit message: " }, function(msg)
    if not msg or msg:match("^%s*$") then
      return
    end

    local result = vim.system({ "git", "commit", "-m", msg }, { cwd = cwd, text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr ~= "" and result.stderr or result.stdout, vim.log.levels.ERROR)
      return
    end

    vim.notify(vim.trim(result.stdout))
    vim.cmd("DiffviewRefresh")
  end)
end

---Repo the current diffview is attached to, falling back to the root dir so
---this also works outside the file panel (e.g. after a commit emptied it).
---@return string?
local function repo_root()
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view()
  return (view and view.adapter and view.adapter.ctx.toplevel) or LazyVim.root.git()
end

---Push the current branch, setting the upstream on first push. Runs async and
---reports the outcome, since a push can take a while.
local function push_branch()
  local cwd = repo_root()
  if not cwd then
    return
  end

  local head = vim.system({ "git", "symbolic-ref", "--short", "HEAD" }, { cwd = cwd, text = true }):wait()
  if head.code ~= 0 then
    vim.notify("Detached HEAD, nothing to push", vim.log.levels.WARN)
    return
  end

  local branch = vim.trim(head.stdout)
  local cmd = { "git", "push" }
  if vim.system({ "git", "rev-parse", "--abbrev-ref", branch .. "@{upstream}" }, { cwd = cwd }):wait().code ~= 0 then
    vim.list_extend(cmd, { "--set-upstream", "origin", branch })
  end

  vim.notify("Pushing " .. branch .. "...")
  vim.system(cmd, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      local output = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
      if result.code ~= 0 then
        vim.notify(output, vim.log.levels.ERROR)
        return
      end
      vim.notify(output ~= "" and output or ("Pushed " .. branch))
      if require("diffview.lib").get_current_view() then
        vim.cmd("DiffviewRefresh")
      end
    end)
  end)
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory", "DiffviewRefresh" },
  opts = {
    keymaps = {
      file_panel = {
        { "n", "cc", commit_staged, { desc = "Commit staged changes" } },
      },
    },
  },
  init = function()
    vim.api.nvim_set_hl(0, "DiffviewPathHintBorder", { link = "DiagnosticWarn", default = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("DiffviewPathHintAttach", { clear = true }),
      pattern = { "DiffviewFiles", "DiffviewFileHistory" },
      callback = function(args)
        attach_hint(args.buf)
      end,
    })
  end,
  keys = {
    -- Use <leader>g for "Git"
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    -- { "<leader>gt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Files (Diff View)" },
    { "<leader>ghi", "<cmd>DiffviewFileHistory<cr>", desc = "File History (Git)" },
    { "<leader>gp", push_branch, desc = "Push Branch (Git)" },
    -- { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File History for Word (Git)" },
    {
      "<leader>oc",
      function()
        local diffview_lib = require("diffview.lib")
        if diffview_lib.get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
          vim.cmd("DiffviewToggleFiles")
        end
      end,
      desc = "Toggle Changes View (No Sidebar)",
    },
  },
}
