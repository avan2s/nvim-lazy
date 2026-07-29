local gitsigns_diff = require("util.gitsigns_diff")

local function in_diff_buf()
  return gitsigns_diff.rev() ~= nil
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- lualine's branch component finds no git dir for a gitsigns:// buffer, so
    -- swap in the diffed revision there to keep the section filled.
    opts.sections.lualine_b = {
      { "branch", fmt = function(s) return s end, cond = function() return not in_diff_buf() end },
      {
        function()
          return gitsigns_diff.rev() or ""
        end,
        icon = "",
        cond = in_diff_buf,
      },
    }
    return opts
  end,
}
