---- lua/plugins/custom-keymaps.lua
return {
  "LazyVim/LazyVim",
  keys = {
    {
      "X",
      function()
        -- Existing float?
        local winid = vim.b.diagnostic_winid
        if winid and vim.api.nvim_win_is_valid(winid) then
          vim.api.nvim_set_current_win(winid)
          return
        end

        -- Preserve current virtual-text setting and turn it off
        local prev_virtual_text = vim.diagnostic.config().virtual_text
        vim.b._prev_virtual_text = prev_virtual_text
        vim.diagnostic.config({ virtual_text = false })

        -- Open a focusable diagnostics float for the current line
        local _, float_winid = vim.diagnostic.open_float(nil, { scope = "cursor", focusable = true })
        if not float_winid then
          vim.diagnostic.config({ virtual_text = prev_virtual_text })
          return
        end
        vim.b.diagnostic_winid = float_winid

        -- Restore virtual-text automatically when the float closes
        vim.api.nvim_create_autocmd("WinClosed", {
          once = true,
          callback = function(ev)
            if tonumber(ev.match) == float_winid then
              vim.diagnostic.config({ virtual_text = vim.g.lsp_diagnostics_virtual_text })
              vim.b.diagnostic_winid = nil
              vim.b._prev_virtual_text = nil
            end
          end,
        })
      end,
      mode = "n",
      desc = "Diagnostics: Toggle Float / Focus",
    },
  },
}
