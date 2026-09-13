local function base_branch()
  local cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  for _, branch in ipairs({ "develop", "main", "master" }) do
    for _, ref in ipairs({ "refs/heads/" .. branch, "refs/remotes/origin/" .. branch }) do
      local ok = vim.system({ "git", "rev-parse", "--verify", "--quiet", ref }, { cwd = cwd }):wait()
      if ok.code == 0 then
        return ref
      end
    end
  end
end

local function toggle_blame()
  local closed = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "gitsigns-blame" then
      vim.api.nvim_win_close(win, true)
      closed = true
    end
  end
  if not closed then
    require("gitsigns").blame()
  end
end

return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local on_attach = opts.on_attach
    opts.on_attach = function(buffer)
      if on_attach then
        on_attach(buffer)
      end
      vim.keymap.set("n", "<leader>ghB", toggle_blame, { buffer = buffer, desc = "Blame Buffer (toggle)" })
    end
    opts.current_line_blame = true
    opts.current_line_blame_opts = vim.tbl_extend("force", opts.current_line_blame_opts or {}, {
      virt_text_pos = "eol",
      delay = 0,
    })
  end,
  keys = {
    { "<leader>ghB", toggle_blame, desc = "Blame Buffer (toggle)" },
    {
      "<leader>oC",
      function()
        require("gitsigns").diffthis()
      end,
      desc = "Open Changes",
    },
    {
      "<leader>ghm",
      function()
        local base = base_branch()
        if not base then
          vim.notify("No develop/main/master branch found", vim.log.levels.WARN)
          return
        end
        require("gitsigns").diffthis(base)
      end,
      desc = "Diff This (develop/main)",
    },
    {
      "<leader>ghP",
      function()
        require("gitsigns").preview_hunk()
      end,
      desc = "Preview hunk (floating)",
    },
  },
}
