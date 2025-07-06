-- ~/.config/nvim/lua/plugins/diffview.lua
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
  keys = {
    -- Use <leader>g for "Git"
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    { "<leader>gt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Files (Diff View)" },
    { "<leader>ghi", "<cmd>DiffviewFileHistory<cr>", desc = "File History (Git)" },
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
