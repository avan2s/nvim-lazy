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

return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      -- virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 0,
      -- ignore_whitespace = false,
      -- virt_text_priority = 100,
      -- use_focus = true,
    },
  },
  keys = {
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
