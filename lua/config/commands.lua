local function copy_filename(modifier)
  local path = vim.fn.expand("%" .. modifier)
  if path == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied" })
end

vim.api.nvim_create_user_command("CopyFilePath", function(opts)
  copy_filename(opts.bang and ":p" or ":.")
end, { bang = true, desc = "Copy file path relative to cwd (! = absolute)" })

vim.api.nvim_create_user_command("CopyFileName", function()
  copy_filename(":t")
end, { desc = "Copy file name" })

for _, name in ipairs({ "CopyFilePath", "CopyFileName" }) do
  vim.keymap.set("ca", name:lower(), function()
    return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == name:lower() and name or name:lower()
  end, { expr = true })
end
