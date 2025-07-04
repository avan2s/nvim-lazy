-- lua/plugins/custom-keymaps.lua
return {
  -- This is a dummy plugin spec. We are only using it to install our keymaps.
  "LazyVim/LazyVim",
  keys = {
    {
      "X",
      function()
        -- This variable will hold the window ID of the diagnostic float
        -- 'vim.b.diagnostic_winid' stores it per-buffer, which is a good practice.
        -- We use a buffer-local variable to avoid conflicts between different files.
        local diagnostic_winid = vim.b.diagnostic_winid

        -- Check if the window ID we stored is still a valid, open window
        if diagnostic_winid and vim.api.nvim_win_is_valid(diagnostic_winid) then
          -- If it is, this is the "second press": move the cursor into it
          vim.api.nvim_set_current_win(diagnostic_winid)
        else
          -- If not, this is the "first press": open a new float
          -- The 'scope = "cursor"' option ensures it only shows diagnostics for the current line
          -- 'focusable = true' is crucial so we can move into the window later
          local _, winid = vim.diagnostic.open_float(nil, {
            scope = "cursor",
            focusable = true,
          })
          -- If a window was successfully opened, store its ID
          if winid then
            vim.b.diagnostic_winid = winid
          end
        end
      end,
      mode = "n", -- Normal mode
      desc = "Diagnostics: Toggle Float / Focus",
    },
  },
  -- this makes the whole window instead of the diagnostic window in that style - strange - commented out for now
  -- opts = {
  --   -- This section is not used, but the `config` function will run
  -- },
  -- config = function()
  --   -- Configure the appearance of the diagnostic float
  --   vim.diagnostic.config({
  --     float = {
  --       border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  --       source = "if_many", -- "if_many" (default) or true/false to always/never show the source
  --       header = "", -- Don't show a header
  --       prefix = "", -- Don't show a prefix
  --     },
  --   })
  -- end,
}
