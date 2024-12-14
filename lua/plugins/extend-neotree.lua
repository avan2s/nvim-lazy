return {
  "nvim-neo-tree/neo-tree.nvim", -- Ensure this is the correct plugin name
  config = function(_, opts)
    local prev_win_config = nil -- Variable to store previous window configuration

    require("neo-tree").setup(vim.tbl_deep_extend("force", opts, {
      window = {
        mappings = {
          ["M"] = function()
            local winid = vim.api.nvim_get_current_win()
            local win_config = vim.api.nvim_win_get_config(winid)

            if prev_win_config then
              if prev_win_config.relative == "" then
                -- Restore regular (non-floating) window size
                vim.cmd(string.format("resize %d | vertical resize %d", prev_win_config.height, prev_win_config.width))
              else
                -- Restore floating window configuration
                vim.api.nvim_win_set_config(winid, prev_win_config)
              end
              prev_win_config = nil
            else
              -- Save current configuration
              prev_win_config = {
                relative = win_config.relative,
                width = vim.api.nvim_win_get_width(winid),
                height = vim.api.nvim_win_get_height(winid),
                row = win_config.row,
                col = win_config.col,
              }

              if win_config.relative == "" then
                -- Maximize regular (non-floating) window
                vim.cmd("resize | vertical resize")
              else
                -- Maximize floating window (set to 100% of the screen size)
                vim.api.nvim_win_set_config(winid, {
                  relative = "editor",
                  width = vim.o.columns,
                  height = vim.o.lines - 2, -- Adjust for status bar and command line
                  row = 0,
                  col = 0,
                })
              end
            end
          end,
        },
      },
    }))
  end,
}
