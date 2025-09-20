return {
  "nvim-mini/mini.pairs",
  opts = {
    -- Remove specific pairs from auto-completion
    mappings = {
      ["("] = false,
      ['"'] = false,
      ["'"] = false,
      ["`"] = false,
    },
  },
}
