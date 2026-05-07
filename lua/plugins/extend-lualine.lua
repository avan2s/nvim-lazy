return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections.lualine_b = {
      { "branch", fmt = function(s) return s end },
    }
    return opts
  end,
}
